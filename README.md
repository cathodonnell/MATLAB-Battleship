# MATLAB-Battleship

An interactive Battleship game and computational search project written in
MATLAB.

The project began as a MATLAB coding assignment featuring a playable
Battleship game and one computer opponent, now called the **Original Bot**.
The program was later expanded into a platform for comparing different search
strategies, including random search, structured hunt-and-target methods,
Monte Carlo simulation, probability-density analysis, and player-specific
adaptive learning.

The current version supports:

- Single-player gameplay
- Local two-player gameplay
- Automated bot comparison
- Seven computer opponents
- Persistent leaderboard statistics
- Player-specific ship-placement history
- An unlockable adaptive bot
- Optional probability heatmap visualization

---

## Project Motivation

Battleship can be treated as a search problem under uncertainty. A bot does
not know where the ships are located and must use the results of previous
guesses to reduce the remaining search space.

The bots in this project represent a progression from uninformed search to
increasingly informed decision-making:

1. Random coordinate selection
2. Structured search patterns
3. Local reasoning after a hit
4. Monte Carlo estimation
5. Exhaustive probability-density analysis
6. Player-specific historical learning

The project was used to investigate how algorithm design affects the number
of turns required to locate and sink all five ships.

---

## Game Configuration

The game uses a standard 10 × 10 Battleship board with five ships:

| Ship | Length |
|---|---:|
| Carrier | 5 |
| Battleship | 4 |
| Cruiser | 3 |
| Submarine | 3 |
| Destroyer | 2 |

Ships must:

- Remain inside the board
- Be horizontal or vertical
- Not overlap another ship

A complete fleet occupies 17 grid cells.

---

## Bot Levels

### Level 1 — MATLAB Random Bot

Uses MATLAB-generated random coordinates as an uninformed search baseline.

The bot does not use previous hits or misses to improve its next selection.
Its purpose is to demonstrate the performance of a simple random search.

### Level 2 — Mathematically Random Bot

Uses a mathematically generated pseudorandom sequence rather than directly
using MATLAB's normal random coordinate selection.

This bot also acts as an uninformed baseline and does not use the current
board state to predict ship locations.

### Level 3 — Original Hunt-and-Target Bot

The first strategy-based bot developed for the project.

During the hunt phase, it searches broadly for a ship. After detecting a hit,
it switches to target mode and searches neighboring cells. Once the ship's
orientation is inferred, it continues along that direction until the ship is
sunk.

### Level 4 — Checkerboard Bot

Uses an alternating checkerboard pattern during the hunt phase.

Because every ship is at least two cells long, searching one color of a
checkerboard guarantees that every ship crosses at least one searched cell.
After detecting a hit, the bot switches to the same local targeting logic used
by the hunt-and-target strategy.

### Level 5 — Monte Carlo Bot

Generates multiple possible ship placements that are consistent with the
known hits and misses.

The bot counts how frequently each grid cell is occupied across these sampled
configurations and attacks one of the highest-probability cells.

The benchmarked version used 50 simulations per move, providing a compromise
between probability accuracy and computation time.

### Level 6 — Probability Density Bot

Systematically evaluates valid placements for the remaining ships rather than
estimating them from a random sample.

Each valid placement contributes to a 10 × 10 probability-density grid. The
bot then attacks one of the highest-scoring cells that has not already been
selected.

Because it evaluates the legal search space more completely, it generally
requires fewer turns than the Monte Carlo bot, but it also requires more
computation per move.

### Level 7 — Adaptive Player Bot

The Adaptive Player Bot was added after the original six-bot comparison.

It unlocks after 10 completed single-player games under the same player name.
The game stores that player's previous ship coordinates and builds a
player-specific placement heatmap.

The bot combines:

- General legal-placement probability
- The player's historically preferred cells
- Regional clustering tendencies
- Current-game hits and misses
- Remaining ship lengths

This allows it to learn tendencies such as:

- Frequently placing ships near edges
- Favoring particular rows or columns
- Grouping ships in one region
- Reusing similar board layouts

The current board is saved only after the game ends, so the adaptive bot
cannot access the exact placement it is presently attacking.

---

## Experimental Comparison

Six bots were evaluated using the same randomly generated board for each
trial. This paired-board approach ensured that every bot faced identical ship
placements, so performance differences resulted from the search strategy
rather than board difficulty.

The reported experiment used:

- 1,013 games per bot
- Identical boards for every bot
- A 10 × 10 board
- Standard ship lengths of 5, 4, 3, 3, and 2
- No repeated guesses
- Immediate termination after the final ship was sunk
- Number of turns required to win as the primary metric

The Adaptive Player Bot was developed after this experiment and is not
included in the table.

## Benchmark Results

| Bot | Average Turns | Standard Deviation | Best Game | Worst Game |
|---|---:|---:|---:|---:|
| Probability Density | **47.43** | 9.90 | 25 | 83 |
| Monte Carlo | 49.04 | 10.84 | **22** | 85 |
| Original Hunt-and-Target | 69.48 | 17.25 | 27 | 100 |
| Checkerboard | 72.28 | 18.26 | 30 | 100 |
| Mathematically Random | 94.05 | 5.09 | 61 | 100 |
| MATLAB Random Function | 94.58 | 6.04 | 63 | 101 |

### Main Findings

The probability-based bots clearly outperformed the random and
rule-based strategies.

The Probability Density Bot required approximately:

- 2.61% fewer turns than the Monte Carlo Bot
- 31.73% fewer turns than the Original Bot
- 34.38% fewer turns than the Checkerboard Bot
- 49.57% fewer turns than the MATLAB Random Bot

The Monte Carlo and Probability Density Bots also produced tighter
performance distributions than the Original and Checkerboard Bots.

The random bots had relatively small standard deviations, but this reflected
consistently poor performance rather than efficiency.

Pairwise t-tests in the project report found nearly all bot differences to be
statistically significant at `p < 0.01`. The difference between the Monte
Carlo and Probability Density Bots was also statistically significant in the
larger dataset.

---

## Interpretation

The results demonstrate that using information from previous guesses greatly
improves search efficiency.

The strategies can be viewed as increasing levels of board awareness:

| Strategy Type | Information Used |
|---|---|
| Random | No board-state reasoning |
| Hunt-and-target | Local information after a hit |
| Checkerboard | Board structure plus local targeting |
| Monte Carlo | Sampled global probability |
| Probability Density | Systematic global probability |
| Adaptive | Global probability plus player history |

The Probability Density Bot performed best in number of turns because it
evaluated legal ship placements more completely than the sampled Monte Carlo
approach.

This improvement comes with a computational tradeoff. Random and
checkerboard bots execute quickly, while Monte Carlo and probability-density
methods require additional calculations on every move.

The project therefore demonstrates a broader engineering principle:

> More informed algorithms can reduce search effort, but often require
> additional computational effort.

---

## Running the Game

1. Download or clone this repository.
2. Keep all project files in the same folder.
3. Open the folder in MATLAB.
4. Run:

```matlab
Battleship
