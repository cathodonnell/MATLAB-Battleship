function [isUnlocked,gamesPlayed,gamesRemaining] = ...
    getAdaptiveBotStatus(placementHistory,playerName,requiredGames)
%GETADAPTIVEBOTSTATUS Checks whether a player has unlocked the adaptive bot.

playerName = strtrim(string(playerName));
gamesPlayed = 0;
gamesRemaining = requiredGames;
isUnlocked = false;
if strlength(playerName) == 0 || strcmpi(playerName,'guest')
    return
end
if isempty(placementHistory)
    return
end
savedNames = string({placementHistory.playerName});
playerIndex = find(strcmpi(savedNames,playerName),1);
if ~isempty(playerIndex)
    gamesPlayed = placementHistory(playerIndex).gamesPlayed;
end
gamesRemaining = max(0,requiredGames - gamesPlayed);
isUnlocked = gamesPlayed >= requiredGames;
end