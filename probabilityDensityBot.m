function [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot] = probabilityDensityBot(occupiedPoints,ship1,ship2,ship3,ship4,ship5,showHeatmap)
% probabilityDensityBot uses deterministic placement counting to create a
% probability density heatmap, then chooses the highest-probability shot.

if nargin < 7
    showHeatmap = 0;
end

p=1;
b=0;
strategy=0;
reverse=0;
sunkShipsBot=[0 0];
sBot=0;
s_newBot=0;
bestPoints_unique=[];

bHit=0;
bMiss=0;
bTurn=1;
turnsToWin=0;

hitPointsBot=zeros(0,2);
hitPointsBot_unique=zeros(0,2);
missedPointsBot=zeros(0,2);
allPointsBot=zeros(0,2);

botname='Probability Density Bot';
gameOver=false;

while gameOver==false

    % which ships are sunk?
    shipSunk = zeros(1,5);

    if ~isempty(hitPointsBot_unique)
        shipSunk(1) = all(ismember(ship1,hitPointsBot_unique,'rows'));
        shipSunk(2) = all(ismember(ship2,hitPointsBot_unique,'rows'));
        shipSunk(3) = all(ismember(ship3,hitPointsBot_unique,'rows'));
        shipSunk(4) = all(ismember(ship4,hitPointsBot_unique,'rows'));
        shipSunk(5) = all(ismember(ship5,hitPointsBot_unique,'rows'));
    end

    sunkHitPoints = zeros(0,2);

    if shipSunk(1)==1
        sunkHitPoints = [sunkHitPoints; ship1];
    end
    if shipSunk(2)==1
        sunkHitPoints = [sunkHitPoints; ship2];
    end
    if shipSunk(3)==1
        sunkHitPoints = [sunkHitPoints; ship3];
    end
    if shipSunk(4)==1
        sunkHitPoints = [sunkHitPoints; ship4];
    end
    if shipSunk(5)==1
        sunkHitPoints = [sunkHitPoints; ship5];
    end

    %'active; hits
    activeHitPoints = zeros(0,2);

    if ~isempty(hitPointsBot_unique)
        for k = 1:size(hitPointsBot_unique,1)
            currentHit = hitPointsBot_unique(k,:);
            if isempty(sunkHitPoints) || ~ismember(currentHit,sunkHitPoints,'rows')
                activeHitPoints = [activeHitPoints; currentHit];
            end
        end
    end

    if strategy==0
        [clickedPointBot, probGrid] = probabilityDensityMove(activeHitPoints, hitPointsBot_unique, missedPointsBot, shipSunk);
    else
        if isempty(bestPoints_unique)
            [clickedPointBot, probGrid] = probabilityDensityMove(activeHitPoints, hitPointsBot_unique, missedPointsBot, shipSunk);
            strategy = 0;
        else
            usedPoints = unique([hitPointsBot_unique; missedPointsBot],'rows');
            availableTargets = zeros(0,2);

            for k = 1:size(bestPoints_unique,1)
                currentPoint = bestPoints_unique(k,:);

                if currentPoint(1)>=1 && currentPoint(1)<=10 && currentPoint(2)>=1 && currentPoint(2)<=10
                    if isempty(usedPoints) || ~ismember(currentPoint,usedPoints,'rows')
                        availableTargets = [availableTargets; currentPoint];
                    end
                end
            end

            availableTargets = unique(availableTargets,'rows');

            if isempty(availableTargets)
                [clickedPointBot, probGrid] = probabilityDensityMove(activeHitPoints, hitPointsBot_unique, missedPointsBot, shipSunk);
                strategy = 0;
            else
                r = randi(size(availableTargets,1));
                clickedPointBot = availableTargets(r,:);
                probGrid = zeros(10,10);
            end
        end
    end
showHeatmap=0;
    if showHeatmap==1 && strategy==0
        plotMonteCarloHeatmap(probGrid,hitPointsBot_unique,missedPointsBot,clickedPointBot);
    end

    compare = ismember(clickedPointBot,occupiedPoints,'rows');

    if compare==1
        hit=1;
        b=1;
        p=0;
        bHit=bHit+1;
        hitPointsBot(bHit,:)=clickedPointBot;
        hitPointsBot_unique=unique(hitPointsBot,'rows','stable');
        allPointsBot(bTurn,:)=clickedPointBot;
        bTurn=bTurn+1;
    else
        hit=0;
        b=0;
        p=1;
        bMiss=bMiss+1;
        missedPointsBot(bMiss,:)=clickedPointBot;
        allPointsBot(bTurn,:)=clickedPointBot;
        bTurn=bTurn+1;
    end

    allPointsBot_unique=unique(allPointsBot,'rows','stable');

    if size(allPointsBot_unique,1)~=size(allPointsBot,1)
        bTurn=bTurn-1;
    end

    if hit==1 && size(allPointsBot_unique,1)==size(allPointsBot,1)
        [s_newBot,~,~,~,~,~,sunkShipsBot] = sink_check_multibots(hitPointsBot_unique,ship1,ship2,ship3,ship4,ship5,sunkShipsBot);
        [strategy,bestPoints_unique,reverse] = strategize_multibots(hitPointsBot_unique,allPointsBot_unique,s_newBot,sBot,strategy,reverse);

        if s_newBot>sBot
            sBot=s_newBot;
        end
    end

    if hit==0 && size(allPointsBot_unique,1)==size(allPointsBot,1)
        if reverse>1
            [strategy,bestPoints_unique,reverse] = reverse_multibots(hitPointsBot_unique,allPointsBot_unique,s_newBot,sBot,strategy,reverse);
        end
    end

    if size(hitPointsBot_unique,1)>=size(occupiedPoints,1)
        gameOver = true;
        turnsToWin = size(allPointsBot_unique,1);
    end
end

end