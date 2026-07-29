function [b] = errorcheck_codonnell(occupiedPoints,occupiedPoints_unique,n,carrier_orientation,b,shiplength)
%errorcheck inputs information about previously places ships and current
%placement to check for errors and tell user what the error is
if height(occupiedPoints)~=height(occupiedPoints_unique)
    fprintf('Error! You''ve placed a ship overlapping with another!\n') %tell player the issue
    b=b-shiplength;
end
if n==0 & carrier_orientation==1
    fprintf('Error! You''ve placed the ship too low!\n') %tell player the issue
    b=b-shiplength;
end
if n==0 & carrier_orientation==-1
    fprintf('Error! You''ve placed the ship too far right!\n') %tell player the issue
    b=b-shiplength;
end
end