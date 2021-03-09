# Kaldi for Dysarthic Speech Recognition
- **Part 3: Speech Recognition**
- GMM-based acoustic model training

### The general work-flow is as follows:
1. Prepare data
2. Build n-gram language model 
3. Extract acoustic features (MFCC, Fbank, etc)
4. Train a monophone acoustic model (context independent)
5. Train a triphone acoustic model (context depedent) 
6. Decode and evaluate AM via word-error rate

### All the above steps will be written in a 'run.sh' recipe which runs kaldi-provided scripts
- The provided run script is divided into 4 stages (language model building, feature extraction, acoustic model training, and decoding)
- Also, run the below commands to soft link required folders for feature extraction, training, etc.
 ```
 ln -s kaldi/egs/wsj/s5/utils
 ln -s kaldi/egs/wsj/s5/steps
 ```   

#### Example code from run.sh

- Building language model
```
echo
echo "===== PREPARING Language DATA ====="
echo
 
# Prepare ARPA LM and vocabulary using SRILM
local/torgo_prepare_lm.sh --order ${lm_order} || exit 1

# Prepare the lexicon and various phone lists
# Pronunciations for OOV words are obtained using a pre-trained Sequitur model
local/torgo_prepare_dict.sh || exit 1
echo ""
echo "=== Preparing data/lang and data/local/lang directories ..."
echo ""

utils/prepare_lang.sh --position-dependent-phones $pos_dep_phones \
        data/local/dict '!SIL' data/local/lang data/lang || exit 1

# Prepare G.fst and data/{train,test} directories
local/torgo_prepare_grammar.sh "test" || exit 1
```
- Extracting MFCC's
```
# Extract MFCC
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
steps/make_mfcc.sh --nj 1 --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir

# Making cmvn.scp files (cepstral mean and variance normalization)
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir
```

- Training acoustic model (monophone and triphone)
```
 steps/train_mono.sh --nj $nj --cmd "$train_cmd" --cmvn-opts "$cmvn_opts" \
         $data_dir/train $lang $exp_dir/train/mono
 steps/align_si.sh --nj $nj --cmd "$train_cmd" \
         $data_dir/train $lang $exp_dir/train/mono $exp_dir/train/mono_ali
 steps/train_deltas.sh --cmd "$train_cmd" --cmvn-opts "$cmvn_opts" \
         $Leaves $Gauss $data_dir/train $lang $exp_dir/train/mono_ali $exp_dir/train/tri1
 steps/align_si.sh --nj $nj --cmd "$train_cmd" \
         $data_dir/train $lang $exp_dir/train/tri1 $exp_dir/train/tri1_ali
 steps/train_deltas.sh --cmd "$train_cmd" --cmvn-opts "$cmvn_opts" \
         $Leaves $Gauss $data_dir/train $lang $exp_dir/train/tri1_ali $exp_dir/train/tri2
 steps/align_si.sh --nj $nj --cmd "$train_cmd" \
         $data_dir/train $lang $exp_dir/train/tri2 $exp_dir/train/tri2_ali
 steps/train_lda_mllt.sh --cmd "$train_cmd" --cmvn-opts "$cmvn_opts" \
         $Leaves $Gauss $data_dir/train $lang $exp_dir/train/tri2_ali $exp_dir/train/tri3
 steps/align_si.sh --nj $nj --cmd "$train_cmd" \
         $data_dir/train $lang $exp_dir/train/tri3 $exp_dir/train/tri3_ali
 steps/train_sat.sh --cmd "$train_cmd" \
         $Leaves $Gauss $data_dir/train $lang $exp_dir/train/tri3_ali $exp_dir/train/tri4
 steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
         $data_dir/train $lang $exp_dir/train/tri4 $exp_dir/train/tri4_ali
```
- Decoding and scoring AM
```
# decode
utils/mkgraph.sh $lang_test $exp_dir/train/tri4 $exp_dir/train/tri4/graph
steps/decode_fmllr.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd"  --num-threads $thread_nj --scoring_opts "$scoring_opts" \
        $exp_dir/train/tri4/graph $data_dir/test $exp_dir/train/tri4/decode_test
```


#### Stage 1: Languge model preparation

./run.sh (stage 1)
```
===== PREPARING Language DATA =====


=== Building a language model ...

=== Preparing the dictionary ...

--- Downloading CMU dictionary ...
A    data/local/dict/cmudict/scripts

=== Preparing the grammar transducer (G.fst) for testing ...

arpa2fst - 
LOG (arpa2fst[5.5.888~1-d619]:Read():arpa-file-parser.cc:94) Reading \data\ section.
LOG (arpa2fst[5.5.888~1-d619]:Read():arpa-file-parser.cc:149) Reading \1-grams: section.
LOG (arpa2fst[5.5.888~1-d619]:Read():arpa-file-parser.cc:149) Reading \2-grams: section.
remove_oovs.pl: removed 2 lines.
fstisstochastic data/lang_test/G.fst 
0.692776 -0.315091
```

