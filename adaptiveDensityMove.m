function [clickedPointBot,combinedGrid] = adaptiveDensityMove( ...
    activeHitPoints,hitPointsBotUnique,missedPointsBot,shipSunk, ...
    playerHeatmap,gamesPlayed)
%ADAPTIVEDENSITYMOVE Combines legal-placement density with player history.

shipLengths = [5 4 3 3 2];
remainingLengths = shipLengths(shipSunk == 0);

generalGrid = zeros(10,10);
usedPoints = unique([hitPointsBotUnique; missedPointsBot],'rows');

for shipIndex = 1:length(remainingLengths)
    shipLength = remainingLengths(shipIndex);

    for row = 1:10
        for column = 1:(10-shipLength+1)
            placement = [row*ones(shipLength,1), ...
                (column:column+shipLength-1)'];

            if isValidPlacementDensity(placement,activeHitPoints,missedPointsBot)
                for pointIndex = 1:shipLength
                    currentRow = placement(pointIndex,1);
                    currentColumn = placement(pointIndex,2);
                    generalGrid(currentRow,currentColumn) = ...
                        generalGrid(currentRow,currentColumn) + 1;
                end
            end
        end
    end

    for column = 1:10
        for row = 1:(10-shipLength+1)
            placement = [(row:row+shipLength-1)', ...
                column*ones(shipLength,1)];

            if isValidPlacementDensity(placement,activeHitPoints,missedPointsBot)
                for pointIndex = 1:shipLength
                    currentRow = placement(pointIndex,1);
                    currentColumn = placement(pointIndex,2);
                    generalGrid(currentRow,currentColumn) = ...
                        generalGrid(currentRow,currentColumn) + 1;
                end
            end
        end
    end
end

personalGrid = playerHeatmap;
if max(personalGrid(:)) > 0
    personalGrid = personalGrid ./ max(personalGrid(:));
end

clusterGrid = conv2(personalGrid,ones(3,3),'same');
if max(clusterGrid(:)) > 0
    clusterGrid = clusterGrid ./ max(clusterGrid(:));
end

validCells = generalGrid > 0;
generalNormalized = zeros(10,10);
if any(validCells(:))
    generalNormalized(validCells) = ...
        generalGrid(validCells) ./ max(generalGrid(validCells));
end

personalWeight = min(0.50,0.05*gamesPlayed);
generalWeight = 1 - personalWeight;
learnedGrid = 0.80*personalGrid + 0.20*clusterGrid;
combinedGrid = generalWeight*generalNormalized + personalWeight*learnedGrid;
combinedGrid(~validCells) = -Inf;

for pointIndex = 1:size(usedPoints,1)
    row = usedPoints(pointIndex,1);
    column = usedPoints(pointIndex,2);

    if row >= 1 && row <= 10 && column >= 1 && column <= 10
        combinedGrid(row,column) = -Inf;
    end
end

maximumValue = max(combinedGrid(:));

if isinf(maximumValue)
    remainingPoints = zeros(0,2);

    for row = 1:10
        for column = 1:10
            if isempty(usedPoints) || ~ismember([row column],usedPoints,'rows')
                remainingPoints(end+1,:) = [row column]; %#ok<AGROW>
            end
        end
    end

    if isempty(remainingPoints)
        error('No valid remaining shots for Adaptive Bot.');
    end

    clickedPointBot = remainingPoints(randi(size(remainingPoints,1)),:);
else
    bestIndices = find(combinedGrid == maximumValue);
    selectedIndex = bestIndices(randi(length(bestIndices)));
    [row,column] = ind2sub(size(combinedGrid),selectedIndex);
    clickedPointBot = [row column];
end
end
