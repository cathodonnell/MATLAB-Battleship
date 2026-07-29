clc;clear; close all;
size=10;
pointnum=[1:size^2];
fprintf('A grid of size %ix%i will have %i spaces.',size,size,pointnum(end))
x=[1:size]; %space by 1, start at 1.5 to place the points in the middle of the space
y=[1:size];
n=1;
for x=1:size
    for y=1:size
    points(n,:)=[n,x,y]; %vector of point [number x-coor y-corr]
    n=n+1;
    end
end
points
fid=fopen('battleship_points_multibots.txt','w');
fprintf(fid,'%2.0f\t%0.2f\t%0.2f\n',points');
fclose(fid);