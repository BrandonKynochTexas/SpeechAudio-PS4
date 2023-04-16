\#!/usr/bin/env bash

data=/lusr/opt/kaldi/kaldi-master/egs/mini_librispeech/s5/corpus/
data_url=www.openslr.org/resources/31
lm_url=www.openslr.org/resources/11

. ./cmd.sh
. ./path.sh

stage=0
. utils/parse_options.sh

set -euo pipefail

if [ $stage -le 0 ]; then
  local/download_lm.sh $lm_url $data data/local/lm
fi

if [ $stage -le 1 ]; then
  # format the data as Kaldi data directories
  for part in dev-clean-2 train-clean-5; do
    # use underscore-separated names in data directories.
    local/data_prep.sh $data/LibriSpeech/$part data/$(echo $part | sed s/-/_/g)
  done

  local/prepare_dict.sh --stage 3 --nj 30 --cmd "$train_cmd" \
    data/local/lm data/local/lm data/local/dict_nosp

  utils/prepare_lang.sh data/local/dict_nosp \
    "<UNK>" data/local/lang_tmp_nosp data/lang_nosp

  local/format_lms.sh --src-dir data/lang_nosp data/local/lm
fi

if [ $stage -le 2 ]; then
  mfccdir=mfcc
  # TODO: extract MFCCs for train and test data
fi

# train a monophone system
if [ $stage -le 3 ]; then
  utils/subset_data_dir.sh --shortest data/train_clean_5 500 data/train_500short
  # TODO: train a monophone acoustic model
fi

# train a delta + delta-delta triphone system on all utterances
if [ $stage -le 4 ]; then
    # TODO: 1) force-align the entire training set with the monophone model
    # TODO: 2) train the triphone model on the entire training set
fi

if [ $stage -le 5 ]; then
    # TODO: 1) build the decoding graph
    # TODO: 2) decode using the triphone model
    # TODO: 3) rescore with the larger (tgmed) language model
fi
