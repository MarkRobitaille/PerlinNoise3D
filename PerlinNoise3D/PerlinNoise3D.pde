
Player player;
final boolean useOctaves = true; 
final int enviromentType = 0; // 0 for Mountains, 1 for Islands, 2 for grasslands, 3 for deserts
final int CHUNK_SIZE = 500;
final int CHUNK_DETAIL = 15;
Chunk[][] chunks;

final float maxHeight = 600.0;

// Used to base movement off time
int prevTime;
int diffTime;

void setup() {
  size(800, 640, P3D);
  strokeWeight(1);
  stroke(75,75,75);
  smooth(4);
  frustum(-float(width)/height, float(width)/height, 1, -1, 1.5, 5000);
  resetMatrix();
  prevTime=millis();

  chunks = new Chunk[10][10];
  
  for (int z = 0; z<chunks.length; z++) {
      for (int x = 0; x<chunks[z].length; x++) {
        chunks[z][x] = new Chunk(enviromentType,x*CHUNK_SIZE,z*CHUNK_SIZE);
      }
  }
  
  player = new Player();
}

void draw() {
  background(135, 205, 235);
  diffTime = millis() - prevTime;
  prevTime = millis();
  player.updatePlayer(diffTime);
  
  rotateX(radians(player.playerRotationX));
  rotateY(radians(player.playerRotationY));
  translate(-player.playerLocation.x, -player.playerLocation.y, -player.playerLocation.z);

  fill(255,255,255);
  for (int z = 0; z<10*CHUNK_SIZE; z+=CHUNK_SIZE) {
    for (int x = 0; x<10*CHUNK_SIZE; x+=CHUNK_SIZE) {
      beginShape(QUADS);
      vertex(x-CHUNK_SIZE/2.0, 0, z-CHUNK_SIZE/2.0, 0, 1);
      vertex(x+CHUNK_SIZE/2.0, 0, z-CHUNK_SIZE/2.0, 1, 1);
      vertex(x+CHUNK_SIZE/2.0, 0, z+CHUNK_SIZE/2.0, 1, 0);
      vertex(x-CHUNK_SIZE/2.0, 0, z+CHUNK_SIZE/2.0, 0, 0);
      endShape();
    }
  }
  
  color(150,150,150);
  for (int z = 0; z<chunks.length; z++) {
    for (int x = 0; x<chunks[z].length; x++) {
      chunks[z][x].drawChunk();
    }
  }
}

void keyPressed() {
  if (key == CODED) { // Arrow keys
    switch(keyCode) {
      case LEFT:
        player.turnLeft = true;
        break;
      case RIGHT:
        player.turnRight = true;
        break;
      case UP:
        player.turnUp = true;
        break;
      case DOWN:
        player.turnDown = true;
        break;
    }
  } else { 
    switch(key) {
      case 'a':
        player.moveLeft = true;
        break;
      case 'd':
        player.moveRight = true;
        break;
      case 'w':
        player.moveForwards = true;
        break;
      case 's':
        player.moveBackwards = true;
        break;
      case 'q':
        player.flyDown = true;
        break;
      case 'e':
        player.flyUp = true;
        break;
    }
  }
}

void keyReleased() {
  if (key == CODED) { // Arrow keys
    switch(keyCode) {
      case LEFT:
        player.turnLeft = false;
        break;
      case RIGHT:
        player.turnRight = false;
        break;
      case UP:
        player.turnUp = false;
        break;
      case DOWN:
        player.turnDown = false;
        break;
    }
  } else { 
    switch(key) {
      case 'a':
        player.moveLeft = false;
        break;
      case 'd':
        player.moveRight = false;
        break;
      case 'w':
        player.moveForwards = false;
        break;
      case 's':
        player.moveBackwards = false;
        break;
      case 'q':
        player.flyDown = false;
        break;
      case 'e':
        player.flyUp = false;
        break;
    }  
  }
}

class Player {
  PVector playerLocation;
  float playerRotationX;
  float playerRotationY;
  final float movementSpeed = 0.25;
  final float rotationSpeed = 0.1;
  boolean moveForwards;
  boolean moveBackwards;
  boolean moveLeft;
  boolean moveRight;
  boolean turnUp;
  boolean turnDown;
  boolean turnLeft;
  boolean turnRight;
  boolean flyUp;
  boolean flyDown;

