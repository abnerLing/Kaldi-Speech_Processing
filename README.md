![alt text](kaldi.png "Title")
# Speech Processing with TORGO dataset
## Tutorial on using Kaldi for Dysarthric Speech Recognition and Speaker Recognition.
### The data used is provided by the University of Toronto for free. 
- http://www.cs.toronto.edu/~complingweb/data/TORGO/torgo.html
- Speakers have speech impairments due to **Cerebral Palsy** or **Amyotrophic Lateral Sclerosis**.

### Goals of this excercise 
1. Build a kaldi-based GMM-HMM acoustic model for speech recognition.
2. Improve the recognition accuracy for impaired speech (data augmentation, hyperparameter tuning, etc.) 
3. Train a DNN-HMM acoustic model using the alignments from the GMM-HMM model. 
4. Perform speaker identification/recognition via i-vectors and improve baseline results.


### Sections
- Part 1: [Installation](https://github.com/abnerLing/TORGO-ASR/tree/main/installation)
- Part 2: [Data Preparation](https://github.com/abnerLing/TORGO-ASR/tree/main/data%20prep)
- Part 3: [Speech Recognition (acoustic and Language model training)](https://github.com/abnerLing/TORGO-ASR/tree/main/speech%20recognition)
  - [GMM-HMM acoustic model](https://github.com/abnerLing/TORGO-ASR/tree/main/speech%20recognition#stage-3-acoustic-model-training)
  - [DNN-HMM acoustic model](https://github.com/abnerLing/TORGO-ASR/tree/main/speech%20recognition/DNN)
- Part 4: [Speaker Recognition (using i-vectors)](https://github.com/abnerLing/TORGO-ASR/tree/main/speaker%20recognition)


### Section Details
- Part 1 **Installation**
  - Kaldi 
  - The SRI Language Modeling Toolkit
  - Sequitur Grapheme-to-Phoneme converter
  - Intel MKL (Math Kernel Library)
- Part 2 **Data Preparation**
  - Audio data download
  - Files that need to be created by us
  - Kaldi directory structure
- Part 3 **Speech Recognition**
  - N-gram language model building
  - MFCC extraction + CMVN (cepstral mean and variance normalization)
  - **GMM-HMM training**
     - Monophone training
     - Triphone training
      - Delta + delta-delta training computes dynamic coefficients to supplement the MFCC features.
      - Linear Discriminant Analysis – Maximum Likelihood Linear Transform (LDA-MLLT to reduce feature space)
      - Speaker Adaptive Training (SAT performs speaker and noise normalization) 
    - Alignment with Feature Space Maximum Likelihood Linear Regression (fmllr features are speaker-normalized features)
  - **DNN-based acoustic model**
    - Use GMM-HMM generated alignments to train a deep neural network acoustic model
    - Restricted Boltzmann Machine (RBM) pre-training
    - Frame cross-entropy training
    - Sequence-training optimizing state-level minimum Bayes risk (sMBR)
   
- Part 4 **Speaker Recognition** (or identification)
  - MFCC feature extraction
  - Voice Activity detection (compute energy based VAD output)
  - Train Gaussian Mixture Model - Universal Background Model (GMM-UBM)
  - Train ivector extractor
  - Extract ivector from audio files
  - Train a Probabilistic Linear Discriminant Analysis (PLDA) model
  - Compute PLDA score (Equal Error Rate)
