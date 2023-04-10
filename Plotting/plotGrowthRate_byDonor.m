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

% This script plots the estimated growth rates of cells in the
% microbioreactor.

%%
figure; clc;
cols = [0    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250];

runs_to_use = [1 0; 1 1; 1 2; 2 0; 2 1; 2 2; 3 0; 3 1; 3 2];  % List of runs and pods to use. First column is run IDs and second column is pod IDs
movmean_window = 40;  %40 values = 4 hr window

k_data = diff_growthRate;
k_data_sel = selectRunData(k_data,runs_to_use);
run_info = cell2mat(k_data_sel(:,1));
unique_runs = unique(run_info);

k_run = zeros(150,size(k_data_sel{1,4},1),length(unique_runs));
median_k_run = zeros(length(unique_runs),size(k_data_sel{1,4},1));
mean_k_run = median_k_run; std_k_run = median_k_run; mad_k_run = median_k_run;

for i = 1:length(unique_runs)
    run = unique_runs(i,1);
    run_ind = run_info(:,1)==run; num_runs = sum(run_ind);
    k_data_run = k_data_sel(run_ind,:);
    for xx = 1:num_runs
        k = k_data_run{xx,4}; t = k_data_run{xx,5};
        k_run(xx,:,i) = movmean(k',movmean_window);
    end
    median_k_run(i,:) = median(k_run(:,:,i));
    mean_k_run(i,:) = mean(k_run(:,:,i));
    std_k_run(i,:) = std(k_run(:,:,i));
    mad_k_run(i,:) = mad(k_run(:,:,i));
end

min_t = floor(t(1)/24); min_t_hr = min_t*24;
max_t = ceil(t(end)/24); max_t_hr = max_t*24;


for i = 1:3
    b = plot(t,median_k_run(i,:),'Color',cols(i,:),'LineWidth',2);
    hold on;
end

for i = 1:3
    [s_x,s_y] = getShadedRegion(t,median_k_run(i,:),mad_k_run(i,:));
    fill(s_x,s_y,cols(i,:),'FaceAlpha',0.25,'EdgeColor','none');
end

ylim([-0.1 0.3]); %grid on;
set(gca,'box','off','XTick',min_t_hr:24:max_t_hr,'XTickLabel',min_t:max_t,'fontsize',20);
xlabel('Time (days)','fontsize',20);
ylabel('Estimated Growth rate (hr^-^1)','fontsize',20);


pr_hours = [2 4 6 8]*24;
for pr = 1:4
    line([pr_hours(pr) pr_hours(pr)],[-500 500],'Color',[0.5 0.5 0.5]);
end
legend('Donor A','Donor B','Donor C',"","","","","","","",'fontsize',20,'location','best');