#### Stage 2: MFCC feature extraction

./run.sh (stage 2)
```
steps/make_mfcc.sh: [info]: no segments file exists: assuming wav.scp indexed by utterance.
steps/make_mfcc.sh: Succeeded creating MFCC features for test
steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train mfcc
Succeeded creating CMVN stats for train
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test mfcc
Succeeded creating CMVN stats for test
```

#### Stage 3: Acoustic model training

./run.sh (stage 3)
```
steps/train_mono.sh: Initializing monophone system.
steps/train_mono.sh: Compiling training graphs
steps/train_mono.sh: Aligning data equally (pass 0)
steps/train_mono.sh: Pass 1
steps/train_mono.sh: Aligning data
steps/train_mono.sh: Pass 2
steps/train_mono.sh: Aligning data
...
...
steps/align_fmllr.sh: computing fMLLR transforms
steps/align_fmllr.sh: doing final alignment.
steps/align_fmllr.sh: done aligning data.
steps/diagnostic/analyze_alignments.sh --cmd run.pl /home/abner/kaldi/egs/torgo/data/lang /home/abner/kaldi/egs/torgo/exp/train/tri4_ali
steps/diagnostic/analyze_alignments.sh: see stats in /home/abner/kaldi/egs/torgo/exp/train/tri4_ali/log/analyze_alignments.log
```

#### Stage 4: Decoding and scoring

./run.sh (stage 4)
```
steps/decode_fmllr.sh: feature type is lda
steps/decode_fmllr.sh: getting first-pass fMLLR transforms.
steps/decode_fmllr.sh: doing main lattice generation phase
steps/decode_fmllr.sh: estimating fMLLR transforms a second time.
steps/decode_fmllr.sh: doing a final pass of acoustic rescoring.
```
cat /home/abner/kaldi/egs/torgo/exp/train/tri4/decode_test/scoring_kaldi/best_wer
```
%WER 39.12 [ 1089 / 2784, 279 ins, 112 del, 698 sub ] /home/abner/kaldi/egs/torgo/exp/train/tri4/decode_test/wer_17_0.0
```

#### Our model has a WER of 39.12%





### The next step is to improve the recognition accuracy and lower the WER as much as possible
Things to consider: <br/>
- Data augmentation
    - See [speed perturbation](https://github.com/kaldi-asr/kaldi/blob/master/egs/wsj/s5/utils/data/perturb_data_dir_speed_3way.sh)
    - Recommended articles [[1]](https://188.166.204.102/archive/Interspeech_2018/pdfs/1751.pdf), [[2]](https://ieeexplore.ieee.org/abstract/document/8683091), [[3]](https://ieeexplore.ieee.org/abstract/document/8462290), [[4]](https://isca-speech.org/archive/Interspeech_2020/pdfs/1161.pdf)
- Increasing data size?
    - See [UASpeech database](http://www.isle.illinois.edu/sst/data/UASpeech/) (speech database with dysarthric speakers)
    - [Librispeech](https://www.openslr.org/12) (large 1000 hour corpus)
- Adjusting Kaldi's internal default parameters
    - See [Improving Acoustic Models in TORGO Dysarthric Speech Database](https://ieeexplore.ieee.org/abstract/document/8283503)
    - eg. mfcc dimensions, decode beam size, etc.

```
[1] Vachhani, B., Bhat, C., & Kopparapu, S. K. (2018, September). Data Augmentation Using Healthy Speech for Dysarthric Speech Recognition. In Interspeech (pp. 471-475).
[2] Xiong, F., Barker, J., & Christensen, H. (2019, May). Phonetic analysis of dysarthric speech tempo and applications to robust personalised dysarthric speech recognition. In ICASSP 2019-2019 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP) (pp. 5836-5840). IEEE.
[3] Jiao, Y., Tu, M., Berisha, V., & Liss, J. (2018, April). Simulating dysarthric speech for training data augmentation in clinical speech applications. In 2018 IEEE international conference on acoustics, speech and signal processing (ICASSP) (pp. 6009-6013). IEEE.
[4] Geng, M., Xie, X., Liu, S., Yu, J., Hu, S., Liu, X., Meng, H. (2020) Investigation of Data Augmentation Techniques for Disordered Speech Recognition. Proc. Interspeech 2020, 696-700.
```


