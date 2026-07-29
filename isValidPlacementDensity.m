function valid = isValidPlacementDensity(placement, activeHitPoints, missedPointsBot)
% isValidPlacementDensity checks whether a candidate ship placement is
% consistent with the current known misses and active hits.

valid = true;

% cannot overlap a known miss
if ~isempty(missedPointsBot)
    for k = 1:size(missedPointsBot,1)
        if ismember(missedPointsBot(k,:), placement, 'rows')
            valid = false;
            return;
        end
    end
end

% no active hits -> any miss-free placement is valid
if isempty(activeHitPoints)
    return;
end

% if there is 1 active hit, placement must include it
if size(activeHitPoints,1) == 1
    if ~ismember(activeHitPoints(1,:), placement, 'rows')
        valid = false;
    end
    return;
end

% if there are multiple active hits:
% require placement to include at least one hit, and if hits are aligned,
% require consistency with that alignment

containsHit = false;
for k = 1:size(activeHitPoints,1)
    if ismember(activeHitPoints(k,:), placement, 'rows')
        containsHit = true;
        break;
    end
end

if ~containsHit
    valid = false;
    return;
end

sameRow = all(activeHitPoints(:,1) == activeHitPoints(1,1));
sameCol = all(activeHitPoints(:,2) == activeHitPoints(1,2));

% determine placement orientation
if all(placement(:,1) == placement(1,1))
    placementIsHorizontal = true;
    placementIsVertical = false;
elseif all(placement(:,2) == placement(1,2))
    placementIsHorizontal = false;
    placementIsVertical = true;
else
    placementIsHorizontal = false;
    placementIsVertical = false;
end

if sameRow && ~placementIsHorizontal
    valid = false;
    return;
end

if sameCol && ~placementIsVertical
    valid = false;
    return;
end

end