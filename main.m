% main_batch

clear; clc; close all;

addpath(genpath('functions'));
addpath(genpath('data'));

cover_dir = 'data/PSB_cover_norm';
stego_dir = 'data/PSB_stego';

%% extract features
fprintf('Extract features...\n');

meshes = dir(cover_dir);
meshnum = length(meshes)-2;

j = str2num(getenv('SLURM_CPUS_PER_TASK'));
parpool(j)
parfor_progress(meshnum*2);


fea_d = 36;

F = zeros(meshnum, fea_d);
parfor i = 1:meshnum
    name = meshes(i+2).name;
    cover_mesh = [cover_dir,'/',name];
    F(i, :) = nvt36_fea(cover_mesh);
    parfor_progress;
end

for i = 1:meshnum
    names{i, 1} = num2str(i);
end

cover_pathfea = 'data/cover.mat';
save(cover_pathfea, 'names', 'F');

F = zeros(meshnum, fea_d);
parfor i = 1:meshnum
    name = meshes(i+2).name;
    stego_mesh = [stego_dir,'/',name];
    F(i, :) = nvt36_fea(stego_mesh);
    parfor_progress;
end

stego_pathfea = 'data/stego.mat';
save(stego_pathfea, 'names', 'F');

poolobj = gcp('nocreate');
delete(poolobj);

parfor_progress(0);

%% conduct classification
fprintf('Conduct classification...\n');

num_train = 260;
ensemble_classifier(cover_pathfea, stego_pathfea, num_train);
