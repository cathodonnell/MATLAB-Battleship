close all; clc; clear;

projectFolder = fileparts(mfilename('fullpath'));
pointsFile = fullfile(projectFolder,'battleship_points_multibots.txt');
leaderboardFile = fullfile(projectFolder,'leaderboardData.mat');
leaderboardTextFile = fullfile(projectFolder,'leaderboard_data.txt');
placementHistoryFile = fullfile(projectFolder,'playerPlacementData.mat');
adaptiveUnlockGames = 10;
placementHistory = loadPlacementHistory(placementHistoryFile);

if isfile(leaderboardFile)
    load(leaderboardFile)
    fprintf('Leaderboard file loaded!\n')
    uniquePlayers;
    avgScores;
    percentWin;
    players;
    allScores;
    allOutcomes;
    z;
    c;
else
    fprintf('Leaderboard file does not exist.\n')
    uniquePlayers=strings(1,0);
    avgScores=[];
    percentWin=[];
    players=strings(1,0);
    allScores=[];
    allOutcomes=[];
    z=1;
    c=1;
end

fprintf('Welcome to battleship!\n')
pause(0.5);
instructions=input('New to battleship? Or MATLAB? Type yes here for more detailed instructions: ','s');
while strcmpi(instructions,'yes')~=1 && strcmpi(instructions,'y')~=1 && strcmpi(instructions,'no')~=1 && strcmpi(instructions,'n')~=1
    instructions=input('Error! Type yes (or y) if you would like more detailed instructions, otherwise type no ( or n): ','s');
end
if strcmpi(instructions,'yes') || strcmpi(instructions,'y')
    instructions=1;
    fprintf('You''ll receive detailed instructions throughout the game, which hopefully makes it super easy to follow!\n')
    fprintf(['Let''s start with the basics: battleship. \nEach player places 5 ships, which you can choose the orientation (vertical or hotizontal) and location of. ' ...
        '\nDuring gameplay, you''ll click points on the other player''s board to look for their ships. \nWhen you sink a ship, that will be marked on the board.\nFirst player to sink all of their opponent''s ships wins!\n'])
    fprintf(['Now MATLAB. During setup, you''ll be prompted to type a few things here. \nDon''t worry, if you mistype, we''ll let you know and you can retype your answer.' ...
        '\nFor everything on the board, you''ll be prompted to click a point on the board. \nThe points are in light blue and you''ll be told what you''re clicking for each time.\n'])
    fprintf('Have fun!\n\n')
    pause(5);
else
    instructions=0;
    fprintf('You''re a pro! Have fun!\n')
    pause(1);
end

points=load(pointsFile); %read in text file 'points' that contains all of the points in a 10x10 board
ship.name=char('Carrier','Battleship','Cruiser','Submarine','Destroyer'); %ship names, cell structure
ship.length=[5 4 3 3 2]; %vector of desired ship lengths, width is constantly one

game_style=input('Would you like to play against the computer or a two player game? Or would you like to see the bots play each other (enter bots)? ','s');
while strcmpi(game_style,'computer')~=1 && strcmpi(game_style,'single player')~=1 && strcmpi(game_style,'two player')~=1 && strcmpi(game_style,'bots')~=1
    game_style=input('Error! Please type single player, two player, or bots: ','s');
end
if strcmpi(game_style,'computer') || strcmpi(game_style,'single player')
    game_style=1;
elseif strcmpi(game_style,'two player')
    game_style=2;
elseif strcmpi(game_style,'bots')
    game_style=3;
end

