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

% This script is the outermost wrapper for computing daily metabolic
% consumption/production rates. The script uses data from the
% microbioreactor and daily metabolic measurements (cedex) to run an
% optimizer using the simulannealbnd function (simulated annealing)

clear; clc;
simulOptions = optimoptions(@simulannealbnd,'AnnealingFcn','annealingboltz','InitialTemperature',200, 'TemperatureFcn','temperatureboltz');
load load erbi_data_eqns.mat
load Cedex_data.mat

%%
lb = 0;
ub = 2;
run_id = 1;
run_info = cell2mat(erbi_data_all_t(:,1));
runs_to_use = find(run_info==run_id);
data = erbi_data_all_t(runs_to_use,:);
fit_eqns_data = fit_eqns_var(runs_to_use,:);
met_to_use = 'GLU';  % GLC = glucose, LAC = lactate, GLN = glutamine, GLU = glutamate
met_ind = find(ismember(cedex_mets,met_to_use)); 

res_var = {};
j = 0;
var_pref = ['opt_',lower(met_to_use),'_',num2str(run_id)];
filename = [var_pref,'.mat'];
%%
datetime
tic;
for i = 1:size(data,1)
    data_run = data{i,3};
    data_run(:,2) = movmean(data_run(:,2),21);
    fit_eqns_prctile = getEqnsWithinPrctile(fit_eqns_data{i,5}, fit_eqns_data{i,6}, 25, 75);
    rand_perm_order = randperm(size(fit_eqns_prctile,1));
    fit_eqns_rand_sorted = fit_eqns_prctile(rand_perm_order,:);
    cedex_data = cedex.data{i,met_ind};
    c_times = squeeze(c_meas_erbi_times(:,:,i));
    run = fit_eqns_data{i,1};
    pod = fit_eqns_data{i,2};
    
    c_t = zeros(11,2);
    data_subset_withCellnum = cell(11,1);
    for j = 1:(length(cedex_data)-1)
        t_start = c_times(j,2);
        t_end = c_times((j+1),2);
        ind = find(data_run(:,1)> t_start & data_run(:,1) < t_end);
        data_subset = data_run(ind,:);
        data_subset(:,1) = data_subset(:,1) - t_start;
        data_subset_withCellnum{j} = data_subset;
        c_t(j,:) = c_times((j+1),:) - t_start;
    end
    
    for rand_eq = 1:50
        fit_eqn_rand = fit_eqns_rand_sorted(rand_eq,:);
        toWrite = [i rand_eq];
        fid = fopen('log.txt', 'a+');
        fprintf(fid, '%d %d\n', toWrite);
        fclose(fid);
        
        parfor j = 1:length(cedex_data)-1
            data_for_opt = data_subset_withCellnum{j};
            cellnum_pred = getCellNumFromOD(data_for_opt(:,2),fit_eqn_rand);
            data_for_opt = [data_for_opt cellnum_pred];
            
            for k = 1:5
                p0 = rand;
                [p_opt,fval] = simulannealbnd(@(p)objMetRates(p, data_for_opt,cedex_data(j:(j+1)),c_t(j,:)),p0,lb,ub);
                tmp = cell(1,7);
                tmp{1,1} = run;
                tmp{1,2} = pod;
                tmp{1,3} = j;
                tmp{1,4} = fit_eqn_rand;
                tmp{1,5} = p0;
                tmp{1,6} = p_opt;
                tmp{1,7} = fval;
                
                res_var = [res_var; tmp];
            end
        end
    end
    
    eval([var_pref,' = res_var;']);
    eval('save(filename,var_pref)');
    
end
toc
datetime

eval([var_pref,' = res_var;']);
eval('save(filename,var_pref)');

