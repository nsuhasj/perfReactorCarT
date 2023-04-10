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

% This script computes the oxygen consumption rate of cells in the
% microbioreactor over time.

%%
clear; clc;
load erbi_data_eqns.mat %data file containing microbioreactor data obtained using getErbiData.m and family of fit equation obtained from using getCellNumODFit_withVar.m

data = erbi_data_all_t;
fit_eqns_data = fit_eqns_var;

kla_vals = [
    28.08... Run 1 pod 0
    24.12... Run 1 pod 1
    43.92... Run 1 pod 2
    36 ...   Run 1 pod 3
    27.72... Run 2 pod 0
    42.12... Run 2 pod 1
    ]'; % Example vector of kLa values obtained during calibration of the microbioreactor. Each element corresponds to one run (donor) and pod (replicate). 

var_pref = ['diff_ocr'];
filename = [var_pref,'.mat'];
res_var = {};

%%
inf_nan = zeros(16,2);
for i = 1:size(data,1)
    curr_kla = kla_vals(i);
    data_run = data{i,3};
    cleaned_data_run = sanitizeErbiDataForOCR(data_run,2);
    fit_eqns_prctile = getEqnsWithinPrctile(fit_eqns_data{i,5}, fit_eqns_data{i,6}, 25, 75);
    rand_perm_order = randperm(size(fit_eqns_prctile,1));
    fit_eqns_rand_sorted = fit_eqns_prctile(rand_perm_order,:);
    run = fit_eqns_data{i,1};
    pod = fit_eqns_data{i,2};
    
    for rand_eq = 1:50
        fit_eqn_rand = fit_eqns_rand_sorted(rand_eq,:);
        [run pod rand_eq]
        
        cellnum_pred = getCellNumFromOD(cleaned_data_run(:,2),fit_eqn_rand);
        data_for_calc = [cleaned_data_run cellnum_pred];
        [k,t] = computeOCRbyDiff(data_for_calc,curr_kla,drive_offset);
        
        k = movmean(k,11);
        t_interp = 24:0.1:282;
        k_interp = interp1(t(1:2:end),k(1:2:end),t_interp);
        inf_nan(i,1) = sum(isinf(k));
        inf_nan(i,2) = sum(isnan(k));
       
        tmp = cell(1,5);
        tmp{1,1} = run;
        tmp{1,2} = pod;
        tmp{1,3} = fit_eqn_rand;
        tmp{1,4} = k_interp;
        tmp{1,5} = t_interp;
        
        res_var = [res_var; tmp];
        
    end    
end
eval([var_pref,' = res_var;']);
%%

eval('save(filename,var_pref)');

