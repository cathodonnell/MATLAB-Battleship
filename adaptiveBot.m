function [turnsToWin,hitPointsBotUnique,missedPointsBot, ...
    botName,allPointsBot] = adaptiveBot( ...
    occupiedPoints,ship1,ship2,ship3,ship4,ship5, ...
    placementHistory,playerName,showHeatmap)
%ADAPTIVEBOT Learns a player's historical ship-placement tendencies.

if nargin < 10
    showHeatmap = 0;
end

[playerHeatmap,gamesPlayed] = buildPlayerHeatmap(placementHistory,playerName);

if gamesPlayed == 0
    error('No saved placement history exists for player "%s".',playerName);
end

strategy = 0;
reverse = 0;
sunkShipsBot = [0 0];
sBot = 0;
sNewBot = 0;
bestPointsUnique = zeros(0,2);

bHit = 0;
bMiss = 0;
bTurn = 1;
turnsToWin = 0;

hitPointsBot = zeros(0,2);
hitPointsBotUnique = zeros(0,2);
missedPointsBot = zeros(0,2);
allPointsBot = zeros(0,2);

botName = 'Adaptive Player Bot';
gameOver = false;

while ~gameOver
    shipSunk = zeros(1,5);

    if ~isempty(hitPointsBotUnique)
        shipSunk(1) = all(ismember(ship1,hitPointsBotUnique,'rows'));
        shipSunk(2) = all(ismember(ship2,hitPointsBotUnique,'rows'));
        shipSunk(3) = all(ismember(ship3,hitPointsBotUnique,'rows'));
        shipSunk(4) = all(ismember(ship4,hitPointsBotUnique,'rows'));
        shipSunk(5) = all(ismember(ship5,hitPointsBotUnique,'rows'));
    end

    sunkHitPoints = zeros(0,2);
    if shipSunk(1), sunkHitPoints = [sunkHitPoints; ship1]; end %#ok<AGROW>
    if shipSunk(2), sunkHitPoints = [sunkHitPoints; ship2]; end %#ok<AGROW>
    if shipSunk(3), sunkHitPoints = [sunkHitPoints; ship3]; end %#ok<AGROW>
    if shipSunk(4), sunkHitPoints = [sunkHitPoints; ship4]; end %#ok<AGROW>
    if shipSunk(5), sunkHitPoints = [sunkHitPoints; ship5]; end %#ok<AGROW>

    activeHitPoints = zeros(0,2);
    for pointIndex = 1:size(hitPointsBotUnique,1)
        currentHit = hitPointsBotUnique(pointIndex,:);
        if isempty(sunkHitPoints) || ~ismember(currentHit,sunkHitPoints,'rows')
            activeHitPoints(end+1,:) = currentHit; %#ok<AGROW>
        end
    end

    if strategy == 0
        [clickedPointBot,combinedGrid] = adaptiveDensityMove( ...
            activeHitPoints,hitPointsBotUnique,missedPointsBot, ...
            shipSunk,playerHeatmap,gamesPlayed);
    else
        if isempty(bestPointsUnique)
            [clickedPointBot,combinedGrid] = adaptiveDensityMove( ...
                activeHitPoints,hitPointsBotUnique,missedPointsBot, ...
                shipSunk,playerHeatmap,gamesPlayed);
            strategy = 0;
        else
            usedPoints = unique([hitPointsBotUnique; missedPointsBot],'rows');
            availableTargets = zeros(0,2);

            for pointIndex = 1:size(bestPointsUnique,1)
                currentPoint = bestPointsUnique(pointIndex,:);
                insideBoard = currentPoint(1) >= 1 && currentPoint(1) <= 10 && ...
                    currentPoint(2) >= 1 && currentPoint(2) <= 10;
                notUsed = isempty(usedPoints) || ...
                    ~ismember(currentPoint,usedPoints,'rows');

                if insideBoard && notUsed
                    availableTargets(end+1,:) = currentPoint; %#ok<AGROW>
                end
            end

            availableTargets = unique(availableTargets,'rows');

            if isempty(availableTargets)
                [clickedPointBot,combinedGrid] = adaptiveDensityMove( ...
                    activeHitPoints,hitPointsBotUnique,missedPointsBot, ...
                    shipSunk,playerHeatmap,gamesPlayed);
                strategy = 0;
            else
                clickedPointBot = availableTargets(randi(size(availableTargets,1)),:);
                combinedGrid = zeros(10,10);
            end
        end
    end

    if showHeatmap == 1 && strategy == 0
        plotMonteCarloHeatmap(combinedGrid,hitPointsBotUnique, ...
            missedPointsBot,clickedPointBot);
    end

    isHit = ismember(clickedPointBot,occupiedPoints,'rows');

    if isHit
        hit = 1;
        bHit = bHit + 1;
        hitPointsBot(bHit,:) = clickedPointBot;
        hitPointsBotUnique = unique(hitPointsBot,'rows','stable');
    else
        hit = 0;
        bMiss = bMiss + 1;
        missedPointsBot(bMiss,:) = clickedPointBot;
    end

    allPointsBot(bTurn,:) = clickedPointBot;
    bTurn = bTurn + 1;
    allPointsBotUnique = unique(allPointsBot,'rows','stable');

    if size(allPointsBotUnique,1) ~= size(allPointsBot,1)
        error('Adaptive Bot attempted a repeated shot.');
    end

    if hit == 1
        [sNewBot,~,~,~,~,~,sunkShipsBot] = sink_check_multibots( ...
            hitPointsBotUnique,ship1,ship2,ship3,ship4,ship5,sunkShipsBot);

        [strategy,bestPointsUnique,reverse] = strategize_multibots( ...
            hitPointsBotUnique,allPointsBotUnique,sNewBot,sBot,strategy,reverse);

        if sNewBot > sBot
            sBot = sNewBot;
        end
    elseif reverse > 1
        [strategy,bestPointsUnique,reverse] = reverse_multibots( ...
            hitPointsBotUnique,allPointsBotUnique,sNewBot,sBot,strategy,reverse);
    end

    if size(hitPointsBotUnique,1) >= size(occupiedPoints,1)
        gameOver = true;
        turnsToWin = size(allPointsBotUnique,1);
    end
end
end
