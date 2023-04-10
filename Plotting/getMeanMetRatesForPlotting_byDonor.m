%{ 
Copyright (C) 2023  N. Suhas Jagannathan
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

% This file uses the data of the form output via optScript_metRates.m
% (pooled across donors/runs) and computes the mean and standard deviation
% for each time point.
 
function [plot_data_mean, plot_data_std] = getMeanMetRatesForPlotting_byDonor(opt_data, num_reps)

opt_data_mat = cell2mat(opt_data(:,[1 2 3 5 6 7]));
unique_opt_data_runs = unique(opt_data_mat(:,1));
num_runs = size(unique_opt_data_runs,1);
num_times = max(opt_data_mat(:,3));

opt_data_min_e = [];
for i = 1:num_reps:size(opt_data_mat,1)
    tmp = opt_data_mat(i:(i+num_reps-1),:);   
    opt_data_min_e = [opt_data_min_e; tmp(tmp(:,6) == min(tmp(:,6)),:)];
end

plot_data_mean = zeros(num_runs,num_times);
plot_data_std = plot_data_mean;

for i = 1:num_runs
    run_id = unique_opt_data_runs(i);
    
    for j = 1:num_times
        opt_ind = find(opt_data_min_e(:,1) == run_id & opt_data_min_e(:,3)==j);
        plot_data_mean(i,j) = mean(opt_data_min_e(opt_ind,5));
        plot_data_std(i,j) = std(opt_data_min_e(opt_ind,5));
    end
end