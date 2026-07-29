function [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot] = randbot(occupiedPoints)
%randbot will choose completely random points using MATLAB's rand function
%   It will serve as a baseline to compare other methods with to evaluate
%   their efficiency.

p=1; b=0; x1=1; x2=10; y1=1; y2=10;
bHit=0; bMiss=0; bTurn=1; checkcount=0;
turnsToWin=0;
hitPointsBot_unique=[];
missedPointsBot=[];
botname='Rand Function'
gameOver=false;
while gameOver==false
    clickedPointx=round(x1 + (x2 - x1) * rand()); %pick a point between x1 and x2
    clickedPointy=round(y1 + (y2 - y1) * rand());%pick a point between y1 and y2
    clickedPointBot=[clickedPointx clickedPointy]; %format

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
        end
    end
    if height(hitPointsBot_unique)>=height(occupiedPoints)
        %this bot has completed the game
        gameOver = true;
        turnsToWin=bTurn;
    end
end
end