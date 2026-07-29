function [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot] = checkerboard(occupiedPoints,ship1,ship2,ship3,ship4,ship5)
%CHECKERBOARD will choose random points within a checkerboard until it
%shifts to strategizing
p=1; b=0; x1=1; x2=10; y1=1; y2=10; strategy=0; reverse=0; sunkShipsBot=[0 0];
sBot=0; bestPoints_unique = [];
bHit=0; bMiss=0; bTurn=1; checkcount=0;
turnsToWin=0;
hitPointsBot_unique=[];
missedPointsBot=[];
botname='Checkerboard Bot'
gameOver=false;
while gameOver==false
    fprintf('It''s my turn!\n')
    if strategy==0
    possiblePoints = [];

    for x = x1:x2
        for y = y1:y2
            if mod(x+y,2)==0
                possiblePoints = [possiblePoints; x y];
            end
        end
    end

    if exist('allPointsBot','var') && ~isempty(allPointsBot)
        possiblePoints = possiblePoints(~ismember(possiblePoints,allPointsBot,'rows'),:);
    end

    if isempty(possiblePoints)
        possiblePoints = [];
        for x = x1:x2
            for y = y1:y2
                possiblePoints = [possiblePoints; x y];
            end
        end

        if exist('allPointsBot','var') && ~isempty(allPointsBot)
            possiblePoints = possiblePoints(~ismember(possiblePoints,allPointsBot,'rows'),:);
        end
    end

    if isempty(possiblePoints)
        error('Bot has no valid points left to choose.')
    end

    r = randi(size(possiblePoints,1));
    clickedPointBot = possiblePoints(r,:);
elseif strategy>0
    r = randi(size(bestPoints_unique,1));
    clickedPointBot = bestPoints_unique(r,:);
end
    %function takes in the point clicked and the bot ships, tells us whether it was a hit or a miss
    compare=ismember(clickedPointBot,occupiedPoints,'rows'); %does it match an occupied point?
    if compare==1
        hit=1; %if so, hit!
        bHit=bHit+1;
        hitPointsBot(bHit,:)=clickedPointBot;
        hitPointsBot_unique=unique(hitPointsBot,'rows','stable');
        allPointsBot(bTurn,:)=clickedPointBot;
        bTurn=bTurn+1;
    else
        hit=0; %if not, miss
        bMiss=bMiss+1;
        missedPointsBot(bMiss,:)=clickedPointBot;
        allPointsBot(bTurn,:)=clickedPointBot;
        bTurn=bTurn+1;
    end
    allPointsBot_unique=unique(allPointsBot,'rows','stable'); %check if it was a unique turn before limiting to strategy
    if height(allPointsBot_unique)~=height(allPointsBot) | clickedPointBot(1,1)>10 | clickedPointBot(1,1)<1 | clickedPointBot(1,2)>10 | clickedPointBot(1,2)<1
        %point selected has been selected before
        b=1;
        p=0;
        bTurn=bTurn-1;
        checkcount=checkcount+1; %bot is likely to chose a point it has chosen
        % before in a limited box, so if it struggles to find a new point,
        % send it back to the whole board
        if checkcount>100
            x1=1;
            x2=10;
            y1=1;
            y2=10;
            strategy=0;
        end
        % bot take another turn
        % this is more important for the bot because it's points are random
        % and often repeating
    end
    if hit==1 && height(allPointsBot_unique)==height(allPointsBot) %if the turn was a unique hit
        [s_newBot,s1,s2,s3,s4,s5,sunkShipsBot] = sink_check_multibots(hitPointsBot_unique,ship1,ship2,ship3,ship4,ship5,sunkShipsBot);
        [strategy,bestPoints_unique,reverse] = strategize_multibots(hitPointsBot_unique,allPointsBot_unique,s_newBot,sBot,strategy,reverse);
        if s_newBot>sBot
            sBot=s_newBot;
            fprintf('I sunk a battleship!\n')
        end
    end
    if hit==0 && height(allPointsBot_unique)==height(allPointsBot) %if the turn was a unique miss
        fprintf('I missed.\n')
        if reverse>1
            fprintf('Reverse, reverse!\n')
            [strategy,bestPoints_unique,reverse] = reverse_multibots(hitPointsBot_unique,allPointsBot_unique,s_newBot,sBot,strategy,reverse);
        end
    end
    if height(hitPointsBot_unique)>=height(occupiedPoints)
        winner=botname;
        gameOver = true;
        turnsToWin=length(allPointsBot_unique);
    end
end
end