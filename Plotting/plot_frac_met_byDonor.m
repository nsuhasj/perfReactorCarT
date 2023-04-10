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

% This script plots the estimated fraction of metabolite A that is shuttled 
% towards producing metabolite B, for all donors. The script requires that 
% individual output files from running optScript_metRates.m are 
% concatenated across donors/runs (for each metabolite), and saved as a 
% file (opt_data_metRates_allDonors.mat).


%%
clear; clc
load 'opt_data_metRates_allDonors.mat';

%%

opt_data_consumed = opt_data_gln; % Metabolite A that is consumed
opt_data_produced = opt_data_glu; % Metabolite B that is produced
ratio_consumed_to_produced_met = 1; % Number of B molecules produced per molecule of A. For glucose and lactate, this value is 2.
runs_to_use = [1 0; 1 1; 1 2; 2 0; 2 1; 2 2; 3 0; 3 1; 3 2];  % List of runs and pods to use. First column is run IDs and second column is pod IDs
num_reps = 5;

opt_data_consumed_sel = selectRunData(opt_data_consumed,runs_to_use);
opt_data_produced_sel = selectRunData(opt_data_produced,runs_to_use);

[plot_data_mean_consumed, plot_data_std_consumed] = getMeanMetRatesForPlotting_byDonor(opt_data_consumed_sel, num_reps);
[plot_data_mean_produced, plot_data_std_produced] = getMeanMetRatesForPlotting_byDonor(opt_data_produced_sel, num_reps);


%%
met_ratio_prod_to_cons = 0*plot_data_mean_produced;

for i = 1:size(plot_data_mean_consumed,1)
    met_ratio_prod_to_cons(i,:) = plot_data_mean_produced(i,:)./plot_data_mean_consumed(i,:);
end

met_ratio_prod_to_cons = met_ratio_prod_to_cons/ratio_consumed_to_produced_met;


%%
clf; plot_alpha = 0.7;
cols = [0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250];
xl = {'D1-D2','D2-D3','D3-D4','D4-D5','D5-D6','D6-D7','D7-D8','D8-D9','D9-D10','D10-D11','D11-D12'};
data_to_plot = [1 2 3];
num_times = 11;

for i = 1:size(met_ratio_prod_to_cons)
    plot(2:num_times, met_ratio_prod_to_cons(i,2:end),'o-','Color',[cols(i,:) plot_alpha],'MarkerFaceColor',cols(i,:),'Linewidth',2.2);
    hold on;
    set(gca,'Box','off','XTick',2:num_times,'XTickLabels',xl(2:end),'fontsize',19);
end
xlim([1 11]);
ylim([0 1]);
legend({'Donor A','Donor C','Donor B'},'Location','Best','fontsize',20);
grid off;
xlabel('Time interval (days)','fontsize',24);
ylabel('Fraction Glutamine to Glutamate','fontsize',24);

