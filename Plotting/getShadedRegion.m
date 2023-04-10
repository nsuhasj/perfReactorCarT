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

% This script computes the region to shade in a plot. The shaded region
% typically indicates a measure of dispersion/variability such as standard
% deviation or median absolute deviation.


function [shade_X, shade_Y] = getShadedRegion(x,mean_y, std_y)

nan_entries_idx = find(isnan(mean_y));
x(nan_entries_idx) = [];
mean_y(nan_entries_idx) = [];
std_y(nan_entries_idx) = [];

x = reshape(x,numel(x),1);
mean_y = reshape(mean_y,numel(mean_y),1);
std_y = reshape(std_y,numel(std_y),1);


shade_X = [x; flipud(x)];

shade_Y = [(mean_y-std_y);flipud(mean_y+std_y)];
