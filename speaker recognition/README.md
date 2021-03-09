# Part 4 Speaker Recognition

### Now we are going to use i-vectors to recognize speakers 
- original i-vector article for speaker verification (see [Front-End Factor Analysis for Speaker Verification](https://ieeexplore.ieee.org/abstract/document/5545402?casa_token=Ri80oe_Y9K4AAAAA:FVar6WkCvIZFr2qn1U19M2ovlBA5fw7y0XtZG0tlvOG2xnfWjmJBoV8hq-6vZqb2tIsGlL2RFQ)).
- For this part we will train models on healthy speakers (7 speakers) and test on speakers with dysarthria (8 speakers).

### Extract MFCCs and compute voice activity detection outputs
```
mfccdir=mfcc
for x in train test; do
  utils/utt2spk_to_spk2utt.pl data/$x/utt2spk > data/$x/spk2utt
  steps/make_mfcc.sh --cmd "$train_cmd" --nj $nj data/$x exp/make_mfcc/$x $mfccdir
  sid/compute_vad_decision.sh --nj $nj --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done
```

### Train a GMM-UBM model
```
# train diag ubm
sid/train_diag_ubm.sh --nj $nj --cmd "$train_cmd" \
  data/train 1024 exp/diag_ubm_1024
```
```
sid/train_diag_ubm.sh: initializing model from E-M in memory,
sid/train_diag_ubm.sh: starting from 512 Gaussians, reaching 1024;
sid/train_diag_ubm.sh: for 20 iterations, using at most 500000 frames of data
Getting Gaussian-selection info
sid/train_diag_ubm.sh: will train for 4 iterations, in parallel over
sid/train_diag_ubm.sh: 7 machines, parallelized with 'run.pl'
sid/train_diag_ubm.sh: Training pass 0
sid/train_diag_ubm.sh: Training pass 1
sid/train_diag_ubm.sh: Training pass 2
sid/train_diag_ubm.sh: Training pass 3
```
```
#train full ubm
sid/train_full_ubm.sh --nj $nj --cmd "$train_cmd" data/train \
  exp/diag_ubm_1024 exp/full_ubm_1024
```
```
sid/train_full_ubm.sh: doing Gaussian selection (using diagonal form of model; selecting 20 indices)
Pass 0
Pass 1
Pass 2
Pass 3
```

### Train an i-vector extractor model
```
#train ivector
sid/train_ivector_extractor.sh --cmd "$train_cmd" --nj 1\
  --num-iters 5 exp/full_ubm_1024/final.ubm data/train \
  exp/extractor_1024
```
```
sid/train_ivector_extractor.sh: doing Gaussian selection and posterior computation
Accumulating stats (pass 0)
Summing accs (pass 0)
Updating model (pass 0)
Accumulating stats (pass 1)
Summing accs (pass 1)
Updating model (pass 1)
Accumulating stats (pass 2)
Summing accs (pass 2)
Updating model (pass 2)
Accumulating stats (pass 3)
Summing accs (pass 3)
Updating model (pass 3)
Accumulating stats (pass 4)
Summing accs (pass 4)
Updating model (pass 4)
```

### Extract i-vectors from audio files
```
sid/extract_ivectors.sh --cmd "$train_cmd" --nj $nj \
  exp/extractor_1024 data/train exp/ivector_train_1024
```
```
sid/extract_ivectors.sh: extracting iVectors
sid/extract_ivectors.sh: combining iVectors across jobs
sid/extract_ivectors.sh: computing mean of iVectors for each speaker and length-normalizing
```

### Train a PLDA model (our classifier)
```
$train_cmd exp/ivector_train_1024/log/plda.log \
  ivector-compute-plda ark:data/train/spk2utt \
  'ark:ivector-normalize-length scp:exp/ivector_train_1024/ivector.scp  ark:- |' \
  exp/ivector_train_1024/plda
```

### Extract i-vectors from our test set
```
sid/extract_ivectors.sh --cmd "$train_cmd" --nj $nj \
  exp/extractor_1024 data/test/enroll  exp/ivector_enroll_1024
```
### Evaluate model with EER
```
#compute plda score
$train_cmd exp/ivector_eval_1024/log/plda_score.log \
  ivector-plda-scoring --num-utts=ark:exp/ivector_enroll_1024/num_utts.ark \
  exp/ivector_train_1024/plda \
  ark:exp/ivector_enroll_1024/spk_ivector.ark \
  "ark:ivector-normalize-length scp:exp/ivector_eval_1024/ivector.scp ark:- |" \
  "cat '$trials' | awk '{print \\\$2, \\\$1}' |" exp/trials_out
#compute EER score
awk '{print $3}' exp/trials_out | paste - $trials | awk '{print $1, $4}' | compute-eer -
```
#### Get results
```LOG (compute-eer[5.5.888~1-d619]:main():compute-eer.cc:136) Equal error rate is 26.8414%, at threshold -1.32142```
- Results when only using the TORGO dataset for training/testing
