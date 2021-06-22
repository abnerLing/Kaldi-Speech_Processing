

# DNN-based ASR with TORGO
- Simple cfg file for TORGO data using pytorch-kaldi based DNN's
- This is just an example on how to use the pytorch-kaldi library to improve the WER of dysarthric speech ASR.
- To use this toolkit you must already have alignments generated from a GMM-HMM acoustic model with kaldi.
  
### Installation
- install pytorch https://pytorch.org/get-started/locally/
- clone pytorch-kaldi repository (I highly reccomend following one of their tutorials on TIMIT or Librispeech first, so you know the basics of this toolkit).
```
git clone git clone https://github.com/mravanelli/pytorch-kaldi
```
install required libraries for pytorch-kaldi
```
cd pytorch-kaldi
pip install -r requirements.txt
```

### Instructions
0. Unlike our original train/test split we need a development set when training our DNN.
- You can write a script simialr to [this](https://github.com/abnerLing/Kaldi-Speech_Processing/blob/main/speech%20recognition/dnn-pytorch/make_dev.sh) to generate a development set from your train set.
1. We will use MFCC features for training.
2. Next you need align train, test, and dev sets.
```
steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
      $data_dir/train $lang $gmmdir exp/tri4_ali_train || exit 1
```
3. Directly modify the cfg directories to point to your features, alignments, scoring script<br/>
This will need to be done for all features, all alignments, all data sets.
```
features:
fea_lst=/home/user/kaldi/egs/torgo-speech_processing/asr-dnn/data/train/fbank_pitch/feats.scp
alignments:
lab_folder=/home/user/kaldi/egs/torgo-speech_processing/asr-dnn/exp/tri4_ali
scoring:
scoring_script = /home/user/kaldi/egs/torgo-speech_processing/asr-dnn/local/score.sh
```
4. Run cfg script 
``` 
python /pytorch-kaldi/run_exp.py cfg/torgo_base.cfg
```
Check Results
``` 
cat /pytorch-kaldi/exp/torgo/decode_test_out_dnn1/scoring_kaldi/best_wer
%WER 32.05 [ 890 / 2777, 163 ins, 152 del, 575 sub ]
```

## Modify hyperparameters?
There are many things you could test out to improve WER by optimizing some hyperparameters.
- Adjust # of layers or hidden nodes.
- Modify learning rate or the scheduler.
- Different DNN model types.
- Different optimizer or optimization parameters.
- etc...
