# Part 2 Data Preparation
### We will use the TORGO Database from the University of Toronto
- http://www.cs.toronto.edu/~complingweb/data/TORGO/torgo.html
- Speech from patients with **Cerebral Palsy** or **Amyotrophic Lateral Sclerosis**.
- 4 sets of data available for free totalling 18GB (uncompressed).

&nbsp;
**Dataset**
- F.tar.bz2. Females (F01, F03, F04) with dysarthria.
- FC.tar.bz2. Female controls (FC01, FC02, FC03) without dysarthria.
- M.tar.bz2. Males (M01, M02, M03, M04, M05) with dysarthria.
- MC.tar.bz2. Male controls (MC01, MC02, MC03, MC04) without dysarthria.

### Extract data into some directory
- eg. ```tar -xf FC.tar.bz2```
- There should be 15 speakers; 7 females, 8 males. 
```
abner@ubuntu:/data/TORGO$ tree -L 1
.
├── F01
├── F03
├── F04
├── FC01
├── FC02
├── FC03
├── FC.tar.bz2
├── F.tar.bz2
├── M01
├── M02
├── M03
├── M04
├── M05
├── MC01
├── MC02
├── MC03
├── MC04
├── MC.tar.bz2
└── M.tar.bz2
```

### Renaming files
- The current status of the data is not organized neatly.
- We should rename all the audio files for better consistency.
- Currently all files are labeled with numbers not unique to the speaker or session, but Kaldi requires unique naming for all audio files.
```
# eg. OLD 
abner@ubuntu:/data/TORGO/M01$ tree
.
├── Session1
│   ├── wav_arrayMic
│   │   ├── 0001.wav
│   │   ├── 0002.wav
│   │   ├── ....
│   └── wav_headMic
│       ├── 0001.wav
│       ├── 0002.wav
│       ├── ...
├── Session2
│   ├── wav_arrayMic
│   │   ├── 0001.wav
│   │   ├── 0002.wav
│   │   ├── ....
│   └── wav_headMic
│       ├── 0001.wav
│       ├── 0002.wav
│       ├── ...


# eg. NEW
abner@ubuntu:/data/TORGO/M01$ tree

.
├── Session1
│   ├── wav_arrayMic
│   │   ├── M01_1_array_0001.wav
│   │   ├── M01_1_array_0002.wav
│   │   ├── ....
│   └── wav_headMic
│       ├── M01_1_head_0001.wav
│       ├── M01_1_head_0002.wav
│       ├── ...
├── Session2
│   ├── wav_arrayMic
│   │   ├── M01_2_array_0001.wav
│   │   ├── M01_2_array_0002.wav
│   │   ├── ....
│   └── wav_headMic
│       ├── M01_2_head_0001.wav
│       ├── M01_2_head_0002.wav
│       ├── ...

# Files are now labeled as "SpeakerID_session#_mictype_filename.wav"
```

#### Current audio file names
```ls /data2/TORGO/M01/Session1/wav_arrayMic/ # Change to your directory```
```
0001.wav  0014.wav  0027.wav  0040.wav	0053.wav  0066.wav  0079.wav  0092.wav
0002.wav  0015.wav  0028.wav  0041.wav	0054.wav  0067.wav  0080.wav  0093.wav
0003.wav  0016.wav  0029.wav  0042.wav	0055.wav  0068.wav  0081.wav  0094.wav
```

#### New audio file names
```ls /data2/TORGO/M01/Session1/wav_arrayMic/ # Change to your directory ```
```
M01_1_array_0001.wav  M01_1_array_0035.wav  M01_1_array_0069.wav
M01_1_array_0002.wav  M01_1_array_0036.wav  M01_1_array_0070.wav
M01_1_array_0003.wav  M01_1_array_0037.wav  M01_1_array_0071.wav
```

### We will train our GMM-HMM acoustic model with all but one speaker (speaker - F03)
- The one speaker left out will be used to evaluate our model.
- The speaker has moderate dysarthria.

### Kaldi requires 4 main files that need to be created by us
1. wav.scp
2. utt2spk
3. text
4. spk2utt 

#### 1. wav.scp
- This is a file containing the file location for each audio file
- One utterance per line
- file name \<space> file location
- eg: <br/>
```
F01_1_array_0006 /data2/TORGO/F01/Session1/wav_arrayMic/F01_1_array_0006.wav
F01_1_array_0007 /data2/TORGO/F01/Session1/wav_arrayMic/F01_1_array_0007.wav
F01_1_array_0008 /data2/TORGO/F01/Session1/wav_arrayMic/F01_1_array_0008.wav
F01_1_array_0009 /data2/TORGO/F01/Session1/wav_arrayMic/F01_1_array_0009.wav
...
```
#### 2. utt2spk
- A file containing the speaker ID for each utterance
- One utterance per line
- file name \<space> speaker ID
- eg: <br/>
```
F01_1_array_0006 F01 
F01_1_array_0007 F01
F01_1_array_0008 F01
MC04_2_array_1016 MC04 
MC04_2_array_1017 MC04 
MC04_2_array_1018 MC04 
...
```

#### 3. text
- Transcriptions for each utterance 
- One utterance per line
- file name \<space> transcription
- eg: <br/> 
```
F01_1_array_0008 EXCEPT IN THE WINTER WHEN THE OOZE OR SNOW OR ICE PREVENTS 
F01_1_array_0009 PAT
F01_1_array_0010 UP 
F01_1_array_0013 KNOW 
F01_1_array_0014 HE SLOWLY TAKES A SHORT WALK IN THE OPEN AIR EACH DAY 
MC04_2_array_1019 UPGRADE YOUR STATUS TO REFLECT YOUR WEALTH
MC04_2_array_1021 EAT YOUR RAISINS OUTDOORS ON THE PORCH STEPS 
MC04_2_array_1023 THE FAMILY REQUESTS THAT FLOWERS BE OMITTED 
...
```
#### 4. spk2utt
- All utterances for each speaker
- One speaker per line
- speaker ID \<space> utterance
- can be created with kaldi provided script (eg. utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt) <br/>
- eg: <br/>
```
M05 M05_1_array_0005 M05_1_array_0006 M05_1_array_0007 M05_1_array_0008 M05_1_array_0009 ... ... ...
```
### All files except text and wav.scp have been provided.  
- Create wav.scp after renaming all audio files and use the other provided files as a reference.
- Create text file with punctuation removed and capitalize all words.

### Once your data directory looks like below, we can start [training](https://github.com/abnerLing/Kaldi-Speech_Processing/tree/main/speech%20recognition)
```
(base) abner@ubuntu:~/kaldi/egs/torgo/data$ tree -L 2
.
├── test
│   ├── spk2utt
│   ├── text
│   ├── utt2spk
│   └── wav.scp
└── train
    ├── spk2utt
    ├── text
    ├── utt2spk
    └── wav.scp
```
