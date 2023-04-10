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

% This function defines the objective function for the optimization
% function to compute metabolic rates. The function returns an error term f
% that is computed as the sum-of-squared difference between experimentally
% measured metabolite concentration and the concentration predicted by an
% ODE defined in the function ode_metRates.

function f = objMetRates(p, data_subset,cedex_data,c_t)

f = 0;
C = [0.035]; 
data.t = data_subset(:,1);
data.perf = data_subset(:,6);
data.cellNum = data_subset(:,8);


y_init = cedex_data(1);
[ode_t,y] = ode15s(@(t,y)ode_metRates(t,y,p,C,data),data.t(1:2:end),y_init);


met_meas = cedex_data(2);
met_ode = mean(y(ode_t>c_t(1) & ode_t<c_t(2)));

f = (met_meas-met_ode)^2;

end