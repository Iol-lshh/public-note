/*
 *  MIT License
 *
 *  Copyright (c) 2020 Michael Pogrebinsky - Java Reflection - Master Class
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

package game.internal;

import game.Game;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class TicTacToeGame implements Game {
    private static final int NUMBER_OF_PLAYERS = 2;
    private final Random random = new Random();
    private final List<Sign> playerSigns = Arrays.asList(Sign.X, Sign.Y);

    private final Board board;
    private final List<Player> players;
    private final BoardPrinter printer;

    TicTacToeGame(Board board,
                  BoardPrinter printer,
                  HumanPlayer humanPlayer,
                  ComputerPlayer computerPlayer) {
        this.board = board;
        this.printer = printer;
        this.players = Arrays.asList(humanPlayer, computerPlayer);
    }

    public void startGame() {
        Sign winner;
        int nextPlayerIndex = random.nextInt(NUMBER_OF_PLAYERS);

        Player player;
        printer.print(board);
        do {
            nextPlayerIndex = NUMBER_OF_PLAYERS - nextPlayerIndex - 1;

            player = players.get(nextPlayerIndex);

            Sign playerSign = playerSigns.get(nextPlayerIndex);

            player.play(board, playerSign);

            winner = board.checkWinner();

            printer.print(board);
        } while (!board.isBoardFull() && winner == Sign.EMPTY);

        if (winner != Sign.EMPTY) {
            System.out.println(String.format("Winner is : %s", player.getPlayerName()));
        } else {
            System.out.println("Game over! Nobody won.");
        }

    }
}
