function [hitPoint,missedPoint,p,b] = Turn_codonnell(clickedPoint,occupiedPoints,p,b)
%playerTurn_codonnell determines whether it is a hit or a miss and,
%if a hit, allows player to take another turn *recursive?
compare=ismember(clickedPoint,occupiedPoints,'rows'); %does it match an occupied point?
    if compare==1
        hit=1; %if so, hit!
    else
        hit=0; %if not, miss
    end
pi=p;
bi=b;
if hit==1 %if a hit, output the point as a hit and allow player another turn
    hitPoint=clickedPoint;
    missedPoint=[0 0];
    p=p;
    b=b;
else %if a miss, output point as a miss and switch to bot turn
    missedPoint=clickedPoint;
    hitPoint=[0 0];
    p=bi;
    b=pi;
end
end