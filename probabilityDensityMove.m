function [clickedPointBot, probGrid] = probabilityDensityMove(activeHitPoints, hitPointsBot_unique, missedPointsBot, shipSunk)
% probabilityDensityMove builds a deterministic heatmap by counting all
% legal placements of each remaining ship length.

shipLengths = [5 4 3 3 2];
remainingLengths = shipLengths(shipSunk == 0);

probGrid = zeros(10,10);

% all shots already taken
usedPoints = unique([hitPointsBot_unique; missedPointsBot],'rows');

% loop through each remaining ship length
for s = 1:length(remainingLengths)
    L = remainingLengths(s);

    %horizontal
    for r = 1:10
        for c = 1:(10-L+1)
            placement = [r*ones(L,1), (c:c+L-1)'];

            if isValidPlacementDensity(placement, activeHitPoints, missedPointsBot)
                for k = 1:L
                    probGrid(placement(k,1), placement(k,2)) = probGrid(placement(k,1), placement(k,2)) + 1;
                end
            end
        end
    end

    %vertical
    for c = 1:10
        for r = 1:(10-L+1)
            placement = [(r:r+L-1)', c*ones(L,1)];

            if isValidPlacementDensity(placement, activeHitPoints, missedPointsBot)
                for k = 1:L
                    probGrid(placement(k,1), placement(k,2)) = probGrid(placement(k,1), placement(k,2)) + 1;
                end
            end
        end
    end
end

%near active hits
if ~isempty(activeHitPoints)
    for k = 1:size(activeHitPoints,1)
        r = activeHitPoints(k,1);
        c = activeHitPoints(k,2);

        neighbors = [r-1 c;
                     r+1 c;
                     r c-1;
                     r c+1];

        for n = 1:size(neighbors,1)
            rr = neighbors(n,1);
            cc = neighbors(n,2);

            if rr>=1 && rr<=10 && cc>=1 && cc<=10
                if isempty(usedPoints) || ~ismember([rr cc], usedPoints, 'rows')
                    if probGrid(rr,cc) > 0
                        probGrid(rr,cc) = probGrid(rr,cc) + 5;
                    end
                end
            end
        end
    end
end

%2+ active hits, aligned
if size(activeHitPoints,1) >= 2
    sameRow = all(activeHitPoints(:,1) == activeHitPoints(1,1));
    sameCol = all(activeHitPoints(:,2) == activeHitPoints(1,2));

    if sameRow
        rowVal = activeHitPoints(1,1);
        minC = min(activeHitPoints(:,2));
        maxC = max(activeHitPoints(:,2));

        extensions = [rowVal minC-1;
                      rowVal maxC+1];

        for k = 1:size(extensions,1)
            rr = extensions(k,1);
            cc = extensions(k,2);

            if rr>=1 && rr<=10 && cc>=1 && cc<=10
                if isempty(usedPoints) || ~ismember([rr cc], usedPoints, 'rows')
                    probGrid(rr,cc) = probGrid(rr,cc) + 15;
                end
            end
        end
    elseif sameCol
        colVal = activeHitPoints(1,2);
        minR = min(activeHitPoints(:,1));
        maxR = max(activeHitPoints(:,1));

        extensions = [minR-1 colVal;
                      maxR+1 colVal];

        for k = 1:size(extensions,1)
            rr = extensions(k,1);
            cc = extensions(k,2);

            if rr>=1 && rr<=10 && cc>=1 && cc<=10
                if isempty(usedPoints) || ~ismember([rr cc], usedPoints, 'rows')
                    probGrid(rr,cc) = probGrid(rr,cc) + 15;
                end
            end
        end
    end
end

for k = 1:size(usedPoints,1)
    probGrid(usedPoints(k,1), usedPoints(k,2)) = -Inf;
end

maxVal = max(probGrid(:));

if isinf(maxVal)
    remainingPoints = zeros(0,2);

    for r = 1:10
        for c = 1:10
            if isempty(usedPoints) || ~ismember([r c], usedPoints, 'rows')
                remainingPoints = [remainingPoints; r c];
            end
        end
    end

    if isempty(remainingPoints)
        error('No valid remaining shots for Probability Density Bot.');
    end

    clickedPointBot = remainingPoints(randi(size(remainingPoints,1)), :);
else
    bestIdx = find(probGrid(:) == maxVal);
    pick = bestIdx(randi(length(bestIdx)));
    [row, col] = ind2sub(size(probGrid), pick);
    clickedPointBot = [row col];
end
% % Plot heatmap for Probability Density Bot
% figure(98)
% imagesc(probGrid')
% axis equal
% axis([0.5 10.5 0.5 10.5])
% set(gca,'YDir','normal')
% 
% colormap(parula)
% colorbar
% title('Probability Density Bot Heat Map')
% xlabel('X Position')
% ylabel('Y Position')
% 
% hold on
% 
% % --- draw grid lines ---
% for k = 0.5:1:10.5
%     plot([0.5 10.5],[k k],'k-')
%     plot([k k],[0.5 10.5],'k-')
% end
% 
% % --- plot MISSES (white) ---
% if ~isempty(missedPointsBot)
%     for i = 1:size(missedPointsBot,1)
%         x = missedPointsBot(i,1);
%         y = missedPointsBot(i,2);
% 
%         rectangle('Position',[x-0.5,y-0.5,1,1], ...
%                   'FaceColor',[1 1 1], ...
%                   'EdgeColor','k');
%     end
% end
% 
% % --- plot HITS (red) ---
% if ~isempty(hitPointsBot_unique)
%     for i = 1:size(hitPointsBot_unique,1)
%         x = hitPointsBot_unique(i,1);
%         y = hitPointsBot_unique(i,2);
% 
%         rectangle('Position',[x-0.5,y-0.5,1,1], ...
%                   'FaceColor',[1 0 0], ...
%                   'EdgeColor','k');
%     end
% end
% 
% % --- highlight current move (cyan outline) ---
% if ~isempty(clickedPointBot)
%     rectangle('Position',[clickedPointBot(1)-0.5,clickedPointBot(2)-0.5,1,1], ...
%               'EdgeColor',[0 1 1], ...
%               'LineWidth',2);
% end
% 
% hold off
% drawnow
end