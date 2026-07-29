function [occupiedPointsBot, validBoard] = randomBoardConsistentWithData(shipLengths,activeHitPoints,missedPointsBot)

validBoard = 0;
occupiedPointsBot = zeros(0,2);

attemptCount = 0;
maxAttempts = 100;

while validBoard==0 && attemptCount<maxAttempts
    attemptCount = attemptCount + 1;

    occupiedPointsBot = zeros(0,2);
    occupiedPointsBot_unique = zeros(0,2);
    a=0;
    b=1;

    for k = 1:length(shipLengths)
        n=0;
        a=a+shipLengths(k);

        while n==0 || size(occupiedPointsBot,1)~=size(occupiedPointsBot_unique,1)
            ship_orientation=round(1 + (-1 - 1) * rand());
            while ship_orientation==0
                ship_orientation=round(1 + (-1 - 1) * rand());
            end

            clickedPointx=round(1 + (10 - 1) * rand());
            clickedPointy=round(1 + (10 - 1) * rand());

            [shipPointsBot,n] = ship_placement_multibots(ship_orientation,clickedPointx,clickedPointy,shipLengths(k));

            occupiedPointsBot(b:a,:) = shipPointsBot;
            occupiedPointsBot_unique = unique(occupiedPointsBot,'rows','stable');

            b = b + shipLengths(k);

            if size(occupiedPointsBot,1)~=size(occupiedPointsBot_unique,1) || n==0
                b = b - shipLengths(k);
            end
        end
    end

    if ~isempty(missedPointsBot)
        if any(ismember(missedPointsBot,occupiedPointsBot,'rows'))
            continue
        end
    end

    if ~isempty(activeHitPoints)
        if ~all(ismember(activeHitPoints,occupiedPointsBot,'rows'))
            continue
        end
    end

    validBoard = 1;
end

end