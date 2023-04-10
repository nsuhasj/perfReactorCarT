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

% This script plots the estimated metabolite consumption/production rates
% for all donors. The script requires that individual output files from
% running optScript_metRates.m are concatenated across donors/runs (for each
% metabolite), and saved as a file (opt_data_metRates_allDonors.mat).


%%
clear; clc
load 'opt_data_metRates_allDonors.mat'
opt_data = opt_data_lac;

%%
clc;
runs_to_use = [1 0; 1 1; 1 2; 2 0; 2 1; 2 2; 3 0; 3 1; 3 2];  % List of runs and pods to use. First column is run IDs and second column is pod IDs
unique_donors = unique(runs_to_use(:,1));

num_reps = 5;
opt_data_sel = selectRunData(opt_data,runs_to_use);
[plot_data_mean, plot_data_std] = getMeanMetRatesForPlotting_byDonor(opt_data_sel, num_reps);

%%
clf; clc; plot_alpha = 0.7;
num_times = 11;
cols = [0.7 0 0;0 0.7 0; 0 0 0.7; 0.7 0.7 0; 0.5 0.5 0.5; 0 0 0];
cols = [0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250];
xl = {'D1-D2','D2-D3','D3-D4','D4-D5','D5-D6','D6-D7','D7-D8','D8-D9','D9-D10','D10-D11','D11-D12'};

for i = 1:length(unique_donors)
    errorbar(1:num_times,plot_data_mean(i,:),plot_data_std(i,:),'o-','Color',cols(i,:),'MarkerFaceColor',cols(i,:),'Linestyle','none','LineWidth',1.75);
    hold on;
    plot(1:num_times,plot_data_mean(i,:),'color',[cols(i,:) plot_alpha],'LineWidth',2.2);
    set(gca,'Box','off','XTick',1:num_times,'XTickLabels',xl(1:end),'fontsize',19);
end
xlim([1 11]);
ylim([0 2.5]);
legend('Donor A',"",'Donor B',"",'Donor C','Location','Best','fontsize',20);
grid off;
xlabel('Time interval (days)','fontsize',24);
ylabel({'Lactate production rate'; '(x10^-^7 mM/hr/cell)'},'fontsize',24);

