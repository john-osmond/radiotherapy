[leavesout m xc] = leafmatch(img, squeeze(jaws(segment,:,:)), squeeze(leaves(segment,:,:)), 'n', 'n');
[leavesout m yc] = leafcomp(squeeze(leaves(segment,:,:)), leavesout, 'n', 'n');
leavesout(16:25,5:6)
sqrt(mean(mean(leavesout(16:25,5:6).^2)))