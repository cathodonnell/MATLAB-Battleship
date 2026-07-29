function [playerHeatmap,gamesPlayed] = buildPlayerHeatmap(placementHistory,playerName)
%BUILDPLAYERHEATMAP Builds a 10-by-10 placement-frequency map for one player.

playerName = strtrim(string(playerName));
playerHeatmap = zeros(10,10);
gamesPlayed = 0;

if isempty(placementHistory) || strlength(playerName) == 0
    return
end

savedNames = string({placementHistory.playerName});
playerIndex = find(strcmpi(savedNames,playerName),1);

if isempty(playerIndex)
    return
end

placements = placementHistory(playerIndex).placements;
gamesPlayed = size(placements,3);

if gamesPlayed == 0
    return
end

for gameIndex = 1:gamesPlayed
    currentPlacement = placements(:,:,gameIndex);

    for pointIndex = 1:size(currentPlacement,1)
        row = currentPlacement(pointIndex,1);
        column = currentPlacement(pointIndex,2);

        if row >= 1 && row <= 10 && column >= 1 && column <= 10
            playerHeatmap(row,column) = playerHeatmap(row,column) + 1;
        end
    end
end

playerHeatmap = playerHeatmap ./ gamesPlayed;
end
