function plotMonteCarloHeatmap(probGrid,activeHitPoints,missedPointsBot,clickedPointBot)
% Plots Monte Carlo probability heatmap with:
% red = hits, white = misses, color = probability

figure(99);
clf

% Normalize probability grid
if ~isempty(probGrid) && max(probGrid(:)) > 0
    probDisplay = probGrid ./ max(probGrid(:));
else
    probDisplay = probGrid;
end

% Plot heatmap
imagesc(probDisplay')
axis equal
axis([0.5 10.5 0.5 10.5])
set(gca,'YDir','normal')

colormap(parula)
colorbar
title('Monte Carlo Probability Heat Map')
xlabel('X Position')
ylabel('Y Position')

hold on

% --- draw grid lines ---
for k = 0.5:1:10.5
    plot([0.5 10.5],[k k],'k-')
    plot([k k],[0.5 10.5],'k-')
end

% --- plot MISSES (white) ---
if ~isempty(missedPointsBot)
    for i = 1:size(missedPointsBot,1)
        x = missedPointsBot(i,1);
        y = missedPointsBot(i,2);
        rectangle('Position',[x-0.5,y-0.5,1,1], ...
                  'FaceColor',[1 1 1], ...
                  'EdgeColor','k');
    end
end

% --- plot HITS (red) ---
if ~isempty(activeHitPoints)
    for i = 1:size(activeHitPoints,1)
        x = activeHitPoints(i,1);
        y = activeHitPoints(i,2);
        rectangle('Position',[x-0.5,y-0.5,1,1], ...
                  'FaceColor',[1 0 0], ...
                  'EdgeColor','k');
    end
end

% --- highlight current move (cyan outline) ---
if ~isempty(clickedPointBot)
    rectangle('Position',[clickedPointBot(1)-0.5,clickedPointBot(2)-0.5,1,1], ...
              'EdgeColor',[0 1 1], ...
              'LineWidth',2);
end

hold off
drawnow

end