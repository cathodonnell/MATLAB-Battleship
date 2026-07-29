function [top5,idx] = top5players(uniquePlayers,avgScores,percentWin)
%Top5 will return a vector of the top 5 players of the game
%   It will take into account their avgScores and percentWin to determine
%   who this is.
turnScore = max(avgScores) - avgScores;
turnScore = turnScore / max(turnScore);
%now turnScore represents the scores of the players normalized such that
%the highest number (instead of lowest) is best
winScore=percentWin; %need to convert if percent win is in % rather than decimal

combinedScore = 0.7*winScore + 0.3*turnScore; %percentWin is worth more than avgScores, can change weights later if I want

% Sort from best to worst
[~, idx] = sort(combinedScore, 'descend');

% Take top 5 or fewer if less than 5 players
nTop = min(5, length(idx));
top5 = uniquePlayers(idx(1:nTop));
end