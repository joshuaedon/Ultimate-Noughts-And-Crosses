// Game settings
int n = 3;

// Sizes
int margin = 20;

int w,h;
float minDim;
float cellSize;

// Dynamic
int turn;

PVector curSubgrid;

SmallGrid overallGame;

SmallGrid[][] detailedGame;

int overallVictor;

void setup() {
  size(750, 750);
  
  surface.setResizable(true);
  registerMethod("pre", this);
  minDim = min(width, height);
  
  reset();
}

void keyPressed() {
    if(key == 'r')
      reset();
    if(keyCode > '0' && keyCode <= '9') {
      n = keyCode - '0';
      cellSize = (minDim - 2 * margin) / (n * n);
      reset();
    }
}

void reset() {
  turn = 0;
  
  curSubgrid = new PVector(-1, -1);
  
  overallGame = new SmallGrid(n);
  
  detailedGame = new SmallGrid[n][n];
  
  // Populate the detailed game with small grids
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      detailedGame[i][j] = new SmallGrid(n);
    }
  }
  
  overallVictor = -1;
}

// Update size values when the window size is changed
void pre() {
  if (w != width || h != height) {
    // Sketch window has resized
    w = width;
    h = height;
    
    minDim = min(width, height);
    cellSize = (minDim - 2 * margin) / (n * n);
  }
}

void draw() {
  background(255);
  
  fill(0);
  textSize(15);
  text("Press numbers to change the grid size and 'r' to reset the game.", 5, height - 5);
  
  highlightAvailable();
  drawGrid();
  highlightCell();
  populateGrid();
  
  if(overallVictor > -1)
    overallGame.drawWinningLine(cellSize, margin);
}

void highlightAvailable() {
  if(overallVictor > -1)
    return;
  
  if(curSubgrid.x < 0) {
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        PVector superDims = new PVector(i, j);
        detailedGame[i][j].highlightAvailable(superDims, cellSize, margin);
      }
    }
  } else {
    detailedGame[int(curSubgrid.x)][int(curSubgrid.y)].highlightAvailable(curSubgrid, cellSize, margin);
  }
}

// Draw the lines of the grid
void drawGrid() {
  stroke(0);
  for(int i = 0; i <= (n * n); i++) {
    if(i % n == 0)
      strokeWeight(3);
    else
      strokeWeight(1);
    
    float len = i * cellSize;
    line(margin, margin + len, minDim - margin, margin + len);
  }
  for(int i = 0; i <= (n * n); i++) {
    if(i % n == 0)
      strokeWeight(3);
    else
      strokeWeight(1);
    
    float len = i * cellSize;
    line(margin + len, margin, margin + len, minDim - margin);
  }
}

// Draw the noughts and crosses in each subgrid
void populateGrid() {
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      PVector superDims = new PVector(i, j);
      detailedGame[i][j].populateGrid(overallGame.grid[i][j], superDims, cellSize, margin);
    }
  }
}

// Highlight the cell which the mouse is over (if 
void highlightCell() {
  if(overallVictor > -1)
    return;
  
  PVector mouseCoords = getMouseCoords();
  if(mouseCoords == null)
    return;
  if(!correctCell(mouseCoords))
    return;
    
  //strokeWeight(4);
  //fill(0, 0, 0, 0);
  //square(margin + mouseCoords.x * cellSize, margin + mouseCoords.y * cellSize, cellSize);
  
  // Draw symbol in grey
  stroke(200);
  noFill();
  strokeWeight(3);
  if(turn == 0) {
    float xOffset = (mouseCoords.x + 0.5) * cellSize + margin;
    float yOffset = (mouseCoords.y + 0.5) * cellSize + margin;
    
    ellipse(xOffset, yOffset, cellSize * 0.75, cellSize * 0.75);
  } else {
    float xOffset = mouseCoords.x * cellSize + margin;
    float yOffset = mouseCoords.y * cellSize + margin;
    
    line(xOffset + cellSize * 0.2, yOffset + cellSize * 0.2, xOffset + cellSize * 0.8, yOffset + cellSize * 0.8);
    line(xOffset + cellSize * 0.8, yOffset + cellSize * 0.2, xOffset + cellSize * 0.2, yOffset + cellSize * 0.8);
  }
}

void mousePressed() {
  if(overallVictor > -1)
    return;
  
  PVector mouseCoords = getMouseCoords();
  if(mouseCoords == null)
    return;
  if(!correctCell(mouseCoords))
    return;
  
  SmallGrid subGame = detailedGame[floor(mouseCoords.x / n)][floor(mouseCoords.y / n)];
  subGame.inputValue(int(mouseCoords.x) % n, int(mouseCoords.y) % n, turn);
  
  curSubgrid.x = int(mouseCoords.x) % n;
  curSubgrid.y = int(mouseCoords.y) % n;
  if(detailedGame[int(curSubgrid.x)][int(curSubgrid.y)].filled)
    curSubgrid = new PVector(-1, -1);
   
  if(overallGame.grid[floor(mouseCoords.x / n)][floor(mouseCoords.y / n)] < 0) {
    int victor = subGame.findVictor();
    if(victor >= 0) {
      overallGame.grid[floor(mouseCoords.x / n)][floor(mouseCoords.y / n)] = victor;
      
      // Check if the whole game has been won
      overallVictor = overallGame.findVictor();
      if(overallVictor > -1) {
        if(overallVictor == 0)
          println("Noughts win!");
        else
          println("Crosses win!");
        println("Press 'r' to restart");
        println("Press a number to change the size of the game");
      }
    }
  }
  
  turn = (turn + 1) % 2;
}

PVector getMouseCoords() {
  int cellX = floor((mouseX - margin) / cellSize);
  if(cellX < 0 || cellX >= (n * n))
    return null;
  
  int cellY = floor((mouseY - margin) / cellSize);
  if(cellY < 0 || cellY >= (n * n))
    return null;
   
  return new PVector(cellX, cellY);
}

// Assumes that the mouseCoords are witin the larger grid
boolean correctCell(PVector coords) {
  int xSuperCoord = floor(coords.x / n);
  int ySuperCoord = floor(coords.y / n);
  // Check valid superCoord
  if(curSubgrid.x == -1 || (xSuperCoord == curSubgrid.x && ySuperCoord == curSubgrid.y)) {
    // Check if cell is already populated
    SmallGrid subGame = detailedGame[xSuperCoord][ySuperCoord];
    int xSubCoord = int(coords.x) % n;
    int ySubCoord = int(coords.y) % n;
    if(subGame.grid[xSubCoord][ySubCoord] < 0)
      return true;
  }
  return false;
}
