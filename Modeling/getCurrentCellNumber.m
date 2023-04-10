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

% This function estimates the viable cell count at time t via interpolation. 

function curr_X = getCurrentCellNumber(data,t)

data_t = [0;data.t(1:2:end)];
data_X = [0; data.cellNum(1:2:end)];
curr_X = interp1(data_t, data_X, t, 'nearest');