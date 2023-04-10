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

% This script computes the minimum offset required to ensure that <5% of
% the recorded OD values until Day 4 are negative


%%
getErbiData;
num_runs = size(erbi_data_all_t,1);
erbi_data_all_t_new = erbi_data_all_t;
offsets = zeros(num_runs,1);
for i = 1:num_runs
    d = erbi_data_all_t{i,3};
    d4 = d;
    d4(d4(:,1)>96,:) = []; % Remove points after day 4
    neg_frac = mean(d4(:,2)<=0)*100;

    if neg_frac>5
        offset = -prctile(d4(:,2),5)+0.0001;
        d(:,2) = d(:,2)+offset;        
        offsets(i) = offset;
    end
    d(d(:,2)<=0,:) = [];
    d(d(:,2)>1,:) = [];
    erbi_data_all_t_new{i,3} = d;
end




