function placementHistory = loadPlacementHistory(placementHistoryFile)
%LOADPLACEMENTHISTORY Loads saved player ship-placement history.
% If no saved file exists, an empty placement-history structure is
% returned.

if isfile(placementHistoryFile)
    savedData = load(placementHistoryFile,'placementHistory');
    if isfield(savedData,'placementHistory')
        placementHistory = savedData.placementHistory;
    else
        warning(['The placement-history file exists but does not contain ' ...
                 'a variable named placementHistory.']);
        placementHistory = createEmptyHistory();
    end
else
    placementHistory = createEmptyHistory();
end
end

function placementHistory = createEmptyHistory()
%CREATEEMPTYHISTORY Creates an empty placement-history structure.
placementHistory = struct( ...
    'playerName',{}, ...
    'placements',{}, ...
    'gamesPlayed',{});

end