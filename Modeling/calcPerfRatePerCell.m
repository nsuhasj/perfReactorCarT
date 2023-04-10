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

% This script estimates the perfusion rate per cell (in picoliters/day) 
% over the reactor running time.

%%
clear; clc;
load erbi_data_eqns.mat %data file containing microbioreactor data obtained using getErbiData.m and family of fit equation obtained from using getCellNumODFit_withVar.m

data = erbi_data_all_t;
fit_eqns_data = fit_eqns_var;

var_pref = ['perfRate_per_cell'];
filename = [var_pref,'.mat'];
res_var = {};

%%
datetime
tic;
cellnum_pred_all = zeros(2581,50);
for i = 1:size(data,1)
    data_run = data{i,3};
    cleaned_data_run = data_run;
    cleaned_data_run(cleaned_data_run(:,2)==0,:) = [];
    cleaned_data_run(:,2) = movmean(cleaned_data_run(:,2),21);
    t_od_perf_data = [];
    t_od_perf_data(:,1) = 24:0.1:282;
    t_od_perf_data(:,2) = interp1(cleaned_data_run(1:2:end,1),cleaned_data_run(1:2:end,2),t_od_perf_data(:,1));
    t_od_perf_data(:,3) = interp1(cleaned_data_run(1:2:end,1),cleaned_data_run(1:2:end,6),t_od_perf_data(:,1));
    
    fit_eqns_prctile = getEqnsWithinPrctile(fit_eqns_data{i,5}, fit_eqns_data{i,6}, 25, 75);
    rand_perm_order = randperm(size(fit_eqns_prctile,1));
    fit_eqns_rand_sorted = fit_eqns_prctile(rand_perm_order,:);
    run = fit_eqns_data{i,1};
    pod = fit_eqns_data{i,2};
    
    for rand_eq = 1:50
        fit_eqn_rand = fit_eqns_rand_sorted(rand_eq,:);
        [run pod rand_eq]
        
        cellnum_pred = getCellNumFromOD(t_od_perf_data(:,2),fit_eqn_rand);
        cellnum_pred_all(:,rand_eq) = cellnum_pred;
        k = (t_od_perf_data(:,3)*24)./cellnum_pred; % multiply by 24 to convert to vvd
        k = k*2e9; % To convert from vvd to picolitres/day
        t = t_od_perf_data(:,1);
        inf_nan(i,1) = sum(isinf(k));
        inf_nan(i,2) = sum(isnan(k));
        
        tmp = cell(1,5);
        tmp{1,1} = run;
        tmp{1,2} = pod;
        tmp{1,3} = fit_eqn_rand;
        tmp{1,4} = k;
        tmp{1,5} = t;
        
        res_var = [res_var; tmp];
        
    end
end
toc
datetime
eval([var_pref,' = res_var;']);

%%
eval('save(filename,var_pref)');