if game_style==1
    if instructions==0
        fprintf('This is a single player game where you will play against the computer(me). \nThere are %1.0f ships. You''ll place yours, I will place mine, and then gameplay will begin. Good luck!\n',length(ship.length))
    else
        fprintf('You''ve chosen the single player version! That means you''ll be playing against the computer (me). \nThere are %1.0f ships. You''ll place yours, then I''ll place mine.\nYour ships will be left up, so you can watch me play. \nMine will be hidden, but I''ll let you know once I''ve chosen them. Good luck!\n',length(ship.length))
    end
    playername = strtrim(input('Enter your name: ','s'));
    [adaptiveUnlocked,previousGames,gamesRemaining] = ...
        getAdaptiveBotStatus(placementHistory,playername,adaptiveUnlockGames);
    if strcmpi(playername,'guest')
        fprintf(['Guest placement data will not be saved, so the adaptive ' ...
            'bot cannot be unlocked for this name.\n']);
    elseif adaptiveUnlocked
        fprintf(['Adaptive Bot unlocked for %s! You have %d saved ' ...
            'placement games.\n'], ...
            playername,previousGames);
    else
        fprintf(['Adaptive Bot locked for %s. You have %d of the %d ' ...
            'games needed to unlock it.\n'], ...
            playername,previousGames,adaptiveUnlockGames);
        fprintf('Play %d more game(s) using this name to unlock it.\n', ...
            gamesRemaining);
    end
    if adaptiveUnlocked
        maximumBotLevel = 7;
        fprintf(['Bot level 7 is the Adaptive Player Bot. It will use your previous ship placements against you.\n']);
    else
        maximumBotLevel = 6;
    end
    bot_level = input(sprintf( ...
        'Which level of bot would you like to play against? Enter 1-%d: ', maximumBotLevel));
    while ~isnumeric(bot_level) || ...
            ~isscalar(bot_level) || ...
            ~isfinite(bot_level) || ...
            bot_level ~= floor(bot_level) || ...
            bot_level < 1 || ...
            bot_level > maximumBotLevel
        bot_level = input(sprintf( ...
            'Error! Please enter a whole number between 1 and %d: ', maximumBotLevel));
    end
    botname=['bot'];
    player1='N/A';
    player2='N/A';
    pause(2);
    figure(1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Player Board')
    axis([0.5,10.5,0.5,10.5]) %sets axis to be 1-11 rather than starting at 0

    a=0;
    b=1; %start at row one
    fprintf('Lets place your ships!\n')
    for k=1:5
        a=a+ship.length(k);
        fprintf('Your %s is %1.0f spaces long! \n',strtrim(ship.name(k,:)),ship.length(k)) %so that the user is not confused why they are entering multiple times
        n=0;
        pause(0.5);
        ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s'); %outside of loop so that if the user misclicks they don't also have to retype
        while strcmpi(ship_orientation_i,'vertically')~=1 && strcmpi(ship_orientation_i,'horizontally')~=1 && strcmpi(ship_orientation_i,'horizontal')~=1 && strcmpi(ship_orientation_i,'vertical')~=1 && strcmpi(ship_orientation_i,'v')~=1 && strcmpi(ship_orientation_i,'h')~=1
            ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s');
        end
        while n==0 || height(occupiedPoints)~=height(occupiedPoints_unique) %while the points are invalid or repeating, rerun this section
            if strcmpi(ship_orientation_i,'vertically') || strcmpi(ship_orientation_i,'vertical') || strcmpi(ship_orientation_i,'v')
                %if user chose vertical, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the top point
                ship_orientation=1; %numerical value easier to work in function
                fprintf('Please select the point you would like to be the TOP of your ship.\n')
                [x,y]=ginput(1); %click rather than input points
                x=round(x);
                y=round(y);
            elseif strcmpi(ship_orientation_i,'horizontally') || strcmpi(ship_orientation_i,'horizontal') || strcmpi(ship_orientation_i,'h')
                %if user chose hotizontal, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the left point
                ship_orientation=-1;
                fprintf('Please select the point you would like to be the LEFT of your ship.\n')
                [x,y]=ginput(1); %this allows the user to click on the graph and then gives the function points based on their click
                x=round(x);
                y=round(y);
            end
            [shipPoints n]=ship_placement_multibots(ship_orientation,x,y,ship.length(k)); %from user entered information to a point vector and validity
            occupiedPoints(b:a,:)=shipPoints; %rows b thru a means row one past previous ship to end of ship length
            occupiedPoints_unique=unique(occupiedPoints,'rows','stable'); %if points overlap, ask for another input
            b=b+ship.length(k); %go to row after this ship length for the next (unless error)
            [b]=errorcheck_multibots(occupiedPoints,occupiedPoints_unique,n,ship_orientation,b,ship.length(k));
            %sets b back to previous if there is an error in the points selected
        end
        figure (1); %if and only if the points are valid, plot them on our board
        hold on
        plot(occupiedPoints(:,1),occupiedPoints(:,2),'Marker','square', ...
            'MarkerFaceColor','black','MarkerEdgeColor','black', ...
            'MarkerSize',20, ...
            'LineStyle','none')
        hold off
    end
    ship1=occupiedPoints((1:5),:);
    ship2=occupiedPoints((6:9),:);
    ship3=occupiedPoints((10:12),:);
    ship4=occupiedPoints((13:15),:);
    ship5=occupiedPoints((16:17),:);

    figure(2); %plot opponent board, same as beginning player board
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    grid on
    set(gca,'color', [0 0.3 0.6]);
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Opponent Board')
    axis([0.5,10.5,0.5,10.5])

    %bot ship set up
    a=0;
    b=1;
    for k=1:5
        n=0;
        a=a+ship.length(k); %bot gets the same ships as player, but doesn't need to display ship names
        while n==0 || height(occupiedPointsBot)~=height(occupiedPointsBot_unique)
            ship_orientation=round(1 + (-1 - 1) * rand()); %pick an orientation between 1 and -1
            while ship_orientation==0
                ship_orientation=round(1 + (-1 - 1) * rand()); %can't be 0
            end
            clickedPointx=round(1 + (10 - 1) * rand()); %pick a point between 1 and 10
            clickedPointy=round(1 + (10 - 1) * rand());%pick a point between 1 and 10
            [shipPointsBot n]=ship_placement_multibots(ship_orientation,clickedPointx,clickedPointy,ship.length(k));
            occupiedPointsBot(b:a,:)=shipPointsBot; %same reason as player
            occupiedPointsBot_unique=unique(occupiedPointsBot,'rows','stable'); %bot is much more likely to pick overlapping points because it is random
            b=b+ship.length(k);
            if height(occupiedPointsBot)~=height(occupiedPointsBot_unique) || n==0
                b=b-ship.length(k); %stops it from increasing the row number when repeat
            end
        end
    end
    ship1Bot=occupiedPointsBot((1:5),:);
    ship2Bot=occupiedPointsBot((6:9),:);
    ship3Bot=occupiedPointsBot((10:12),:);
    ship4Bot=occupiedPointsBot((13:15),:);
    ship5Bot=occupiedPointsBot((16:17),:);
    fprintf('I have placed my ships!\n') %as player cannot see bot ships, inform them they are placed
elseif game_style==2
    if instructions==0
        fprintf('This is a two player game. \nEach player gets %1.0f ships. Each player will place their ships, and then gameplay will begin.\n Your ships will appear while you are placing them, but you won''t be able to see them during gameplay.\n',length(ship.length))
    else
        fprintf(['You''ve chosen the two player version. \nEach player gets %1.0f ships. The first player will place their ships, then the second. \nYou will both be able to see your ships while you''re placing them, but after that they will be hidden so your opponent cannot see them.\n' ...
            'I kindly ask that you do not watch while your opponent places their ships.\n'],length(ship.length))
    end
    pause(5);
    player1=input('What is player 1''s name? ','s');
    player2=input('What is player 2''s name? ','s');
    playername='N/A';
    botname='N/A';
    figure(1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title(sprintf('%s''s Board', player1));
    axis([0.5,10.5,0.5,10.5]) %sets axis to be 1-11 rather than starting at 0

    a=0;
    b=1; %start at row one
    fprintf('%s, lets place your ships!\n',player1)
    for k=1:5
        a=a+ship.length(k);
        fprintf('Your %s is %1.0f spaces long! \n',strtrim(ship.name(k,:)),ship.length(k)) %so that the user is not confused why they are entering multiple times
        n=0;
        pause(0.5);
        ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s'); %outside of loop so that if the user misclicks they don't also have to retype
        while strcmpi(ship_orientation_i,'vertically')~=1 && strcmpi(ship_orientation_i,'horizontally')~=1 && strcmpi(ship_orientation_i,'horizontal')~=1 && strcmpi(ship_orientation_i,'vertical')~=1 && strcmpi(ship_orientation_i,'v')~=1 && strcmpi(ship_orientation_i,'h')~=1
            ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s');
        end
        while n==0 || height(occupiedPointsplayer1)~=height(occupiedPoints_uniqueplayer1) %while the points are invalid or repeating, rerun this section
            if strcmpi(ship_orientation_i,'vertically') || strcmpi(ship_orientation_i,'vertical') || strcmpi(ship_orientation_i,'v')
                %if user chose vertical, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the top point
                ship_orientation=1; %numerical value easier to work in function
                fprintf('Please select the point you would like to be the TOP of your ship.\n')
                [x,y]=ginput(1); %click rather than input points
                x=round(x);
                y=round(y);
            elseif strcmpi(ship_orientation_i,'horizontally') || strcmpi(ship_orientation_i,'horizontal') || strcmpi(ship_orientation_i,'h')
                %if user chose hotizontal, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the left point
                ship_orientation=-1;
                fprintf('Please select the point you would like to be the LEFT of your ship.\n')
                [x,y]=ginput(1); %this allows the user to click on the graph and then gives the function points based on their click
                x=round(x);
                y=round(y);
            end
            [shipPoints n]=ship_placement_multibots(ship_orientation,x,y,ship.length(k)); %from user entered information to a point vector and validity
            occupiedPointsplayer1(b:a,:)=shipPoints; %rows b thru a means row one past previous ship to end of ship length
            occupiedPoints_uniqueplayer1=unique(occupiedPointsplayer1,'rows','stable'); %if points overlap, ask for another input
            b=b+ship.length(k); %go to row after this ship length for the next (unless error)
            [b]=errorcheck_multibots(occupiedPointsplayer1,occupiedPoints_uniqueplayer1,n,ship_orientation,b,ship.length(k));
            %sets b back to previous if there is an error in the points selected
        end
        figure (1); %if and only if the points are valid, plot them on our board
        hold on
        plot(occupiedPointsplayer1(:,1),occupiedPointsplayer1(:,2),'Marker','square', ...
            'MarkerFaceColor','black','MarkerEdgeColor','black', ...
            'MarkerSize',10, ...
            'LineStyle','none')
        hold off
    end
    ship1player1=occupiedPointsplayer1((1:5),:);
    ship2player1=occupiedPointsplayer1((6:9),:);
    ship3player1=occupiedPointsplayer1((10:12),:);
    ship4player1=occupiedPointsplayer1((13:15),:);
    ship5player1=occupiedPointsplayer1((16:17),:);

    figure (1); %if and only if the points are valid, plot them on our board
    hold on
    plot(occupiedPointsplayer1(:,1),occupiedPointsplayer1(:,2),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    hold off

    figure(2);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title(sprintf('%s''s Board', player2));
    axis([0.5,10.5,0.5,10.5]) %sets axis to be 1-11 rather than starting at 0

    a=0;
    b=1; %start at row one
    fprintf('%s, lets place your ships!\n',player2)
    for k=1:5
        a=a+ship.length(k);
        fprintf('Your %s is %1.0f spaces long! \n',strtrim(ship.name(k,:)),ship.length(k)) %so that the user is not confused why they are entering multiple times
        n=0;
        pause(0.5);
        ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s'); %outside of loop so that if the user misclicks they don't also have to retype
        while strcmpi(ship_orientation_i,'vertically')~=1 && strcmpi(ship_orientation_i,'horizontally')~=1 && strcmpi(ship_orientation_i,'horizontal')~=1 && strcmpi(ship_orientation_i,'vertical')~=1 && strcmpi(ship_orientation_i,'v')~=1 && strcmpi(ship_orientation_i,'h')~=1
            ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s');
        end
        while n==0 || height(occupiedPointsplayer2)~=height(occupiedPoints_uniqueplayer2) %while the points are invalid or repeating, rerun this section
            if strcmpi(ship_orientation_i,'vertically') || strcmpi(ship_orientation_i,'vertical') || strcmpi(ship_orientation_i,'v')
                %if user chose vertical, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the top point
                ship_orientation=1; %numerical value easier to work in function
                fprintf('Please select the point you would like to be the TOP of your ship.\n')
                [x,y]=ginput(1); %click rather than input points
                x=round(x);
                y=round(y);
            elseif strcmpi(ship_orientation_i,'horizontally') || strcmpi(ship_orientation_i,'horizontal') || strcmpi(ship_orientation_i,'h')
                %if user chose hotizontal, this section creates a variable that
                %the function uses to know how to place the proceeding points,
                %it also informs the user they are choosing the left point
                ship_orientation=-1;
                fprintf('Please select the point you would like to be the LEFT of your ship.\n')
                [x,y]=ginput(1); %this allows the user to click on the graph and then gives the function points based on their click
                x=round(x);
                y=round(y);
            end
            [shipPoints n]=ship_placement_multibots(ship_orientation,x,y,ship.length(k)); %from user entered information to a point vector and validity
            occupiedPointsplayer2(b:a,:)=shipPoints; %rows b thru a means row one past previous ship to end of ship length
            occupiedPoints_uniqueplayer2=unique(occupiedPointsplayer2,'rows','stable'); %if points overlap, ask for another input
            b=b+ship.length(k); %go to row after this ship length for the next (unless error)
            [b]=errorcheck_multibots(occupiedPointsplayer2,occupiedPoints_uniqueplayer2,n,ship_orientation,b,ship.length(k));
            %sets b back to previous if there is an error in the points selected
        end
        figure (2); %if and only if the points are valid, plot them on our board
        hold on
        plot(occupiedPointsplayer2(:,1),occupiedPointsplayer2(:,2),'Marker','square', ...
            'MarkerFaceColor','black','MarkerEdgeColor','black', ...
            'MarkerSize',10, ...
            'LineStyle','none')
        hold off
    end
    ship1player2=occupiedPointsplayer2((1:5),:);
    ship2player2=occupiedPointsplayer2((6:9),:);
    ship3player2=occupiedPointsplayer2((10:12),:);
    ship4player2=occupiedPointsplayer2((13:15),:);
    ship5player2=occupiedPointsplayer2((16:17),:);

    figure (2); %if and only if the points are valid, plot them on our board
    hold on
    plot(occupiedPointsplayer2(:,1),occupiedPointsplayer2(:,2),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    hold off
elseif game_style==3
    fprintf('You''ve chosen to have all the bots play each other!');
    boardstyle=input('Would you like to place the ships or randomize it? ','s');
    while strcmpi(boardstyle,'me')~=1 && strcmpi(boardstyle,'place')~=1 && strcmpi(boardstyle,'random')~=1 && strcmpi(boardstyle,'randomize')~=1
        boardstyle=input('Error! Please enter "me" or "random": ', 's')
    end
    if strcmpi(boardstyle,'me') || strcmpi(boardstyle,'place')
        figure(1);
        plot(points(:,2),points(:,3),'Marker','square', ...
            'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
            'MarkerSize',10, ...
            'LineStyle','none')
        set(gca,'color', [0 0.3 0.6]); %ocean background color!
        grid on
        xticks(1:10);
        xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
        yticks(1:10);
        yticklabels({'1','2','3','4','5','6','7','8','9','10'})
        title('Player Board')
        axis([0.5,10.5,0.5,10.5]) %sets axis to be 1-11 rather than starting at 0

        a=0;
        b=1; %start at row one
        fprintf('Lets place some ships!\n')
        for k=1:5
            a=a+ship.length(k);
            fprintf('Your %s is %1.0f spaces long! \n',strtrim(ship.name(k,:)),ship.length(k)) %so that the user is not confused why they are entering multiple times
            n=0;
            pause(0.5);
            ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s'); %outside of loop so that if the user misclicks they don't also have to retype
            while strcmpi(ship_orientation_i,'vertically')~=1 && strcmpi(ship_orientation_i,'horizontally')~=1 && strcmpi(ship_orientation_i,'horizontal')~=1 && strcmpi(ship_orientation_i,'vertical')~=1 && strcmpi(ship_orientation_i,'v')~=1 && strcmpi(ship_orientation_i,'h')~=1
                ship_orientation_i=input('Would you like to place this ship vertically or horizontally? ','s');
            end
            while n==0 || height(occupiedPoints)~=height(occupiedPoints_unique) %while the points are invalid or repeating, rerun this section
                if strcmpi(ship_orientation_i,'vertically') || strcmpi(ship_orientation_i,'vertical') || strcmpi(ship_orientation_i,'v')
                    %if user chose vertical, this section creates a variable that
                    %the function uses to know how to place the proceeding points,
                    %it also informs the user they are choosing the top point
                    ship_orientation=1; %numerical value easier to work in function
                    fprintf('Please select the point you would like to be the TOP of your ship.\n')
                    [x,y]=ginput(1); %click rather than input points
                    x=round(x);
                    y=round(y);
                elseif strcmpi(ship_orientation_i,'horizontally') || strcmpi(ship_orientation_i,'horizontal') || strcmpi(ship_orientation_i,'h')
                    %if user chose hotizontal, this section creates a variable that
                    %the function uses to know how to place the proceeding points,
                    %it also informs the user they are choosing the left point
                    ship_orientation=-1;
                    fprintf('Please select the point you would like to be the LEFT of your ship.\n')
                    [x,y]=ginput(1); %this allows the user to click on the graph and then gives the function points based on their click
                    x=round(x);
                    y=round(y);
                end
                [shipPoints n]=ship_placement_multibots(ship_orientation,x,y,ship.length(k)); %from user entered information to a point vector and validity
                occupiedPoints(b:a,:)=shipPoints; %rows b thru a means row one past previous ship to end of ship length
                occupiedPoints_unique=unique(occupiedPoints,'rows','stable'); %if points overlap, ask for another input
                b=b+ship.length(k); %go to row after this ship length for the next (unless error)
                [b]=errorcheck_multibots(occupiedPoints,occupiedPoints_unique,n,ship_orientation,b,ship.length(k));
                %sets b back to previous if there is an error in the points selected
            end
            figure (1); %if and only if the points are valid, plot them on our board
            hold on
            plot(occupiedPoints(:,1),occupiedPoints(:,2),'Marker','square', ...
                'MarkerFaceColor','black','MarkerEdgeColor','black', ...
                'MarkerSize',20, ...
                'LineStyle','none')
            hold off
        end
        ship1=occupiedPoints((1:5),:);
        ship2=occupiedPoints((6:9),:);
        ship3=occupiedPoints((10:12),:);
        ship4=occupiedPoints((13:15),:);
        ship5=occupiedPoints((16:17),:);
    elseif strcmpi(boardstyle,'random') || strcmpi(boardstyle,'randomize')
        figure(1); %plot opponent board, same as beginning player board
        plot(points(:,2),points(:,3),'Marker','square', ...
            'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
            'MarkerSize',10, ...
            'LineStyle','none')
        grid on
        set(gca,'color', [0 0.3 0.6]);
        xticks(1:10);
        xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
        yticks(1:10);
        yticklabels({'1','2','3','4','5','6','7','8','9','10'})
        title('Opponent Board')
        axis([0.5,10.5,0.5,10.5])
    end
    if strcmpi(boardstyle,'random') || strcmpi(boardstyle,'randomize')
        %bot ship set up
        a=0;
        b=1;
        for k=1:5
            n=0;
            a=a+ship.length(k); %bot gets the same ships as player, but doesn't need to display ship names
            while n==0 || height(occupiedPointsBot)~=height(occupiedPointsBot_unique)
                ship_orientation=round(1 + (-1 - 1) * rand()); %pick an orientation between 1 and -1
                while ship_orientation==0
                    ship_orientation=round(1 + (-1 - 1) * rand()); %can't be 0
                end
                clickedPointx=round(1 + (10 - 1) * rand()); %pick a point between 1 and 10
                clickedPointy=round(1 + (10 - 1) * rand());%pick a point between 1 and 10
                [shipPointsBot n]=ship_placement_multibots(ship_orientation,clickedPointx,clickedPointy,ship.length(k));
                occupiedPointsBot(b:a,:)=shipPointsBot; %same reason as player
                occupiedPointsBot_unique=unique(occupiedPointsBot,'rows','stable'); %bot is much more likely to pick overlapping points because it is random
                b=b+ship.length(k);
                if height(occupiedPointsBot)~=height(occupiedPointsBot_unique) || n==0
                    b=b-ship.length(k); %stops it from increasing the row number when repeat
                end
            end
        end
        ship1=occupiedPointsBot((1:5),:);
        ship2=occupiedPointsBot((6:9),:);
        ship3=occupiedPointsBot((10:12),:);
        ship4=occupiedPointsBot((13:15),:);
        ship5=occupiedPointsBot((16:17),:);
        occupiedPoints=occupiedPointsBot;
        fprintf('I have placed my ships!\n') %as player cannot see bot ships, inform them they are placed
        %use bot placing boards and showing them for user
        figure (1); %if and only if the points are valid, plot them on our board
        hold on
        plot(occupiedPoints(:,1),occupiedPoints(:,2),'Marker','square', ...
            'MarkerFaceColor','black','MarkerEdgeColor','black', ...
            'MarkerSize',20, ...
            'LineStyle','none')
        hold off
    end
end
%% Gameplay
pTurn=1; bTurn=1; p1Turn=1; p2Turn=1; botPlayers=[]; botScore=[];
if game_style==1
    fprintf('\nGameplay is about to begin! \nYou''ll go first! Chose any point on my board. \nIf it is a hit, it will turn red. If it is a miss, \nit will turn white. You''ll also see my moves \nthe same way on your board. \nSunken ships will be covered with skulls. \nGood luck!\n')
    pause(3);

    p=1; %start as player turn
    b=0;
    %the player and bot have selected no points yet
    hitPoints=[0 0]; hitPoints_unique=[0 0]; missedPoints=[0 0]; allPointsPlayer=[0 0];
    missedPointsBot=[0 0]; hitPointsBot=[0 0];hitPointsBot_unique=[0 0]; allPointsBot=[0 0];
    %the player and bot have not taken any turns yet
    pHit=1; pMiss=1; pTurn=1;
    bHit=1; bMiss=1; bTurn=1;
    %the bot should first chose a point anywhere on the board, later will strategize
    x1=1; x2=10; y1=1; y2=10;
    %the bot has not hit yet and should not strategize yet
    hit=0; box=[0 0]; checkcount=0;

    s=0; sunkShips=[0 0]; strategy=0; bestPoints=[0 0]; sBot=0; sunkShipsBot=[0 0]; reverse=0;
    gameOver=false;

    %this is the gameplay section, it runs alternating player and bot turns.
    %if the number of points the player hits exceeds the number of spaces the bot
    % occupies OR the number the bot hits exceeds the number of spaces the player
    % occupies, someone has won.

    %first, get full gameplay of the selected bot
    switch bot_level
        case 1
            [~,~,~,botname,botMoveList]=randbot(occupiedPoints);
        case 2
            [~,~,~,botname,botMoveList]=mathrand(occupiedPoints);
        case 3
            [~,~,~,botname,botMoveList]=...
                originalbot(occupiedPoints,ship1,ship2,ship3,ship4,ship5);
        case 4
            [~,~,~,botname,botMoveList]=...
                checkerboard(occupiedPoints,ship1,ship2,ship3,ship4,ship5);
        case 5
            [~,~,~,botname,botMoveList]=...
                montecarloBot(occupiedPoints,ship1,ship2,ship3,...
                ship4,ship5,0);
        case 6
            [~,~,~,botname,botMoveList]=...
                probabilityDensityBot(occupiedPoints,ship1,ship2,...
                ship3,ship4,ship5,0);
        case 7
            [~,~,~,botname,botMoveList] = adaptiveBot( ...
                occupiedPoints, ship1,ship2,ship3,ship4,ship5, ...
                placementHistory,playername,0); %1 shows heatmap, 0 hides
    end
    botMoveIndex=1;
    %begin player game
    while ~gameOver
        while p==1 %player turn
            fprintf('Click, on my board, the space you would like to attack\n');
            figure(2); %limit the player to the opponent's board
            [x_attack,y_attack]=ginput(1);
            x_attack=round(x_attack);
            y_attack=round(y_attack);
            clickedPoint=[x_attack,y_attack];
            %function takes in the point clicked and the bot ships, tells us whether it was a hit or a miss
            [hitPoint missedPoint p b]=turn_multibots(clickedPoint,occupiedPointsBot,p,b);
            if p==1 %if it was a hit, player gets another turn
                hitPoints(pHit,:)=hitPoint;
                hitPoints_unique=unique(hitPoints,'rows','stable'); %store hits to see if they win!
                pHit=pHit+1;
                figure(2); %plot player turn over opponent board/ships
                hold on; %plot the hit points red! Smaller than ship size for visual aid
                plot(hitPoint(1),hitPoint(2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r');
                hold off;
                allPointsPlayer(pTurn,:)=hitPoint; %store all points so they don't repeat guesses
                pTurn=pTurn+1; %player turn has passed
                fprintf('You''ve hit a ship! You get another turn!\n')
                [s_new,s1,s2,s3,s4,s5,sunkShips]=sink_check_multibots(hitPoints_unique,ship1Bot,ship2Bot,ship3Bot,ship4Bot,ship5Bot,sunkShips);
                if s_new>s
                    s=s_new;
                    fprintf('You sunk my battleship!\n')
                    figure(2); %plot player turn over opponent board/ships
                    hold on; %plot the hit points red! Smaller than ship size for visual aid
                    text(sunkShips(:,1), sunkShips(:,2), '☠', 'FontSize', 14, 'Color', 'black','HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                    hold off;
                end
                if height(hitPoints_unique)>=height(occupiedPointsBot)
                    fprintf('Congratulations! You''ve won!\n');
                    winner=playername;
                    gameOver=true;
                    break;
                end
            end
            if b==1 %player missed :(, bot turn next
                missedPoints(pMiss,:)=missedPoint;
                pMiss=pMiss+1;
                figure(2);%plot player turn over opponent board/ships
                hold on; %plot the miss points white. Smaller than ship size for visual aid
                plot(missedPoint(1),missedPoint(2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w');
                hold off;
                pTurn=pTurn;
                allPointsPlayer(pTurn,:)=missedPoint;
                pTurn=pTurn+1; %player turn has passed
                fprintf('Miss! Bummer.\n')
            end
            allPointsPlayer_unique=unique(allPointsPlayer,'rows','stable');
            if height(allPointsPlayer_unique)~=height(allPointsPlayer) %point selected has been selected before
                p=1;
                b=0;
                pTurn=pTurn-1;
                %player take another turn
            end
        end

        while b==1 %bot turn
            fprintf('It''s my turn!\n')
            clickedPointBot=botMoveList(botMoveIndex,:);
            botMoveIndex=botMoveIndex + 1;
            %function takes in the point clicked and the bot ships, tells us whether it was a hit or a miss
            [hitPoint missedPoint p b]=turn_multibots(clickedPointBot,occupiedPoints,p,b);
            if b==1 %bot hit, another turn
                hitPointsBot(bHit,:)=hitPoint;
                hitPointsBot_unique=unique(hitPointsBot,'rows','stable');
                bHit=bHit+1;
                allPointsBot(bTurn,:)=hitPoint;
                bTurn=bTurn+1;
            end
            if p==1 %bot missed, player turn next!
                missedPointsBot(bMiss,:)=missedPoint;
                bMiss=bMiss+1;
                allPointsBot(bTurn,:)=missedPoint;
                bTurn=bTurn+1;
            end
            allPointsBot_unique=unique(allPointsBot,'rows','stable'); %check if it was a unique turn before limiting to strategy
            if height(allPointsBot_unique)~=height(allPointsBot) || clickedPointBot(1,1)>10 || clickedPointBot(1,1)<1 || clickedPointBot(1,2)>10 || clickedPointBot(1,2)<1
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
            if b==1 && height(allPointsBot_unique)==height(allPointsBot) %if the turn was a unique hit
                fprintf('I got a hit! Still my turn.\n')
                figure(1); %plot bot turn over player board
                hold on;%plot the unique points that actually count as a turn, hit points red
                plot(hitPoint(1,1),hitPoint(1,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r');
                hold off;
                pause(0.5);
                [s_newBot,s1,s2,s3,s4,s5,sunkShipsBot]=sink_check_multibots(hitPointsBot_unique,ship1,ship2,ship3,ship4,ship5,sunkShipsBot);
                if s_newBot>sBot
                    sBot=s_newBot;
                    fprintf('I sunk your battleship!\n')
                    figure(1); %plot player turn over opponent board/ships
                    hold on; %plot the hit points red! Smaller than ship size for visual aid
                    text(sunkShipsBot(:,1), sunkShipsBot(:,2), '☠', 'FontSize', 14, 'Color', 'black','HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                    hold off;
                end
            end
            if p==1 && height(allPointsBot_unique)==height(allPointsBot) %if the turn was a unique miss
                fprintf('I missed. Your turn!\n')
                figure(1); %plot bot turn over player board
                hold on; %plot the unique points that actually count as a turn, miss points white
                plot(missedPoint(1),missedPoint(2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w');
                hold off;
            end
            if height(hitPoints_unique)>=height(occupiedPointsBot)
                fprintf('Congratulations! You''ve won!\n')
                winner=playername;
                gameOver=true;
                break;
            end
            if height(hitPointsBot_unique)>=height(occupiedPoints)
                fprintf('You''ve lost! Better luck next time!\n')
                winner=botname;
                gameOver=true;
                break;
            end
        end

        %allow loop back to player turn
    end

elseif game_style==2
    fprintf('\nGameplay is about to begin! \n%s will go first! Chose any point on %s''s board. \nIf it is a hit, it will turn red. If it is a miss, \nit will turn white. %s, you will go second and click on %s''s board. \nSunken ships will be covered with skulls. \nGood luck!\n',player1,player2,player2,player1)
    pause(3);

    p1=1; %start as player turn
    p2=0;
    %the player and bot have selected no points yet
    hitPointsplayer1=[0 0]; hitPoints_uniqueplayer1=[0 0]; missedPointsplayer1=[0 0]; allPointsPlayer1=[0 0];
    missedPointsplayer2=[0 0]; hitPointsplayer2=[0 0];hitPoints_uniqueplayer2=[0 0]; allPointsPlayer2=[0 0];
    %the player and bot have not taken any turns yet
    p1Hit=1; p1Miss=1; p1Turn=1;
    p2Hit=1; p2Miss=1; p2Turn=1;
    sp1=0; s_newp1=0; sp2=0; s_newp2=0; sunkShipsp1=[0 0]; sunkShipsp2=[0 0];
    s1p1=0; s2p1=0; s3p1=0; s4p1=0; s5p1=0;
    s1p2=0; s2p2=0; s3p2=0; s4p2=0; s5p2=0;

    %this is the gameplay section, it runs alternating player1 and player2 turns.
    %if the number of points player1 hits exceeds the number of spaces
    %player2 occupies OR the number player2 hits exceeds the number of
    %spaces player1 occupies, someone has won.
    while height(hitPoints_uniqueplayer1)<height(occupiedPointsplayer2) && height(hitPoints_uniqueplayer2)<height(occupiedPointsplayer1)
        while p1==1 %player1 turn
            fprintf('Click, on your opponent''s board, the space you would like to attack\n');
            figure(2); %limit the player to the opponent's board
            [x_attack,y_attack]=ginput(1);
            x_attack=round(x_attack);
            y_attack=round(y_attack);
            clickedPoint=[x_attack,y_attack];
            %function takes in the point clicked and the bot ships, tells us whether it was a hit or a miss
            [hitPoint missedPoint p1 p2]=turn_multibots(clickedPoint,occupiedPointsplayer2,p1,p2);
            if p1==1 %if it was a hit, player1 gets another turn
                hitPointsplayer1(p1Hit,:)=hitPoint;
                hitPoints_uniqueplayer1=unique(hitPointsplayer1,'rows','stable'); %store hits to see if they win!
                p1Hit=p1Hit+1;
                figure(2); %plot player turn over opponent board/ships
                hold on; %plot the hit points red! Smaller than ship size for visual aid
                plot(hitPoint(1,1),hitPoint(1,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r');
                hold off;
                allPointsPlayer1(p1Turn,:)=hitPoint; %store all points so they don't repeat guesses
                p1Turn=p1Turn+1; %player turn has passed
                fprintf('You''ve hit a ship! You get another turn!\n')
                [s_newp1,s1p1,s2p1,s3p1,s4p1,s5p1,sunkShipsp1]=sink_check_multibots(hitPoints_uniqueplayer1,ship1player2,ship2player2,ship3player2,ship4player2,ship5player2,sunkShipsp1);
                if s_newp1>sp1
                    sp1=s_newp1;
                    fprintf('You sunk my battleship!\n')
                    figure(2); %plot player turn over opponent board/ships
                    hold on; %plot the hit points red! Smaller than ship size for visual aid
                    text(sunkShipsp1(:,1), sunkShipsp1(:,2), '☠', 'FontSize', 14, 'Color', 'black','HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                    hold off;
                end
            end
            if p2==1 %player 1 missed,player 2 turn next
                missedPointsplayer1(p1Miss,:)=missedPoint;
                p1Miss=p1Miss+1;
                figure(2);%plot player turn over opponent board/ships
                hold on; %plot the miss points white. Smaller than ship size for visual aid
                plot(missedPoint(1,1),missedPoint(1,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w');
                hold off;
                p1Turn=p1Turn;
                allPointsPlayer1(p1Turn,:)=missedPoint;
                p1Turn=p1Turn+1; %player turn has passed
                fprintf('Miss! Bummer.\n')
            end
            allPointsPlayer1_unique=unique(allPointsPlayer1,'rows','stable');
            if height(allPointsPlayer1_unique)~=height(allPointsPlayer1) %point selected has been selected before
                p1=1;
                p2=0;
                p1Turn=p1Turn-1;
                %player1 take another turn
            end
            if height(hitPoints_uniqueplayer1)>=height(occupiedPointsplayer2)
                fprintf('Congratulations, %s! You''ve won!\n Sorry, %s, you''ve lost. Better luck next time!',player1,player2)
                winner=player1;
                gameOver=true;
                break;
            end
            if height(hitPoints_uniqueplayer2)>=height(occupiedPointsplayer1)
                fprintf('Congratulations, %s! You''ve won!\n Sorry, %s, you''ve lost. Better luck next time!',player2,player1)
                winner=player2;
                gameOver=true;
                break;
            end
        end

        while p2==1 %player2 turn
            fprintf('Click, on your opponent''s board, the space you would like to attack\n');
            figure(1); %limit the player to the opponent's board
            [x_attack,y_attack]=ginput(1);
            x_attack=round(x_attack);
            y_attack=round(y_attack);
            clickedPoint=[x_attack,y_attack];
            %function takes in the point clicked and the bot ships, tells us whether it was a hit or a miss
            [hitPoint missedPoint p2 p1]=turn_multibots(clickedPoint,occupiedPointsplayer1,p2,p1);
            if p2==1 %if it was a hit, player1 gets another turn
                hitPointsplayer2(p2Hit,:)=hitPoint;
                hitPoints_uniqueplayer2=unique(hitPointsplayer2,'rows','stable'); %store hits to see if they win!
                p2Hit=p2Hit+1;
                figure(1); %plot player turn over opponent board/ships
                hold on; %plot the hit points red! Smaller than ship size for visual aid
                plot(hitPoint(1,1),hitPoint(1,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r');
                hold off;
                allPointsPlayer2(p2Turn,:)=hitPoint; %store all points so they don't repeat guesses
                p2Turn=p2Turn+1; %player turn has passed
                fprintf('You''ve hit a ship! You get another turn!\n')
                [s_newp2,s1p2,s2p2,s3p2,s4p2,s5p2,sunkShipsp2]=sink_check_multibots(hitPoints_uniqueplayer2,ship1player1,ship2player1,ship3player1,ship4player1,ship5player1,sunkShipsp2);
                if s_newp2>sp2
                    sp2=s_newp2;
                    fprintf('You sunk my battleship!\n')
                    figure(1); %plot player turn over opponent board/ships
                    hold on; %plot the hit points red! Smaller than ship size for visual aid
                    text(sunkShipsp2(:,1), sunkShipsp2(:,2), '☠', 'FontSize', 14, 'Color', 'black','HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                    hold off;
                end
            end
            if p1==1 %player 2 missed,player 2 turn next
                missedPointsplayer2(p2Miss,:)=missedPoint;
                p2Miss=p2Miss+1;
                figure(1);%plot player turn over opponent board/ships
                hold on; %plot the miss points white. Smaller than ship size for visual aid
                plot(missedPoint(1,1),missedPoint(1,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w');
                hold off;
                p2Turn=p2Turn;
                allPointsPlayer2(p2Turn,:)=missedPoint;
                p2Turn=p2Turn+1; %player turn has passed
                fprintf('Miss! Bummer.\n')
            end
            allPointsPlayer2_unique=unique(allPointsPlayer2,'rows','stable');
            if height(allPointsPlayer2_unique)~=height(allPointsPlayer2) %point selected has been selected before
                p2=1;
                p1=0;
                p2Turn=p2Turn-1;
                %player take another turn
            end
            if height(hitPoints_uniqueplayer1)>=height(occupiedPointsplayer2)
                fprintf('Congratulations, %s! You''ve won!\n Sorry, %s, you''ve lost. Better luck next time!',player1,player2)
                winner=player1;
                gameOver=true;
                close all
                break;
            end
            if height(hitPoints_uniqueplayer2)>=height(occupiedPointsplayer1)
                fprintf('Congratulations, %s! You''ve won!\n Sorry, %s, you''ve lost. Better luck next time!',player2,player1)
                winner=player2;
                gameOver=true;
                close all
                break;
            end
        end

        %allow loop back to player turn
    end
elseif game_style==3
    %read in occupied points from set up
    %send board into each bot's function
    %have each bot output a number of turns it took them to win the game
    %
    %this may need to feed out the win % section since theoretically they
    %will all be 'winning' the game since they're not technically playing
    %against anyone
    botPlayers=strings(1,0);
    player1='N/A';
    player2='N/A';
    playername='N/A';
    winner='dummy'; %I need to figure out a way to get rid of this as a player later so that it does not show in leaderboard
    
    fprintf('Starting rand function bot.\n')
    botnum=1;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=randbot(occupiedPoints);
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Rand Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off

    fprintf('Starting original bot.\n')
    botnum=2;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=originalbot(occupiedPoints,ship1,ship2,ship3,ship4,ship5)
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Original Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off

    fprintf('Starting checkerboard bot.\n')
    botnum=3;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=checkerboard(occupiedPoints,ship1,ship2,ship3,ship4,ship5)
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Checkerboard Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off

    fprintf('Starting Monte Carlo Bot.\n')
    botnum=4;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=montecarloBot(occupiedPoints,ship1,ship2,ship3,ship4,ship5,1);
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Monte Carlo Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off
    fprintf('\nFinished Monte Carlo Bot.\n')

    fprintf('Starting Probability Density Bot.\n')
    botnum=5;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=probabilityDensityBot(occupiedPoints,ship1,ship2,ship3,ship4,ship5);
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Probability Density Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off
    fprintf('\nFinished Probability Density Bot.\n')

    fprintf('Starting mathematically random bot.\n')
    botnum=6;
    [turnsToWin, hitPointsBot_unique, missedPointsBot, botname, allPointsBot]=mathrand(occupiedPoints)
    botPlayers(botnum)=[botname];
    botScore(botnum)=turnsToWin;
    fprintf('Bot %s took %f turns to finish this game.\n',botname,turnsToWin)
    bTurn=turnsToWin
    figure(botnum+1);
    plot(points(:,2),points(:,3),'Marker','square', ...
        'MarkerFaceColor','[0, 0.5, 0.7]','MarkerEdgeColor','[0, 0.5, 0.7]', ...
        'MarkerSize',10, ...
        'LineStyle','none')
    set(gca,'color', [0 0.3 0.6]); %ocean background color!
    grid on
    xticks(1:10);
    xticklabels({'1','2','3','4','5','6','7','8','9','10'}) %mark as 1-10 so the ticks make sense to the user
    yticks(1:10);
    yticklabels({'1','2','3','4','5','6','7','8','9','10'})
    title('Rand Bot Board')
    axis([0.5,10.5,0.5,10.5])
    hold on
    plot(hitPointsBot_unique(:,1),hitPointsBot_unique(:,2),'square','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r')
    plot(missedPointsBot(:,1),missedPointsBot(:,2),'square','MarkerSize',10,'MarkerFaceColor','w','MarkerEdgeColor','w')
    hold off
end

%% 
%Save single-player placement history
if game_style == 1 && ~strcmpi(playername,'guest')
    [placementHistory,totalSavedGames] = ...
        recordPlayerPlacement(placementHistory,playername,occupiedPoints,placementHistoryFile);
    fprintf(['Placement history saved for %s. Total saved games: %d\n'], playername,totalSavedGames);
    if totalSavedGames == adaptiveUnlockGames
        fprintf(['Congratulations! You have now unlocked the Adaptive Bot for this player name.\n']);
    end
end
%%
%Creating a leaderboard
%step1: relevant data
%names: player1 player2 playername botname
%turns: p1Turn p2Turn bTurn pTurn
%game_style=1 single player
%game_style=2 two player
[uniquePlayers,avgScores,percentWin,players,allScores,allOutcomes,z,c]=leaderboard( ...
    player1,player2,playername,botname,p1Turn,p2Turn,bTurn,pTurn,game_style,winner, ...
    uniquePlayers,avgScores,percentWin,players,allScores,allOutcomes,z,c,botPlayers,botScore);
[top5,idx]=top5players(uniquePlayers,avgScores,percentWin);
save(leaderboardFile,'uniquePlayers','avgScores','percentWin','players','allScores','allOutcomes','z','c')
top5;
uniquePlayers;
avgScores;
percentWin;
rankedPlayers=uniquePlayers(idx);
rankedScores=avgScores(idx);
rankedPercent=percentWin(idx);

%%
%step 2: displaying a leaderboard that looks nice

figure;
set(gcf,'Color',[0, 0.5, 0.7])
nTop=length(top5);

if nTop == 0
    text(0.5,0.5,'No leaderboard data yet','HorizontalAlignment','center','FontSize',18)
    axis off
else
    axis([0 1 0 1])
    axis off
    title('Top 5 Players','FontSize',18,'Color',[0 0.2 0.5])
    for i=1:nTop
        y=0.9 - 0.15*(i-1);
        text(0.2,y,[num2str(i) '.'],'FontSize',16,'FontWeight','bold','Color',[0 0.2 0.5])
        text(0.3,y,char(top5(i)),'FontSize',16,'Color',[0 0.2 0.5])
    end
end

leaderboardDisplay=input('Would you like to see the leaderboard for this MATLAB Battleship game? ','s');
if strcmpi(leaderboardDisplay,'yes')
    figure;
    set(gcf,'Color',[1 1 1])
    valid = uniquePlayers ~= "";
    playersDisplay = uniquePlayers(valid);
    avgDisplay = avgScores(valid);
    winDisplay = percentWin(valid);

    if ~isfile(leaderboardFile)
        text(0.5,0.5,'No leaderboard data yet','HorizontalAlignment','center','FontSize',18)
        axis off
    else
        axis([0 1 0 n+2])
        axis off
        title('Full Leaderboard--unordered','FontSize',18)
        % headers
        text(0.02,n+1,'Rank','FontSize',14,'FontWeight','bold')
        text(0.15,n+1,'Player','FontSize',14,'FontWeight','bold')
        text(0.60,n+1,'Avg Turns','FontSize',14,'FontWeight','bold')
        text(0.90,n+1,'Win %','FontSize',14,'FontWeight','bold')
        % rows
        for i=1:n
            y=n+1-i;
            text(0.02,y,num2str(i),'FontSize',13)
            text(0.10,y,char(playersDisplay(i)),'FontSize',13)
            text(0.60,y,sprintf('%.2f',avgDisplay(i)),'FontSize',13)
            text(0.90,y,sprintf('%.1f',100*winDisplay(i)),'FontSize',13)
        end
    end
end

if strcmpi(leaderboardDisplay,'yes')
    figure;
    set(gcf,'Color',[1 1 1])
    valid=rankedPlayers ~= "";
    playersDisplay=rankedPlayers(valid);
    avgDisplay=rankedScores(valid);
    winDisplay=rankedPercent(valid);
    n=length(playersDisplay);

    if ~isfile(leaderboardFile)
        text(0.5,0.5,'No leaderboard data yet','HorizontalAlignment','center','FontSize',18)
        axis off
    else
        axis([0 1 0 n+2])
        axis off
        title('Full Leaderboard--ranked','FontSize',18)
        % headers
        text(0.02,n+1,'Rank','FontSize',14,'FontWeight','bold')
        text(0.15,n+1,'Player','FontSize',14,'FontWeight','bold')
        text(0.60,n+1,'Avg Turns','FontSize',14,'FontWeight','bold')
        text(0.90,n+1,'Win %','FontSize',14,'FontWeight','bold')
        % rows
        for i=1:n
            y=n+1-i;
            text(0.02,y,num2str(i),'FontSize',13)
            text(0.10,y,char(playersDisplay(i)),'FontSize',13)
            text(0.60,y,sprintf('%.2f',avgDisplay(i)),'FontSize',13)
            text(0.90,y,sprintf('%.1f',100*winDisplay(i)),'FontSize',13)
        end
    end
end

% Specific player statistics
playerStats=input( ...
    'Would you like to see the statistics for a specific player? ','s');
if strcmpi(playerStats,'yes') || strcmpi(playerStats,'y')
    fprintf('Which player(s) would you like to see statistics for?\n')
    fprintf('If entering multiple players, separate the names with commas.\n')
    statsFor=input('Enter here: ','s');
    % Convert the entered names into a list
    requestedPlayers=strtrim(split(string(statsFor),','));
    % Find requested players without requiring matching capitalization
    R=[];
    for i=1:length(requestedPlayers)
        playerIndex=find(strcmpi(uniquePlayers,requestedPlayers(i)));
        if ~isempty(playerIndex)
            R=[R playerIndex(1)];
        end
    end

    % Remove repeated indices while preserving the entered order
    R=unique(R,'stable');
    figure('Position',[150 200 900 450]);
    set(gcf,'Color',[1 1 1])
    if isempty(R)
        text(0.5,0.5,'Player not found', ...
            'HorizontalAlignment','center', ...
            'FontSize',18)
        axis off
    else

        playersDisplay=uniquePlayers(R);
        avgDisplay=avgScores(R);
        winDisplay=percentWin(R);
        n=length(R);
        axis([0 1 0 n+2])
        axis off
        title('Specific Player Statistics', ...
            'FontSize',18, ...
            'FontWeight','bold')
        % Column positions
        xRank  =0.06;
        xPlayer=0.16;
        xAvg   =0.53;
        xWin   =0.70;
        xGames =0.89;
        % Header row
        text(xRank,n+1,'Rank', ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center')
        text(xPlayer,n+1,'Player', ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','left')
        text(xAvg,n+1,'Avg Turns', ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center')
        text(xWin,n+1,'Win %', ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center')
        text(xGames,n+1,'Games Played', ...
            'FontSize',14, ...
            'FontWeight','bold', ...
            'HorizontalAlignment','center')
        % Player rows
        for i=1:n
            y=n+1-i;
            currentPlayer=playersDisplay(i);
            % Count only games belonging to this individual player
            numGames=sum(strcmpi(players,currentPlayer));
            text(xRank,y,sprintf('%d',R(i)), ...
                'FontSize',13, ...
                'HorizontalAlignment','center')
            text(xPlayer,y,char(currentPlayer), ...
                'FontSize',12, ...
                'HorizontalAlignment','left', ...
                'Interpreter','none')
            text(xAvg,y,sprintf('%.2f',avgDisplay(i)), ...
                'FontSize',13, ...
                'HorizontalAlignment','center')
            text(xWin,y,sprintf('%.1f',100*winDisplay(i)), ...
                'FontSize',13, ...
                'HorizontalAlignment','center')
            text(xGames,y,sprintf('%d',numGames), ...
                'FontSize',13, ...
                'HorizontalAlignment','center')
        end
    end
end

% Auto-save leaderboard data if any player has >= 100 games (testing bots)

% Count games per player
uniqueList=unique(players);
gameCounts=zeros(size(uniqueList));

for i=1:length(uniqueList)
    gameCounts(i)=sum(players == uniqueList(i));
end

% Check condition
if any(gameCounts >= 100)

    filename=leaderboardTextFile;
    fid=fopen(filename,'w');

    if fid == -1
        error('Could not open %s for writing.', filename);
    end

    % Header row
    fprintf(fid, 'Game,Player,Turns,Outcome\n');

    % Raw game data
    for i=1:length(players)
        fprintf(fid, '%d,%s,%d,%d\n', ...
            i, char(players(i)), allScores(i), allOutcomes(i));
    end

    fclose(fid);

    fprintf('\nLeaderboard data saved to %s as row-formatted data.\n', filename);
end
