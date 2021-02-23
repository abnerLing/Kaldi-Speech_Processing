## Installation
Useful source for installing Kaldi:
- http://jrmeyer.github.io/asr/2016/01/26/Installing-Kaldi.html
- http://kaldi-asr.org/doc/install.html
### Clone Kaldi repository
 ```
git clone https://github.com/kaldi-asr/kaldi.git

Cloning into 'kaldi'...
remote: Enumerating objects: 113197, done.
remote: Total 113197 (delta 0), reused 0 (delta 0), pack-reused 113197
Receiving objects: 100% (113197/113197), 120.97 MiB | 15.29 MiB/s, done.
Resolving deltas: 100% (87455/87455), done. 
```

### Check for any required libraries/dependencies
```
cd ./kaldi/tools
./extras/check_dependencies.sh

./kaldi/tools/extras/check_dependencies.sh: WARNING python 2.7 is not the default python. We fixed this by adding a correct symlink more prominently on the path.
 ... If you really want to use python 3.6.12 as default, add an empty file /home/abner/python/.use_default_python and run this script again.
./kaldi/tools/extras/check_dependencies.sh: all OK.
```
- If you get the "all OK." message, then you can continue

```
make -j N # change N if you want to ue multiple processors (recommended)
...
...
All done OK.
make: Leaving directory '/home/abner/kaldi/tools'
```
- If you get the "All done OK." message, then you can continue

```
cd ../src
./configure
```
```
Kaldi has been successfully configured. To compile:

  make -j clean depend; make -j <NCPU>

where <NCPU> is the number of parallel builds you can afford to do. If unsure,
use the smaller of the number of CPUs or the amount of RAM in GB divided by 2,
to stay within safe limits. 'make -j' without the numeric value may not limit
the number of parallel jobs at all, and overwhelm even a powerful workstation,
since Kaldi build is highly parallelized.
  ```
```  
make -j clean depend; make -j <NCPU>
```

## To check if everything is installed correctly run the below script for the yesno data
- This is a very small dataset and lets us check if Kaldi compiled correctly.
- The run script will do the following:
    - Download the data
    - Extract mfcc's
    - Train a simple 1-gram language model
    - Train a monophone gmm-hmm acoustic model
    - Decode and score the acoustic model.
- Since the dataset is simple, you should obtain a wer of 0.00%

```
cd ./kaldi/egs/yesno/s5/
./run.sh

..
...
local/score.sh --cmd utils/run.pl data/test_yesno exp/mono0a/graph_tgpr exp/mono0a/decode_test_yesno
local/score.sh: scoring with word insertion penalty=0.0,0.5,1.0
%WER 0.00 [ 0 / 232, 0 ins, 0 del, 0 sub ] exp/mono0a/decode_test_yesno/wer_10_0.0
```
- If you reached here with no problems, you should have a working installation of Kaldi.
### Other required installations for this exercise
```
# For language model building
./kaldi/tools/.install_srilm.sh

# For obtaining pronuciations of out-of-vocabulary words from CMU-dict trained G2P model
./kaldi/tools/extras/install_sequitur.sh
```

## After installing Kaldi go the egs folder and clone this repository
```
cd ./kaldi/egs/ && git clone https://github.com/abnerLing/TORGO-ASR.git
```