  public Player() {
    playerLocation = new PVector(1,maxHeight,1);
    playerRotationX = 0.0;
    //playerRotationY = 0.0;
    playerRotationY = 135.0;
    moveForwards = false;
    moveBackwards = false;
    moveLeft = false;
    moveRight = false;
    turnUp = false;
    turnDown = false;
    turnLeft = false;
    turnRight = false;
    flyUp = false;
    flyDown = false;
  }
  
  void updatePlayer(float diffTime) {
    if (moveLeft) {
      playerLocation.z -= cos(radians(playerRotationY-90.0))*movementSpeed*diffTime;
      playerLocation.x += sin(radians(playerRotationY-90.0))*movementSpeed*diffTime;
    }
    
    if (moveRight) {
      playerLocation.z -= cos(radians(playerRotationY+90.0))*movementSpeed*diffTime;
      playerLocation.x += sin(radians(playerRotationY+90.0))*movementSpeed*diffTime;
    }
    
    if (moveForwards) {
      playerLocation.z -= cos(radians(playerRotationY))*movementSpeed*diffTime;
      playerLocation.x += sin(radians(playerRotationY))*movementSpeed*diffTime;
    } 
    
    if (moveBackwards) {
      playerLocation.z += cos(radians(playerRotationY))*movementSpeed*diffTime;
      playerLocation.x -= sin(radians(playerRotationY))*movementSpeed*diffTime;
    }
    
    if (turnLeft) {
      playerRotationY = (playerRotationY - diffTime * rotationSpeed) % 360;
    }
    
    if (turnRight) {
      playerRotationY = (playerRotationY + diffTime * rotationSpeed) % 360;
    }
    
    if (turnUp) {
      playerRotationX = (playerRotationX - diffTime/2.0 * rotationSpeed) % 360;
    }
    
    if (turnDown) {
      playerRotationX = (playerRotationX + diffTime/2.0 * rotationSpeed) % 360;
    }
    
    if (flyUp) {
      playerLocation.y += movementSpeed*diffTime;
    }
    
    if (flyDown) {
      playerLocation.y -= movementSpeed*diffTime;
    }
  }
}



class Chunk {
  int type;
  float frequency; // Detail level of noise
  float amplitude; // Range of noise
  float lacunarity; // For inscreases in frequency with octaves
  float persistence; // For inscreases in amplitude with octaves

  float[][] heightMap;
  float x, z; // Coordinates for the center of the chunk
  
  float waterHeight;
  float sandHeight;
  float grassHeight;
  float gravelHeight;
  
  public Chunk(int type, float chunkX, float chunkZ) {
    // Default values
    sandHeight = maxHeight*(2.5/8.0);
    grassHeight = maxHeight*(4.0/10.0);
    gravelHeight = maxHeight*(5.0/7.0); 
    
    // Determine enviroment type's variable settings
    this.type = type;
    switch(type) {
      case 1: // Island
        frequency = 0.004;
        amplitude = maxHeight*(1.8/3.0);
        lacunarity = 1.005;
        persistence = 0.9; 
        waterHeight = sandHeight-maxHeight/30.0;
        break;
      case 2: // Grassland
        frequency = 0.002;
        amplitude = gravelHeight-maxHeight/5.0;
        lacunarity = 1.0;
        persistence = 1.2; 
        sandHeight = maxHeight*(1.5/8.0);
        waterHeight = sandHeight-maxHeight/80.0;
        break;
      case 3: // Desert
        frequency = 0.0035;
        amplitude = grassHeight-maxHeight/30.0;
        lacunarity = 1.0;
        persistence = 0.8; 
        //sandHeight = maxHeight*(1.5/8.0);
        waterHeight = sandHeight-maxHeight/4.25;
        break;
      default: // Mountain
        frequency = 0.005;
        amplitude = maxHeight;
        lacunarity = 1.0;
        persistence = 0.5;  
        waterHeight = sandHeight-maxHeight/50.0;
    }
    
    this.x = chunkX;
    this.z= chunkZ;
  
    // Define the height map
    heightMap = new float[CHUNK_DETAIL][CHUNK_DETAIL];
    generateHeightMap();
  }
  
