![alt text](kaldi.png "Title")
# TORGO-ASR
## Tutorial on using Kaldi for Dysarthric Speech Recognition.
### The data used is provided by the University of Toronto for free. 
- http://www.cs.toronto.edu/~complingweb/data/TORGO/torgo.html
- Speakers have speech impairments due to **Cerebral Palsy** or **Amyotrophic Lateral Sclerosis**.

### Goals of this excercise 
1. Build a kaldi-based GMM-HMM acoustic model for speech recognition.
2. Improve the recognition accuracy for impaired speech (data augmentation, hyperparameter tuning, etc.) 
3. Train a DNN-HMM acoustic model using the alignments from the GMM-HMM model. 
4. Perform speaker identification/recognition via x-vectors.


### Sections
- Part 1: [Installation](https://github.com/abnerLing/TORGO-ASR/tree/main/installation)
- Part 2: [Data Preparation](https://github.com/abnerLing/TORGO-ASR/tree/main/data%20prep)
- Part 3: [Training & Evaluation](https://github.com/abnerLing/TORGO-ASR/tree/main/training-evaluation)
- Part 4: Speaker Recognition 
