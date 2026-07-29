function [shipPoints,n] = ship_placement_codonnell(ship_orientation,x,y,shiplength)
%ship_placement takes an input of the orientation and outputs the ship location
%as a vector of points
if ship_orientation==1 %if vertical
  for k=1:shiplength
      shipPoints(k,:)=[x,y-(k-1)]; %move downward
      if shipPoints(k,2)<1 %if get off board, error
          n=0;
          fprintf('Error! You''ve entered a point that is too low.')
      else
          n=1;
      end
  end
elseif ship_orientation==-1 %if horizontal
      for k=1:shiplength
          shipPoints(k,:)=[x+(k-1),y]; %move right
          if shipPoints(k,1)>10 %if off board, error
              n=0;
              fprintf('Error! You''ve entered a point that it too far right.')
          else
              n=1;
          end
      end
  end
end
