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
- rename.py
```
import os

mydir = "/data2/TORGO/" # change to your TORGO directory location

for subdir, dirs, files in os.walk(mydir):
    for file in files:
        filepath = subdir + os.sep + file
        
        if filepath.endswith(".wav"):
            name = filepath.split('/')
            ID = name[-4]
            SESS = name[-3][-1]
            MIC = name[-2].split('_')[1][:-3]
            WAV = name[-1] 
            
            new_name = ID + '_' + SESS + '_' + MIC + '_' + WAV
            #print(new_name)
            new_filepath = subdir + os.sep + new_name
            os.rename(filepath, new_filepath)
```
#### New audio file names
```ls /data2/TORGO/M01/Session1/wav_arrayMic/ # Change to your directory ```
```
M01_1_array_0001.wav  M01_1_array_0035.wav  M01_1_array_0069.wav
M01_1_array_0002.wav  M01_1_array_0036.wav  M01_1_array_0070.wav
M01_1_array_0003.wav  M01_1_array_0037.wav  M01_1_array_0071.wav
```
