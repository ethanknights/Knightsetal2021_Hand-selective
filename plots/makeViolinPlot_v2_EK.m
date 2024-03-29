function makeViolinPlot_v2_EK(d,roiName)

%%get colours
% try
%     [cb] = cbrewer('qual', 'Set3', 12, 'pchip');
% catch
%     cb = [0.5 0.8 0.9; 1 1 0.7; 0.7 0.8 0.9; 0.8 0.5 0.4; 0.5 0.7 0.8; 1 0.8 0.5; 0.7 1 0.4; 1 0.7 1; 0.6 0.6 0.6; 0.7 0.5 0.7; 0.8 0.9 0.8; 1 1 0.4];
% end
% color_L = cb(1,:)
% color_R = cb(4,:)
color_L = [1 1 1];
color_R = [0.6510    0.6510    0.6510];

%%Kernel densities
[f_L, Xi_L, ~] = ksdensity(d{1}); %leave bandwidth as default, like Allen et al. 2019
[f_R, Xi_R, ~] = ksdensity(d{2}); %leave bandwidth as default, like Allen et al. 2019

[Xi_L,f_L] = truncate_EK(Xi_L,f_L,d{1});
[Xi_R,f_R] = truncate_EK(Xi_R,f_R,d{2});

f_R = 0-f_R; %invert right split

%%Violins
                %%Basic plots for checking
                % clf
                % close all
                % h{1} = area(Xi_L, f_L); hold on %Original
                % h{1} = area(Xi_R, f_R); hold on
%https://stackoverflow.com/questions/44195924/multiple-area-with-different-baseline-in-matlab 
clf
close all

baseline1 = 0.8;
baseline2 = -0.8;
alpha = 0.5; %colour
line_width = 2.5;

ax(1) = axes;
a1 = area(ax(1), Xi_L, f_L + baseline1, baseline1,'FaceColor',color_L,'EdgeColor',[0,0,0],'LineWidth',line_width,'FaceAlpha',alpha);
a1(1).BaseLine.Visible = 'off'; 
set(gca,'linewidth',2) 
ax(2) = axes;
a2 = area(ax(2), Xi_R, f_R + baseline2, baseline2,'FaceColor',color_R,'EdgeColor',[0,0,0],'LineWidth',line_width,'FaceAlpha',alpha);
a2(1).BaseLine.Visible = 'off'; 

axis off % turn off the secon axes
limitsY = cell2mat(get(ax,'YLim')); 
set(ax,'YLim',[min(limitsY(:)) max(limitsY(:))],'TickDir','out'); % set the same values for both axes
linkaxes(ax) %important to keep xAxis scale

set(gca,'Ylim',[-8,8])
% The only other option is 'in' 
%%Boxplots

%parameters
wdth = 0.6
%lwr_bnd = 1; %unnecessary
%jit = (rand(size(d{1})) - 0.5) * wdth; % jitter for raindrops
%dot_dodge_amount = [0.2,-0.2]; %for raindrops
box_dodge_amount = [0.1,-0.01] / [baseline1 / 1.5];

Ymean_L = mean(d{1});
YSEM_Pos_L = Ymean_L + 2 * std(d{1})/sqrt(length(d{1}));
YSEM_Neg_L = Ymean_L - 2 * std(d{1})/sqrt(length(d{1}));
%YSD_Pos = Ymean + 2 * std(d{1}); 2SD is huge, beyond truncation
%YSD_Neg = Ymean - 2 * std(d{1}); 2SD is huge, beyond truncation
YSD_Pos_L = Ymean_L + 1 * std(d{1});
YSD_Neg_L = Ymean_L - 1 * std(d{1});

Ymean_R = mean(d{2});
YSEM_Pos_R = Ymean_R + 2 * std(d{2})/sqrt(length(d{2}));
YSEM_Neg_R = Ymean_R - 2 * std(d{2})/sqrt(length(d{2}));
%YSD_Pos = Ymean + 2 * std(d{2}); 2SD is huge, beyond truncation
%YSD_Neg = Ymean - 2 * std(d{2}); 2SD is huge, beyond truncation
YSD_Pos_R = Ymean_R + 1 * std(d{2});
YSD_Neg_R = Ymean_R - 1 * std(d{2});

