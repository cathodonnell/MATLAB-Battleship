function [clickedPointBot, probGrid] = monteCarloMove(activeHitPoints,missedPointsBot,shipSunk)

numSims = 50;
probGrid = zeros(10,10);

allTriedPoints = [activeHitPoints; missedPointsBot];
allShipLengths = [5 4 3 3 2];
shipLengths = allShipLengths(shipSunk==0);

for sim = 1:numSims
    [simOccupied, validBoard] = randomBoardConsistentWithData(shipLengths,activeHitPoints,missedPointsBot);

    if validBoard==1
        for k = 1:size(simOccupied,1)
            x = simOccupied(k,1);
            y = simOccupied(k,2);
            probGrid(x,y) = probGrid(x,y) + 1;
        end
    end
end

for k = 1:size([activeHitPoints; missedPointsBot],1)
    point = [activeHitPoints; missedPointsBot];
    probGrid(point(k,1),point(k,2)) = 0;
end

if max(probGrid(:))==0
    remainingPoints = zeros(0,2);

    for x = 1:10
        for y = 1:10
            currentPoint = [x y];
            if isempty([activeHitPoints; missedPointsBot]) || ~ismember(currentPoint,[activeHitPoints; missedPointsBot],'rows')
                remainingPoints = [remainingPoints; currentPoint];
            end
        end
    end

    r = randi(size(remainingPoints,1));
    clickedPointBot = remainingPoints(r,:);
else
    maxVal = max(probGrid(:));
    idx = find(probGrid==maxVal);
    chosenIdx = idx(randi(length(idx)));
    [x,y] = ind2sub(size(probGrid),chosenIdx);
    clickedPointBot = [x y];
end

end