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

import java.util.Scanner;

class KeyboardInputProvider implements InputProvider {
    private final Scanner scanner = new Scanner(System.in);
    private final BoardDimensions boardDimensions;

    public KeyboardInputProvider(BoardDimensions boardDimensions) {
        this.boardDimensions = boardDimensions;
    }

    @Override
    public BoardLocation provideNextMove(Board board) {
        int row;
        int column;
        do {
            System.out.print("Please choose row: ");
            row = scanner.nextInt();
            System.out.print("Please choose column: ");
            column = scanner.nextInt();
        } while (row < 0
                || row >= boardDimensions.getNumberOfRows()
                || column < 0
                || column >= boardDimensions.getNumberOfColumns()
                || !board.isCellEmpty(row, column));
        return new BoardLocation(row, column);
    }
}
