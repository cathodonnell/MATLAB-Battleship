function [placementHistory,totalGames]=recordPlayerPlacement(placementHistory,playerName,occupiedPoints,placementHistoryFile)
%RECORDPLAYERPLACEMENT Stores one completed player ship placement.

playerName=strtrim(string(playerName));
if strlength(playerName)==0
    error('Player name cannot be empty.');
end
if strcmpi(playerName,'guest')
    error('Guest placement data should not be saved.');
end
if ~isnumeric(occupiedPoints) || size(occupiedPoints,2) ~= 2
    error('occupiedPoints must be a numeric N-by-2 matrix.');
end
if size(occupiedPoints,1) ~= 17
    error(['A standard Battleship placement should contain exactly ' ...
           '17 occupied board spaces.']);
end
if any(occupiedPoints(:) < 1) || any(occupiedPoints(:) > 10)
    error('All occupied points must be within the 10-by-10 board.');
end
if size(unique(occupiedPoints,'rows'),1) ~= 17
    error('The placement contains overlapping or repeated coordinates.');
end
if isempty(placementHistory)

    playerIndex=[];
else
    savedNames=string({placementHistory.playerName});
    playerIndex=find(strcmpi(savedNames,playerName),1);
end
if isempty(playerIndex)
    playerIndex=numel(placementHistory) + 1;
    placementHistory(playerIndex).playerName=char(playerName);
    placementHistory(playerIndex).placements=reshape(occupiedPoints,17,2,1);
    placementHistory(playerIndex).gamesPlayed=1;
else
    totalGamesBeforeSave=size(placementHistory(playerIndex).placements,3);
    nextGame=totalGamesBeforeSave + 1;
    placementHistory(playerIndex).placements(:,:,nextGame)=occupiedPoints;
    placementHistory(playerIndex).gamesPlayed=nextGame;
end
totalGames=placementHistory(playerIndex).gamesPlayed;
save(placementHistoryFile,'placementHistory');
end