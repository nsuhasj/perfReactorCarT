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

% This script sub-selects data (from a variable called opt_data) for just 
% those runs/pods listed in the matrix runs_to_use. First column of the 
% matrix is the run ID and the second column is the pod ID. 




function selOptData = selectRunData(opt_data,runs_to_use)

if iscell(opt_data)
    opt_data_exp = cell2mat(opt_data(:,[1 2]));
    selOptData = {};
else
    opt_data_exp = opt_data(:,1:2);
    selOptData = [];
end

    
    for i = 1:size(runs_to_use,1)
        run_id = runs_to_use(i,1); pod_id = runs_to_use(i,2);
        opt_ind = find(opt_data_exp(:,1) == run_id & opt_data_exp(:,2)== pod_id);
        tmp = opt_data(opt_ind,:);
        selOptData = [selOptData; tmp];
    end