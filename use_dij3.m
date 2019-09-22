clear;
clc;

s = 0;
gap = 0.1;
eend = 1

path_cell = cell(1,(eend-s)/gap);
jump_m = [];
length_m = [];
rate_m = [];

k = 1;
for i = s:gap:eend
    [new_path,jump_m(k),length_m(k),rate_m(k)] = dij3(i);
    path_cell{k} = new_path;
    k = k + 1;
end