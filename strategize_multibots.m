function [strategy,bestPoints_unique,reverse] = strategize_codonnell(hitPoints,allPoints,s_new,s,strategy,reverse)
%stategize_codonnell should take inputs of previous hits and misses, and
%determine the best possible next hit points, then limit the points to
%those.
n=height(hitPoints)
lastHit=hitPoints(end,:)
if n>1 && hitPoints(n,1)==hitPoints((n-1),1) && s_new==s && strategy>0
    %x value is the same
    fprintf('vertical ship recognized')
    bestX=lastHit(1,1);
    lastY=lastHit(1,2);
    bestPoints=[bestX,(lastY-1);bestX,(lastY+1)];
    bestPoints_unique=bestPoints(~(ismember(bestPoints,allPoints,'rows')),:);
    strategy=height(bestPoints_unique);
    reverse=reverse+1;
elseif n>1 && hitPoints(n,2)==hitPoints((n-1),2) && s_new==s && strategy>0
    %y value is the same
    fprintf('horizontal ship recognized')
    bestY=lastHit(1,2);
    lastX=lastHit(1,1);
    bestPoints=[(lastX-1),bestY;(lastX+1),bestY];
    bestPoints_unique=bestPoints(~(ismember(bestPoints,allPoints,'rows')),:);
    strategy=height(bestPoints_unique);
    reverse=reverse+1;
elseif s_new>s
    %last point on that ship
    fprintf('last point on this ship')
    strategy=0;
    bestPoints_unique=[0 0];
    reverse=0;
else
    %first hit on that ship
    fprintf('first hit on this ship')
    lastX=lastHit(1,1);
    lastY=lastHit(1,2);
    bestPoints=[(lastX-1),lastY;(lastX+1),lastY;lastX,(lastY-1);lastX,(lastY+1)];
    bestPoints_unique=bestPoints(~(ismember(bestPoints,allPoints,'rows')),:);
    strategy=height(bestPoints_unique);
    reverse=1;
end
end