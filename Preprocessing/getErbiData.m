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

% This program loads data from the breez microbioreactor. Excel filenames are
% of the format in the example 'mbs_setup_POD0_export_RUN1.xlsx' which
% contains data from run 1, pod 0. The script loads a matlab data file
% callued cellnum_ode_data.mat that contains information mapping
% experimental cell count measurements and corresponding OD values from the
% microbioreactor.


%%
clear; clc;
numVars = 43;
dt = repmat({'double'},1,numVars);
opts = spreadsheetImportOptions('DataRange','B3','NumVariables',numVars,'VariableNamesRange','B2','VariableTypes',dt);
load cellnum_ode_data.mat; 
fit_eqns_var = getCellNumODFit_withVar(cellnum_od_data);
runOrder = cell2mat(fit_eqns_var(:,1:2));

%%
unique_runs = unique(cellnum_od_data(:,1:2),'rows');
runs_to_use = unique_runs;
erbi_data_all_t = cell(size(runs_to_use,1),3);

for run_ind = 1:length(runs_to_use)
    
    r = runs_to_use(run_ind,1); p = runs_to_use(run_ind,2);
    fit_ind = find(runOrder(:,1)==r & runOrder(:,2)==p);

    
    filename = ['mbs_setup_POD',num2str(p),'_export_RUN',num2str(r),'.xlsx'];
    erbi = readtable(filename,opts);
    disp('Done loading file');
    
    perf = round(erbi.MolecularDilution_vVD_,3)/24; 
    perf(1:500) = 0; % To set perfusion rate during the early timepoints to 0.
    
    tmp = [erbi.Time_h_ erbi.OpticalDensity erbi.DissolvedOxygen erbi.pH erbi.BaseInjections perf  erbi.DissolvedOxygenDrive];
    
    erbi_data_all_t{run_ind,1} = r;
    erbi_data_all_t{run_ind,2} = p;
    erbi_data_all_t{run_ind,3} = tmp;
end
