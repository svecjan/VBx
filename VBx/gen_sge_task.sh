
TASK=$1 #nocat

# for f in $PWD/xvec_lst/voxceleb2_dev.nocat.lst.*; do
for f in $PWD/xvec_lst/voxceleb2_dev.${TASK}.lst.*; do
echo "source /mnt/matylda3/isvecjan/miniconda3/bin/activate /mnt/matylda3/isvecjan/miniconda3/envs/VBx; \
python $PWD/VBx/predict.e1.py \
  --in-raw-dir /mnt/matylda4/glembek/data/raw16/voxceleb2 \
  --in-file-list ${f} \
  --out-xvec-dir ${PWD}/xvec_out \
  --weights VBx/models/ResNet101_16kHz/nnet/raw_81.pth \
  --backend pytorch \
  --model ResNet101 \
  --task ${TASK}"
done