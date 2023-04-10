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

% This function sanitizes the erbi file for OCR computation as follows. Optical 
% density (OD) is recorded by the bioreactor only once every two minutes 
% (approx). However the excel file log includes data fro every minute, so 
% OD values are repeated for two entries.During sanitizing, we idenitfy
% entries where the OD value has been duplicated again and remove these
% entries. In addition the DO drive value which indicates the duty cycles
% for which pure O2 is switched on, is computed as an average of the
% deleted timepoint and the successive timepoint
 
function cleaned_data = sanitizeErbiDataForOCR(erbi_data, od_col)

zero_od_idx = find(erbi_data(:,od_col)==0);
erbi_data(zero_od_idx,:) = [];

d = diff(erbi_data(:,1));
erbi_data(d==0,:) = [];

t = erbi_data(:,1);
od = erbi_data(:,od_col);

diff_t = diff(t);
diff_od = diff(od);

idx = diff_t<0.02 & diff_od==0; idx = [false; idx];
idx_vals = find(idx); idx_vals = idx_vals-1;

cleaned_data = erbi_data;
do_drive = erbi_data(:,7); do_drive_new = do_drive;
do_drive_new(idx_vals+1) = (do_drive(idx_vals+1)+do_drive(idx_vals))/2;
cleaned_data(:,7) = do_drive_new;


cleaned_data(idx_vals,:) = [];
end