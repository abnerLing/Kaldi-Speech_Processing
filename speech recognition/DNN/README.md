# Kaldi for Dysarthic Speech Recognition
- **Part 3: Speech Recognition**
- DNN-based acoustic model training


## We must first train a GMM-HMM AM before attempting a DNN-based model
- After training we can extend extend our previous run.sh script to include the below command
```
local/nnet/run_dnn.sh --nj 1
```

## Storing fmllr features 
```
dir=$data_fmllr/test
steps/nnet/make_fmllr_feats.sh --nj $nj --cmd "$train_cmd" \
   --transform-dir $gmm/decode \
   $dir data/test $gmm $dir/log $dir/data
# train
dir=$data_fmllr/train
steps/nnet/make_fmllr_feats.sh --nj $nj --cmd "$train_cmd" \
   --transform-dir ${gmm}_ali \
   $dir data/train $gmm $dir/log $dir/data
# split the data : 13 speakers train 1 speaker cross-validation (held-out)
utils/subset_data_dir_tr_cv.sh --cv-spk-percent ${cv_spk_percent}  $dir ${dir}_tr90 ${dir}_cv10
```
## Pretrain a deep belief network (DBN)
```
if [ $stage -le 1 ]; then
  # Pre-train DBN, i.e. a stack of RBMs (small database, smaller DNN)
  dir=exp/dnn4b_pretrain-dbn
  $cuda_cmd $dir/log/pretrain_dbn.log \
    steps/nnet/pretrain_dbn.sh --hid-dim 1024 --rbm-iter 20 $data_fmllr/train $dir
fi
```
## Train the DNN optimizing per-frame cross-entropy
```
if [ $stage -le 2 ]; then
  # Train the DNN optimizing per-frame cross-entropy.
  dir=exp/dnn4b_pretrain-dbn_dnn
  ali=${gmm}_ali
  feature_transform=exp/dnn4b_pretrain-dbn/final.feature_transform
  dbn=exp/dnn4b_pretrain-dbn/6.dbn
  # Train
  $cuda_cmd $dir/log/train_nnet.log \
    steps/nnet/train.sh --feature-transform $feature_transform --dbn $dbn --hid-layers 0 --learn-rate 0.008 \
    $data_fmllr/train_tr90 $data_fmllr/train_cv10 data/lang $ali $ali $dir
  # Decode (reuse HCLG graph)
  steps/nnet/decode.sh --nj $nj --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 \
    $gmm/graph_test $data_fmllr/test $dir/decode #cris graph_test
fi
```

## Re-train the DNN by 6 iterations of sMBR (State Minimum Bayes Risk, discriminative training)
```
if [ $stage -le 3 ]; then
  # First we generate lattices and alignments:
  steps/nnet/align.sh --nj $nj --cmd "$train_cmd" \
    $data_fmllr/train data/lang $srcdir ${srcdir}_ali
  steps/nnet/make_denlats.sh --nj $nj --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt $acwt \
    $data_fmllr/train data/lang $srcdir ${srcdir}_denlats
fi

if [ $stage -le 4 ]; then
  # Re-train the DNN by 6 iterations of sMBR
  steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters 6 --acwt $acwt --do-smbr true \
    $data_fmllr/train data/lang $srcdir ${srcdir}_ali ${srcdir}_denlats $dir
  # Decode
  for ITER in 6 3 1; do
    steps/nnet/decode.sh --nj $nj --cmd "$decode_cmd" --config conf/decode_dnn.config \
      --nnet $dir/${ITER}.nnet --acwt $acwt \
      $gmm/graph_test $data_fmllr/test $dir/decode_it${ITER} #cris graph_test
  done
fi
```
## View Results
```
# GMM Results
cat exp/tri4/decode/scoring_kaldi/best_wer
%WER 35.96 [ 1001 / 2784, 234 ins, 122 del, 645 sub ] /home/abner/kaldi/egs/torgo_test/exp/train/tri4/decode_test/wer_17_0.5

# DNN Results
cat exp/dnn4b_pretrain-dbn_dnn_smbr/decode_it3/scoring_kaldi/best_wer
%WER 28.38 [ 790 / 2784, 197 ins, 85 del, 508 sub ] exp/dnn4b_pretrain-dbn_dnn_smbr/decode_it3/wer_15_0.0
```
- Our DNN-based acoustic model lowered the WER by 7.58% with no hyperparameter tuning 

| Errors  | GMM  | DNN |
| -------- | ------- | ------- |
| Insertion  | 234  | 197  |
| Deletion  | 122  | 85  |
| Substitution  | 645  | 508  |
| Total  | 1001  | 790  |
|    |    |    |
| WER  | 35.96%  | 28.38%  |
