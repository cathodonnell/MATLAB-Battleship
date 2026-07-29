function [uniquePlayers,avgScores,percentWin,players,allScores,allOutcomes,z,c] = leaderboard( ...
    player1,player2,playername,botname,p1Turn,p2Turn,bTurn,pTurn,game_style,winner, ...
    uniquePlayers,avgScores,percentWin,players,allScores,allOutcomes,z,c,botPlayers,botScore)
%Leaderboard will develop a leaderboard for this Battleship game
%   It will store the top 5 fastest scores of the entire game and it will
%   store average # of turns to win and % wins for each unique player.
%   Include 'guest' option in instructions if a player does not want their
%   data stored.

if game_style==1
    %single player game
    players(z)=playername;
    players(z+1)=botname;
    allScores(z)=pTurn;
    allScores(z+1)=bTurn;
    if ismember(players(z),uniquePlayers)
        %this player has played before
        uniquePlayers=uniquePlayers;
        c=c;
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to this player
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games this player has played
        relevant_scores=allScores(R_allGames);
        avgScores(R)=mean(relevant_scores); %replace their score in the average score matrix to include the scpre from this game
    else
        %this player is new
        uniquePlayers(c)=playername;
        avgScores(c)=pTurn;
        allScores(z)=pTurn;
        c=c+1;
    end
    if ismember(players(z+1),uniquePlayers)
        %this bot has played before
        uniquePlayers=uniquePlayers;
        c=c;
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to this player
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games this player has played
        relevant_scores=allScores(R_allGames);
        avgScores(R)=mean(relevant_scores); %replace their score in the average score matrix to include the scpre from this game
    else
        %this bot is new
        uniquePlayers(c)=botname;
        avgScores(c)=bTurn;
        allScores(z+1)=bTurn;
        c=c+1;
    end
    if strcmpi(winner,playername)
        %player won the game
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to the player
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games the player has played
        allOutcomes(z)=1;
        allOutcomes(z+1)=0;
        relevant_outcomes=allOutcomes(R_allGames);
        p1=sum(relevant_outcomes)./numel(relevant_outcomes);
        percentWin(R)=p1;
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games the player has played
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to the player
        relevant_outcomes_bot=allOutcomes(R_allGames);
        p2=sum(relevant_outcomes_bot)./numel(relevant_outcomes_bot);
        percentWin(R)=p2;
    else
        %bot won the game
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to the bot
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games the bot has played
        allOutcomes(z)=0;
        allOutcomes(z+1)=1;
        relevant_outcomes=allOutcomes(R_allGames);
        p1=sum(relevant_outcomes)./numel(relevant_outcomes);
        percentWin(R)=p1;
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games the player has played
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to the player
        relevant_outcomes_player=allOutcomes(R_allGames);
        p2=sum(relevant_outcomes_player)./numel(relevant_outcomes_player);
        percentWin(R)=p2;
    end
    z=z+2;
elseif game_style==2
    %two player game
    players(z)=player1;
    players(z+1)=player2;
    allScores(z)=p1Turn;
    allScores(z+1)=p2Turn;
    if ismember(players(z),uniquePlayers)
        %this player has played before
        uniquePlayers=uniquePlayers;
        c=c;
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to this player
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games this player has played
        relevant_scores=allScores(R_allGames);
        avgScores(R)=mean(relevant_scores); %replace their score in the average score matrix to include the scpre from this game
    else
        %this player is new
        uniquePlayers(c)=player1;
        avgScores(c)=p1Turn;
        allScores(z)=p1Turn;
        c=c+1;
    end
    if ismember(players(z+1),uniquePlayers)
        %this bot has played before
        uniquePlayers=uniquePlayers;
        c=c;
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to this player
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games this player has played
        relevant_scores=allScores(R_allGames);
        avgScores(R)=mean(relevant_scores); %replace their score in the average score matrix to include the scpre from this game
    else
        %this bot is new
        uniquePlayers(c)=player2;
        avgScores(c)=p2Turn;
        allScores(z+1)=p2Turn;
        c=c+1;
    end
    if strcmpi(winner,player1)
        %player1 won the game
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to the player
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games the player has played
        allOutcomes(z)=1;
        allOutcomes(z+1)=0;
        relevant_outcomes=allOutcomes(R_allGames);
        p1=sum(relevant_outcomes)./numel(relevant_outcomes);
        percentWin(R)=p1;
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games the player has played
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to the player
        relevant_outcomes_bot=allOutcomes(R_allGames);
        p2=sum(relevant_outcomes_bot)./numel(relevant_outcomes_bot);
        percentWin(R)=p2;
    else
        %player2 won the game
        R=find(strcmp(uniquePlayers,players(z+1))); %R will return which row # in uniquePlayers corresponds to the bot
        R_allGames=find(strcmp(players,players(z+1))); %R_allGames will return all of the rows that correspond to the games the bot has played
        allOutcomes(z)=0;
        allOutcomes(z+1)=1;
        relevant_outcomes=allOutcomes(R_allGames);
        p1=sum(relevant_outcomes)./numel(relevant_outcomes);
        percentWin(R)=p1;
        R_allGames=find(strcmp(players,players(z))); %R_allGames will return all of the rows that correspond to the games the player has played
        R=find(strcmp(uniquePlayers,players(z))); %R will return which row # in uniquePlayers corresponds to the player
        relevant_outcomes_player=allOutcomes(R_allGames);
        p2=sum(relevant_outcomes_player)./numel(relevant_outcomes_player);
        percentWin(R)=p2;
    end
    z=z+2;
elseif game_style==3
    %bot comparison game
    nBots = length(botPlayers);

    players(z:z+nBots-1) = botPlayers;
    allScores(z:z+nBots-1) = botScore;
    allOutcomes(z:z+nBots-1) = 0; % bots get 0% win so they stay off player leaderboard

    for j = 1:nBots
        currentBot = botPlayers(j);
        currentScore = botScore(j);

        if ismember(currentBot,uniquePlayers)
            %this bot has played before
            R = find(strcmp(uniquePlayers,currentBot)); % row in uniquePlayers
            R_allGames = find(strcmp(players,currentBot)); % all games for this bot
            relevant_scores = allScores(R_allGames);
            avgScores(R) = mean(relevant_scores);
        else
            %this bot is new
            uniquePlayers(c) = currentBot;
            avgScores(c) = currentScore;
            percentWin(c) = 0;
            c = c + 1;
        end

        %update win percent for this bot
        R = find(strcmp(uniquePlayers,currentBot));
        R_allGames = find(strcmp(players,currentBot));
        relevant_outcomes = allOutcomes(R_allGames);
        percentWin(R) = sum(relevant_outcomes)./numel(relevant_outcomes);
    end

    z = z + nBots;
end

end