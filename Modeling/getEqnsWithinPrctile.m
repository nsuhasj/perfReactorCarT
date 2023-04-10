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

% This function subselects those equations out of 1000 equations, whose
% predictions of viable cell count from OD values, lies between two percentile
% bounds among all 1000 predictions.

function sel_eqns = getEqnsWithinPrctile(rand_eqns, rand_preds,low_prctile,hi_prctile)

p_low = prctile(rand_preds,low_prctile);
p_hi = prctile(rand_preds,hi_prctile);
z = 0*rand_preds;

for i = 1:size(rand_preds,2)
    z(:,i) = (rand_preds(:,i)<=p_hi(i) & rand_preds(:,i)>=p_low(i)); 
end

z_sel_ind = sum(z,2)==101;
sel_eqns = rand_eqns(z_sel_ind,:);
end