  void generateHeightMap() {
    if (useOctaves) {
      for (int row=0; row<heightMap.length; row++) {
        for (int col=0; col<heightMap[row].length; col++) {
          heightMap[row][col] = generateOctaveNoise(x + ((float)col/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 
            z + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 8); //baseHeight + generateOctaveNoise((float)i/width, 8);
          //System.out.println(y + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
        }
      }
    } else {
      for (int row=0; row<heightMap.length; row++) {
        for (int col=0; col<heightMap[row].length; col++) {
        heightMap[row][col] = generateNoise(x + ((float)col/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 
            z + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0); //baseHeight + generateNoise((float)i/width);
        }
      }
    }
  }
  
  float generateOctaveNoise(float x, float z, int octaves) {
    return generateOctaveNoise(x, z, octaves, frequency, amplitude);
  }
  
  float generateOctaveNoise(float x, float z, int octaves, float frequency, float amplitude) {
    float localFrequency = frequency;
    float localAmplitude = 1;
    float noiseValue = 0;
    float amplitudeSum = 0;
     for (int i=0; i<octaves; i++) {
        noiseValue += noise(x * localFrequency + 1.0, z * localFrequency + 1.0) * localAmplitude;
        amplitudeSum += localAmplitude;
        localFrequency *= lacunarity;
        localAmplitude *= persistence;
     }
     return noiseValue/amplitudeSum * amplitude; // To scale to our intended amplitude
  } 
  
  
  float generateNoise(float x, float z) {
    return noise(x * frequency, z * frequency) * amplitude;
  }
  
  void drawChunk() {
    //Treat height map as a grid, drawing each square on the  grid as two triangles (see below). Then, use the height map values on the Y axis.
    //   ___
    //  |\  |
    //  | \ |
    //  |__\|

     float average1, average2;
    
     for (int row=0; row<heightMap.length-1; row++) {
        for (int col=0; col<heightMap[row].length-1; col++) {
          //Upper Right Triangle
          // Find average height of vertices in triangle
          average1 = (heightMap[row][col]+heightMap[row][col+1]+heightMap[row+1][col+1])/3.0;
          //Determine color by average height of 3 points
          setColorByHeight(average1);
         
          //Draw vertices
          beginShape(TRIANGLES);
          vertex(x + ((float)col/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0,
            heightMap[row][col], z + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          vertex(x + ((float)(col+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0,
            heightMap[row][col+1], z + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          vertex(x + ((float)(col+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0,
            heightMap[row+1][col+1], z + ((float)(row+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          endShape();
          // Lower left triangle
          // Find average height of vertices in triangle
          average2 = (heightMap[row][col]+heightMap[row+1][col+1]+heightMap[row+1][col])/3.0;
          //Determine color by average height of 3 points
          setColorByHeight(average2);
          
          //Draw vertices
          beginShape(TRIANGLES);
          vertex(x + ((float)col/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 
            heightMap[row][col], z + ((float)row/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          vertex(x + ((float)(col+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 
            heightMap[row+1][col+1], z + ((float)(row+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          vertex(x + ((float)col/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0, 
            heightMap[row+1][col], z + ((float)(row+1.0)/(CHUNK_DETAIL-1.0))*(float)CHUNK_SIZE - (float)CHUNK_SIZE/2.0);
          endShape();
       }
    }
    
    // Draw water
    fill(0,120,190);
    beginShape(QUADS);
    vertex(x - (float)CHUNK_SIZE/2.0, waterHeight, z -(float)CHUNK_SIZE/2.0);
    vertex(x - (float)CHUNK_SIZE/2.0, waterHeight, z + (float)CHUNK_SIZE/2.0);
    vertex(x + (float)CHUNK_SIZE/2.0, waterHeight, z + (float)CHUNK_SIZE/2.0);
    vertex(x + (float)CHUNK_SIZE/2.0, waterHeight, z - (float)CHUNK_SIZE/2.0);
     endShape();
  }
  
  void setColorByHeight(float triY) {
    if (triY<=sandHeight) { // sand
      if (type==3 || type==1) {
        fill(255,255,200); 
      } else {
        fill(100,50,0);
      }
    } else if (triY>sandHeight && triY<=grassHeight) { // grass
      fill(0,130,0);
    } else if (triY>grassHeight  && triY<=gravelHeight) { // gravel/stone
      fill(135,125,110);
    } else if (triY>gravelHeight) { // ice
      fill(248,248,255);
    } 
  }
  
}
