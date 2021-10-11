class SmallGrid {
  int[][] grid;
  
  boolean filled = false;
  PVector winStart;
  PVector winEnd;
  
  SmallGrid(int n) {
    grid = new int[n][n];
    
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        grid[i][j] = -1;
      }
    }
  }
  
  void printValues() {
    for(int i = 0; i < grid.length; i++) {
      for(int j = 0; j < grid[0].length; j++) {
        print(grid[i][j] + ", ");
      }
      println("");
    }
  }
  
  void highlightAvailable(PVector superDims, float cellSize, int margin, float highlightIntensity) {
    noStroke();
    color white = color(255);
    color blue = color(207, 238, 250);
    fill(lerpColor(white, blue, highlightIntensity));
    
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        if(grid[i][j] < 0) {
          float xOffset = (superDims.x * n + i) * cellSize + margin;
          float yOffset = (superDims.y * n + j) * cellSize + margin;
          
          square(xOffset, yOffset, cellSize);
        }
      }
    }
  }
  
  void populateGrid(int won, PVector superDims, float cellSize, int margin) {
    int n = grid.length;
    
    if(won < 0 && !filled)
      stroke(0);
    else
      stroke(200);
    strokeWeight(3);
    noFill();
    
    // Draw small symbols
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        if(grid[i][j] == 0) {
          float xOffset = (superDims.x * n + i + 0.5) * cellSize + margin;
          float yOffset = (superDims.y * n + j + 0.5) * cellSize + margin;
          
          ellipse(xOffset, yOffset, cellSize * 0.75, cellSize * 0.75);
        } else if(grid[i][j] == 1) {
          float xOffset = (superDims.x * n + i) * cellSize + margin;
          float yOffset = (superDims.y * n + j) * cellSize + margin;
          
          line(xOffset + cellSize * 0.2, yOffset + cellSize * 0.2, xOffset + cellSize * 0.8, yOffset + cellSize * 0.8);
          line(xOffset + cellSize * 0.8, yOffset + cellSize * 0.2, xOffset + cellSize * 0.2, yOffset + cellSize * 0.8);
        }
      }
    }
    
    if(won >= 0) {
      strokeWeight(4);
      
      float xStart = (superDims.x * n + winStart.x + 0.5) * cellSize + margin;
      float yStart = (superDims.y * n + winStart.y + 0.5) * cellSize + margin;
      float xEnd = (superDims.x * n + winEnd.x + 0.5) * cellSize + margin;
      float yEnd = (superDims.y * n + winEnd.y + 0.5) * cellSize + margin;
      
      line(xStart, yStart, xEnd, yEnd);
    }
    
    // Draw large symbols if one player has how the subgrid
    if(won == 0) {
      stroke(0);
      strokeWeight(5);
      
      float xOffset = (superDims.x + 0.5) * cellSize * n + margin;
      float yOffset = (superDims.y + 0.5) * cellSize * n + margin;
      
      ellipse(xOffset, yOffset, cellSize * n * 0.75, cellSize * n * 0.75);
    } else if(won == 1) {
      stroke(0);
      strokeWeight(5);
      
      float xOffset = superDims.x * n * cellSize + margin;
      float yOffset = superDims.y * n * cellSize + margin;
      
      line(xOffset + cellSize * n * 0.2, yOffset + cellSize * n * 0.2, xOffset + cellSize * n * 0.8, yOffset + cellSize * n * 0.8);
      line(xOffset + cellSize * n * 0.8, yOffset + cellSize * n * 0.2, xOffset + cellSize * n * 0.2, yOffset + cellSize * n * 0.8);
    }
      
  }
  
  void inputValue(int i, int j, int turn) {
    grid[i][j] = turn;
    checkFilled();
  }
  
  void checkFilled() {
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        if(grid[i][j] < 0)
          return;
      }
    }
    filled = true;
  }
  
  int findVictor() {
    for(int i = 0; i < grid.length; i++) {
      int player = grid[i][0];
      // Skip if no player has taken the fisrt cell of the column
      if(player < 0)
        continue;
      boolean match = true;
      for(int j = 1; j < grid[0].length; j++) {
        if(grid[i][j] != player){
          match = false;
          break;
        }
      }
      if(match) {
        winStart = new PVector(i, -0.4);
        winEnd = new PVector(i, grid.length - 0.6);
        return player;
      }
    }
    
    for(int j = 0; j < grid[0].length; j++) {
      int player = grid[0][j];
      // Skip if no player has taken the fisrt cell of the row
      if(player < 0)
        continue;
      boolean match = true;
      for(int i = 1; i < grid.length; i++) {
        if(grid[i][j] != player){
          match = false;
          break;
        }
      }
      if(match) {
        winStart = new PVector(-0.4, j);
        winEnd = new PVector(grid[0].length - 0.6, j);
        return player;
      }
    }
    
    int player = grid[0][0];
    // Skip if no player has taken the fisrt cell of the column
    if(player >= 0) {
      boolean match = true;
      for(int i = 1; i < grid.length; i++) {
        if(grid[i][i] != player){
          match = false;
          break;
        }
      }
      if(match) {
        winStart = new PVector(-0.4, -0.4);
        winEnd = new PVector(grid.length - 0.6, grid.length - 0.6);
        return player;
      }
    }
    
    player = grid[0][grid.length - 1];
    // Skip if no player has taken the fisrt cell of the column
    if(player >= 0) {
      boolean match = true;
      for(int i = 1; i < grid.length; i++) {
        if(grid[i][grid.length - i - 1] != player){
          match = false;
          break;
        }
      }
      if(match) {
        winStart = new PVector(-0.4, grid.length - 0.6);
        winEnd = new PVector(grid.length - 0.6, -0.4);
        return player;
      }
    }
    
    return -1;
  }
  
  void drawWinningLine(float cellSize, int margin) {
    stroke(0);
    strokeWeight(8);
    
    float xStart = (winStart.x + 0.5) * cellSize * n + margin;
    float yStart = (winStart.y + 0.5) * cellSize * n + margin;
    float xEnd = (winEnd.x + 0.5) * cellSize * n + margin;
    float yEnd = (winEnd.y + 0.5) * cellSize * n + margin;
    
    line(xStart, yStart, xEnd, yEnd);
  }
}
