#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import h5py
import numpy as np


if __name__ == '__main__':
    # xvec_lst_filename = sys.argv[1]
    # h5py_file = sys.argv[2]

    # xvec_mat = []
    # names = []
    # physicals = []
    # with open(xvec_lst_filename) as f:
    #     for i, line in enumerate(f):
    #         sl = line.strip().split()

    #         xvec_mat.append(np.array([float(x) for x in sl[1:-1]]))
    #         names.append(sl[0])
    #         physicals.append(sl[-1])

    #         if i % 100000 == 0:
    #             print(f"Processed {i}")

    # xvec_mat = np.array(xvec_mat)

    # with h5py.File(h5py_file, 'w') as f:
    #     dt = h5py.special_dtype(vlen=str)
    #     f.create_dataset('Data', xvec_mat.shape, dtype=np.float64)
    #     f.create_dataset('Name', (len(names),), dtype=dt)
    #     f.create_dataset('Physical', (len(physicals),), dtype=dt)

    #     f['Data'][:, :] = xvec_mat
    #     for i, (n, p) in enumerate(zip(names, physicals)):
    #         f['Name'][i] = names[i]
    #         f['Physical'][i] = physicals[i]

    h5py_file = sys.argv[1]
    with h5py.File(h5py_file) as f:
        print(f["Data"])












    # with h5py.File(args.save, 'w') as fd_h5:
    #     dt = h5py.special_dtype(vlen=str)
    #     fd_h5.create_dataset('labels', (len(args.languages),), dtype=dt)
    #     for i, lang in enumerate(args.languages):
    #         fd_h5['labels'][i] = lang
    #     #     fd_h5.create_dataset(lang, means[lang].shape, dtype=np.float64)
    #     #     fd_h5[lang][:] = means[lang]

    #     fd_h5.create_dataset('means', means.shape, dtype=np.float64)
    #     fd_h5['means'][:, :] = means
    #     fd_h5.create_dataset('cov', cov.shape, dtype=np.float64)
    #     fd_h5['cov'][:, :] = cov