% make some space under the density plot for the boxplot and raindrops
yl = get(gca, 'YLim');
% set(gca, 'YLim', [-yl(2)*lwr_bnd yl(2)]); 
set(gca, 'YLim', [-yl(2) yl(2)]);

        %%raindrops
        %drops_pos = (jit * 0.6) - yl(2) * dot_dodge_amount;
        %h{2} = scatter(X, drops_pos); %%TURN SCATTER ON / OFF
        %h{2}.SizeData = 10;
        %h{2}.MarkerFaceColor = color;
        %h{2}.MarkerEdgeColor = 'none';
        
%boxes        
midWhisk = 1.225; %trial + error

%LEFT
% mean line
h{1} = line([Ymean_L Ymean_L], [yl(2) * box_dodge_amount(1), (yl(2) * box_dodge_amount(1)) + wdth], 'col', [0,0,0], 'LineWidth', line_width);

% whiskers
h{2} = line([YSEM_Pos_L YSD_Pos_L], [yl(2) * box_dodge_amount(1) * midWhisk, yl(2) * box_dodge_amount(1) * midWhisk], 'col', [0,0,0], 'LineWidth', line_width);
h{3} = line([YSEM_Neg_L YSD_Neg_L], [yl(2) * box_dodge_amount(1) * midWhisk, yl(2) * box_dodge_amount(1) * midWhisk], 'col', [0,0,0], 'LineWidth', line_width);

box_pos = [YSEM_Neg_L, yl(2) * box_dodge_amount(1), YSEM_Pos_L - YSEM_Neg_L, wdth]
h{4} = rectangle('Position', box_pos);
set(h{4}, 'EdgeColor', [0,0,0]);
set(h{4}, 'LineWidth', line_width);

%RIGHT
% mean line
h{5} = line([Ymean_R Ymean_R], [yl(1) * box_dodge_amount(1), (yl(1) * box_dodge_amount(1)) - wdth], 'col', [0,0,0], 'LineWidth', line_width);

% whiskers
h{6} = line([YSEM_Pos_R YSD_Pos_R], [-yl(2) * box_dodge_amount(1) * midWhisk, -yl(2) * box_dodge_amount(1) * midWhisk], 'col', [0,0,0], 'LineWidth', line_width);
h{7} = line([YSEM_Neg_R YSD_Neg_R], [-yl(2) * box_dodge_amount(1) * midWhisk, -yl(2) * box_dodge_amount(1) * midWhisk], 'col', [0,0,0], 'LineWidth', line_width);

box_pos = [YSEM_Neg_R, -yl(2) * box_dodge_amount(1) - wdth, YSEM_Pos_R - YSEM_Neg_R, wdth]
h{8} = rectangle('Position', box_pos);
set(h{8}, 'EdgeColor', [0,0,0]);
set(h{8}, 'LineWidth', line_width);

%Between classification line
if strcmp(roiName,'LOTC-Hand') | strcmp(roiName,'IPS-Hand')
    line([Ymean_L,Ymean_R],[yl(2) * box_dodge_amount(1) * midWhisk,-yl(2) * box_dodge_amount(1) * midWhisk],'col', [0,0,0], 'LineWidth', line_width,'LineStyle',':');
end

%formatting
set(gca,'YLim', [-8 8]) %1 ROI
set(gca,'XLim', [0 1]) %1 ROI
set(ax,'view',[-90 90])%,'FontSize',10,'FontName','Arial'); %set(gca,'view',[90 -90])

ax(1).YAxis.Visible = 'off';
ax(1).Box = 'off'; %box off
title(roiName)
%set(gca,'FontSize',20)  %do not play, this alters box plot, just fix after

%print
set(gcf,'PaperPositionMode','auto')
savefig(roiName)
print(roiName,'-dpng','-r1500') print('IPS-Hand','-dpng','-r1000') 
%plot2svg([roiName,'.svg']);
end

