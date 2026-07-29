clear; clc; close all;

%% Read leaderboard data
filename = 'leaderboard_data.txt';

data = readtable(filename);

% Convert Player to string for easier grouping
data.Player = string(data.Player);

%% Get unique bots
bots = unique(data.Player);
numBots = length(bots);

%% Summary statistics
summaryTable = table();

for i = 1:numBots
    bot = bots(i);

    botRows = data.Player == bot;
    turns = data.Turns(botRows);
    outcomes = data.Outcome(botRows);

    avgTurns = mean(turns);
    stdTurns = std(turns);
    bestTurns = min(turns);
    worstTurns = max(turns);
    gamesPlayed = length(turns);
    winRate = 100 * mean(outcomes);

    newRow = table(bot, gamesPlayed, avgTurns, stdTurns, bestTurns, worstTurns, winRate, ...
        'VariableNames', {'Bot','GamesPlayed','AvgTurns','StdDev','Best','Worst','WinRatePercent'});

    summaryTable = [summaryTable; newRow];
end

%% Sort by best average turns
summaryTable = sortrows(summaryTable, 'AvgTurns');

disp('===== BOT PERFORMANCE SUMMARY =====');
disp(summaryTable);

%% Save summary table
writetable(summaryTable, 'bot_summary_stats.txt');

fprintf('\nSummary statistics saved to bot_summary_stats.txt\n');

%% Bar graph: average turns with error bars
figure;
bar(summaryTable.AvgTurns);
hold on;
errorbar(1:numBots, summaryTable.AvgTurns, summaryTable.StdDev, ...
    'k.', 'LineWidth', 1.5);

xticks(1:numBots);
xticklabels(summaryTable.Bot);
xtickangle(30);

ylabel('Average Turns to Win');
title('Average Turns to Win by Bot');
grid on;

%% Histogram: distribution of turns
figure;
hold on;

for i = 1:numBots
    bot = bots(i);
    turns = data.Turns(data.Player == bot);

    histogram(turns, 'DisplayStyle', 'stairs', 'LineWidth', 1.5);
end

xlabel('Turns to Win');
ylabel('Number of Games');
title('Distribution of Turns to Win');
legend(bots, 'Location', 'best');
grid on;

%% Manual "boxplot-style" visualization (no toolbox needed)
figure;
hold on;

for i = 1:numBots
    bot = bots(i);
    turns = data.Turns(data.Player == bot);

    % Compute quartiles manually
    q1 = prctile(turns,25);
    q2 = median(turns);
    q3 = prctile(turns,75);
    minVal = min(turns);
    maxVal = max(turns);

    x = i;

    % Draw vertical line (whiskers)
    plot([x x], [minVal maxVal], 'k-', 'LineWidth', 1.5);

    % Draw box (Q1 to Q3)
    rectangle('Position',[x-0.2, q1, 0.4, q3-q1], ...
              'EdgeColor','k','LineWidth',1.5);

    % Draw median line
    plot([x-0.2 x+0.2], [q2 q2], 'r-', 'LineWidth', 2);
end

xticks(1:numBots);
xticklabels(bots);
xtickangle(30);

ylabel('Turns to Win');
title('Turns to Win Spread by Bot (Manual Boxplot)');
grid on;

%% Running average plot
figure;
hold on;

for i = 1:numBots
    bot = bots(i);
    turns = data.Turns(data.Player == bot);

    runningAvg = cumsum(turns) ./ (1:length(turns))';

    plot(runningAvg, 'LineWidth', 1.5);
end

xlabel('Game Number');
ylabel('Running Average Turns');
title('Running Average Stability Over Time');
legend(bots, 'Location', 'northeastoutside');
xlim([0,100])
grid on;

%% Best/worst comparison graph
figure;

bar(categorical(summaryTable.Bot), [summaryTable.Best summaryTable.Worst]);

ylabel('Turns');
title('Best and Worst Game by Bot');
legend('Best Game','Worst Game', 'Location', 'northeast');
grid on;

%% Manual pairwise t-tests (no toolbox)
fprintf('\n===== PAIRWISE T-TEST RESULTS (MANUAL) =====\n');

for i = 1:numBots
    for j = i+1:numBots
        bot1 = bots(i);
        bot2 = bots(j);

        turns1 = data.Turns(data.Player == bot1);
        turns2 = data.Turns(data.Player == bot2);

        % Sample sizes
        n1 = length(turns1);
        n2 = length(turns2);

        % Means
        m1 = mean(turns1);
        m2 = mean(turns2);

        % Variances
        v1 = var(turns1);
        v2 = var(turns2);

        % Pooled standard deviation
        sp = sqrt(((n1-1)*v1 + (n2-1)*v2) / (n1+n2-2));

        % t-statistic
        t = (m1 - m2) / (sp * sqrt(1/n1 + 1/n2));

        % Degrees of freedom
        df = n1 + n2 - 2;

        % Approximate p-value (two-tailed using normal approx)
        p = 2 * (1 - 0.5 * (1 + erf(abs(t)/sqrt(2))));

        % Decision (approx threshold)
        alpha = 0.05;

        fprintf('\n%s vs %s\n', bot1, bot2);
        fprintf('t = %.3f, approx p = %.5f\n', t, p);

        if p < alpha
            fprintf('Result: statistically significant difference\n');
        else
            fprintf('Result: no statistically significant difference\n');
        end
    end
end
