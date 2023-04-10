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

% This script uses experimentally measured cell number data and
% corresponding OD values from the bioreactor to compute the family of fits
% for each donor(run) and replicate(pod)



function fits_global_ind_var = getCellNumODFit_withVar(cellnum_od_data)

y_overall = cellnum_od_data(:,[6 9]);
pred_od = 0:0.01:1;
lower_bnd = [0 0 0];
upper_bnd = [inf inf 0];
fit_global_obj = fit(y_overall(:,1), y_overall(:,2),'poly2','Lower',lower_bnd,'Upper',upper_bnd);
fit_global = [fit_global_obj.p1 fit_global_obj.p2 fit_global_obj.p3];
fit_global_pred = polyval(fit_global,pred_od);

unique_runs = unique(cellnum_od_data(:,1:2),'rows');
num_runs = size(unique_runs,1);
fits_global_ind_var = cell(num_runs,6);
figure;

for i = 1:num_runs
    r = unique_runs(i,1);
    p = unique_runs(i,2);
    pred_int = zeros(length(0:0.01:1),2);
    y_ind = cellnum_od_data(:,1)==r & cellnum_od_data(:,2) == p;
    y_ind_fit = cellnum_od_data(y_ind,[6 9]);
    y_lin_fit = y_ind_fit;
    y_lin_fit(:,2) = y_lin_fit(:,2)-((y_lin_fit(:,1).^2)*fit_global(1));
    fresh_fit_lin_obj = fit(y_lin_fit(:,1),y_lin_fit(:,2),'poly1','Lower',[0 0],'Upper',[inf 0]);
    fresh_fit_lin = [fit_global(1) fresh_fit_lin_obj.p1 fresh_fit_lin_obj.p2];
    fresh_fit_lin_pred = polyval(fresh_fit_lin,pred_od);
    
    fresh_fit_obj = fit(y_ind_fit(:,1),y_ind_fit(:,2),'poly2','Lower',lower_bnd,'Upper',upper_bnd);  
    fresh_fit = [fresh_fit_obj.p1 fresh_fit_obj.p2 fresh_fit_obj.p3];
    fresh_fit_pred = polyval(fresh_fit,pred_od);
    
    
    tmp{1,1} = r;
    tmp{1,2} = p;
    tmp{1,3} = fresh_fit_lin;
    tmp{1,4} = fresh_fit;
    
    min_params = [min(fresh_fit_lin(1),fresh_fit(1)) min(fresh_fit_lin(2),fresh_fit(2)) min(fresh_fit_lin(3),fresh_fit(3))];
    max_params = [max(fresh_fit_lin(1),fresh_fit(1)) max(fresh_fit_lin(2),fresh_fit(2)) max(fresh_fit_lin(3),fresh_fit(3))];
    
    rand_eqs = zeros(1000,3);
    pred_rands = zeros(1000,101);
    for j = 1:1000
        rand_p = rand(1,3);
        rand_eq_tmp = min_params + (rand_p.*(max_params-min_params));
        rand_eqs(j,:) = rand_eq_tmp;
        pred_rand_tmp = polyval(rand_eq_tmp, pred_od);
        pred_rands(j,:) = pred_rand_tmp;
    end
    
    tmp{1,5} = rand_eqs;
    tmp{1,6} = pred_rands;
    fits_global_ind_var(i,:) = tmp;
    
end