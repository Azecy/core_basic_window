#include "../raylib/src/raylib.h"
#define PATH_ICON "./assets/img/gem_blue.png"

int main(void)
{
/*********************************************************************
* Initialize
*********************************************************************/
	const unsigned int screenWidth = 800;
	const unsigned int screenHeight = 450;
	const unsigned int fps = 60;
	const unsigned int fontSize = 20;
	const Color bgColor = RAYWHITE;
	const Color textColor = LIGHTGRAY;
	bool continueLoop = true;

	InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
	SetTargetFPS(fps);

	// Set the window icon
	Image windowIcon = LoadImage(PATH_ICON);
	SetWindowIcon(windowIcon);
	Texture2D iconTx = LoadTextureFromImage(windowIcon);

/*********************************************************************
* Game Loop
*********************************************************************/
	while (continueLoop)
	{
		// Check for the normal window closing methods
		continueLoop = continueLoop ? !WindowShouldClose() : continueLoop;

/*********************************************************************
* Draw
*********************************************************************/
		BeginDrawing();

			ClearBackground(bgColor);
			
			unsigned int posX = 190;
			unsigned int posY = 200;
			
			DrawText("Congrats! You created your first window!", posX, posY, fontSize, textColor);
			posY += 100;
			DrawTexture(iconTx, posX, posY, WHITE);

		EndDrawing();
	}

/*********************************************************************
* Clean up
*********************************************************************/
	UnloadImage(windowIcon);
	UnloadTexture(iconTx);
	CloseWindow();
	return 0;
}
