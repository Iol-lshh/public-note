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

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class ComputerInputProvider implements InputProvider {
    public final BoardDimensions dimensions;
    private final Random random = new Random();

    public ComputerInputProvider(BoardDimensions dimensions) {
        this.dimensions = dimensions;
    }

    @Override
    public BoardLocation provideNextMove(Board board) {
        List<BoardLocation> availableCells = new ArrayList<>();

        for (int r = 0; r < dimensions.getNumberOfRows(); r++) {
            for (int c = 0; c < dimensions.getNumberOfColumns(); c++) {
                if (board.isCellEmpty(r, c)) {
                    availableCells.add(new BoardLocation(r, c));
                }
            }
        }

        int chosenCell = random.nextInt(availableCells.size());

        return availableCells.get(chosenCell);
    }
}
