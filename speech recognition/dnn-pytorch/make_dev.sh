#!/usr/bin/env bash

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail


ndev_utt=154

. utils/parse_options.sh

if [ $# -ne 0 ]; then
    log "Error: No positional arguments are required."
    exit 2
fi

. ./path.sh
. ./cmd.sh

train_set="train_nodev"
train_dev="dev"


# shuffle whole training set
utils/shuffle_list.pl data/train/utt2spk > utt2spk.tmp

# make a dev set
head -${ndev_utt} utt2spk.tmp | \
utils/subset_data_dir.sh --utt-list - data/train "data/${train_dev}"

# make a traing set
n=$(($(wc -l < data/train/text) - ndev_utt))
tail -${n} utt2spk.tmp | \
utils/subset_data_dir.sh --utt-list - data/train "data/${train_set}"

rm -f utt2spk.tmp
