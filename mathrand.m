function [turnsToWin,hitPointsBotUnique,missedPointsBot, ...
    botname,allPointsBot] = mathrand(occupiedPoints)
%MATHRAND uses a linear congruential generator rather than MATLAB's
% rand function. Every board coordinate appears exactly once, preventing
% repeated guesses and guaranteeing that the bot finishes.
botname = 'Mathematically Random';
[xGrid,yGrid] = ndgrid(1:10,1:10);
allBoardPoints = [xGrid(:),yGrid(:)];
numberOfPoints = size(allBoardPoints,1);
% Linear congruential generator:
% seed(n+1) = mod(a*seed(n) + c, M)
a = 1664525;
c = 1013904223;
M = 2^32;
clockValues = clock;
seed = floor(mod(sum(clockValues .* [1 60 3600 86400 1e5 1e6]),2^32));
randomKeys = zeros(numberOfPoints,1);

for pointIndex = 1:numberOfPoints
    seed = mod(a*seed + c,M);
    randomKeys(pointIndex) = double(seed)/double(M);
end
[~,randomOrder] = sort(randomKeys);
orderedPoints = allBoardPoints(randomOrder,:);
hitPointsBot = zeros(0,2);
missedPointsBot = zeros(0,2);
allPointsBot = zeros(0,2);
for turnIndex = 1:numberOfPoints
    clickedPointBot = orderedPoints(turnIndex,:);
    allPointsBot(turnIndex,:) = clickedPointBot;
    if ismember(clickedPointBot,occupiedPoints,'rows')
        hitPointsBot(end+1,:) = clickedPointBot;
    else
        missedPointsBot(end+1,:) = clickedPointBot;
    end

    if size(hitPointsBot,1) >= size(occupiedPoints,1)
        break
    end
end
allPointsBot = allPointsBot(1:turnIndex,:);
hitPointsBotUnique = unique(hitPointsBot,'rows','stable');
turnsToWin = turnIndex;

end