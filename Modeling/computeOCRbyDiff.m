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

% This script computes the oxygen consumption rate (OCR) of cells in the
% microbioreactor using the difference equation (7) in the main text.


function [k,t] = computeOCRbyDiff(data, kla, drive_offset)

O2_sat = 8.23;  %Saturating O2 concentration at room temerature in mM O2.
do_drive_frac = data(1:(end-drive_offset),7)/100;
scale_sat = (1-do_drive_frac)+(do_drive_frac*4.762); %Computing scale factor for saturating O2 in media as a function of total O2 in the headspace

data_to_use = data((drive_offset+1):end,:);
do_conc = (data_to_use(:,3)*O2_sat)/100;
dOdt = diff(do_conc)./diff(data_to_use(:,1));

kla_term = kla*((scale_sat*O2_sat)-do_conc);
perf_term = data_to_use(:,6).*(O2_sat-do_conc);

A = kla_term+perf_term;
k = (A(2:end)-dOdt)./data_to_use(2:end,8);
t = data_to_use(2:end,1);

