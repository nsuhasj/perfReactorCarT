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

% This function defines the ODE used to compute metabolic consumption or production rates per cell.

function dydt = ode_metRates(t,y,p,C,data)

k_met_x = p(1)*1e-7; % Metabolic consumption/production rate per cell


MET_media = C(1);
k_p = getCurrentPerfRate(data,t);
curr_X = getCurrentCellNumber(data,t);

MET = y(1);
met_flux_x = (k_met_x * curr_X * met_scale);


%dydt(1,1) = k_p* (MET_media - MET) - (met_flux_x);  % Uncomment for metabolite consumption rate

dydt(1,1) = k_p* (MET_media - MET) + (met_flux_x);  % Uncomment for metabolite production rate


end

