/*
 * Copyright (c) 2021-2024 AFADoomer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

const CHUNKSIZE = 512;
const MAPMAX = 32768;
const MAXINTERVAL = 16;

class EffectChunk
{
	Array<int> sectors;
	Array<int> things;
	int x, y, distance, range;
	double maxplayerz;
	bool infov, culled;
	Actor nearestplayer;

	static int, int GetChunk(double x, double y)
	{
		int row = int(y + MAPMAX) / CHUNKSIZE;
		int col = int(x + MAPMAX) / CHUNKSIZE;

		int maxval = MAPMAX * 2 / CHUNKSIZE;

		row = clamp(row, 0, maxval);
		col = clamp(col, 0, maxval);

		return col, row;
	}

	// Find a chunk's info based off of the x and y coordinates
	static EffectChunk FindChunk(double x, double y, in out Array<EffectChunk> chunks, bool chunkcoords = true)
	{
		if (!chunkcoords)
		{
			[x, y] = EffectChunk.GetChunk(x, y);
		}

		for (int e = 0; e < chunks.Size(); e++)
		{
			let chunk = chunks[e];
			if (chunk.x == int(x) && chunk.y == int(y)) { return chunk; }
		}

		// Or create a chunk if none exists
		EffectChunk chunk = New("EffectChunk");
		chunks.Push(chunk);

		chunk.x = int(x);
		chunk.y = int(y);
		chunk.distance = MAXINTERVAL * CHUNKSIZE;
		chunk.range = MAXINTERVAL;
		chunk.maxplayerz = -0x7FFFFFFF;
		chunks.Push(chunk);

		return chunk;
	}
}

class ChunkHandler : EventHandler
{
	Array<EffectChunk> chunks;
	int lastupdate;

	enum coords // bbox coordinates
	{
		BOXTOP,
		BOXBOTTOM,
		BOXLEFT,
		BOXRIGHT
	};

	override void WorldLoaded(WorldEvent e)
	{
		for (int s = 0; s < level.sectors.Size(); s++)
		{
			GetSectorChunks(s);
		}
	}

	static ChunkHandler Get()
	{
		return ChunkHandler(EventHandler.Find("ChunkHandler"));
	}

	static int GetDistance(Vector2 pos)
	{
		ChunkHandler handler = ChunkHandler.Get();
		if (!handler) { return CHUNKSIZE; }
		
		EffectChunk chunk = EffectChunk.FindChunk(pos.x, pos.y, handler.chunks, false);
		if (!chunk) { return CHUNKSIZE; }
			
		return chunk.distance;
	}

	static int GetRange(Vector2 pos)
	{
		ChunkHandler handler = ChunkHandler.Get();
		if (!handler) { return 1; }
		
		EffectChunk chunk = EffectChunk.FindChunk(pos.x, pos.y, handler.chunks, false);
		if (!chunk) { return 1; }
			
		return chunk.range;
	}

	static bool InFOV(Vector2 pos)
	{
		ChunkHandler handler = ChunkHandler.Get();
		if (!handler) { return true; }
		
		EffectChunk chunk = EffectChunk.FindChunk(pos.x, pos.y, handler.chunks, false);
		if (!chunk) { return true; }
			
		return chunk.infov;
	}

	// Get the chunks that are associated with a specific sector
	void GetSectorChunks(int s)
	{
		let sec = level.sectors[s];
		double top, bottom, left, right;
		top = right = -0x7FFFFFFF;
		bottom = left = 0x7FFFFFFF;

		for (int l = 0; l < sec.lines.Size(); l++)
		{
			top = max(top, sec.lines[l].bbox[BOXTOP]);
			right = max(right, sec.lines[l].bbox[BOXRIGHT]);
			bottom = min(bottom, sec.lines[l].bbox[BOXBOTTOM]);
			left = min(left, sec.lines[l].bbox[BOXLEFT]);
		}

		for (int x = int(left); x <= int(right) + CHUNKSIZE; x += CHUNKSIZE)
		{
			for (int y = int(bottom); y <= int(top) + CHUNKSIZE; y += CHUNKSIZE)
			{
				EffectChunk chunk = EffectChunk.FindChunk(x, y, chunks, false);
				chunk.sectors.Push(sec.sectornum);
			}
		}
	}

	void GetChunksInRadius(Vector2 pos, double radius, in out Array<EffectChunk> foundchunks)
	{
		for (int x = int(pos.x - radius); x <= int(pos.x + radius); x += CHUNKSIZE)
		{
			for (int y = int(pos.y - radius); y <= int(pos.y + radius); y += CHUNKSIZE)
			{
				EffectChunk chunk = EffectChunk.FindChunk(x, y, chunks, false);
				foundchunks.Push(chunk);
			}
		}
	}

	EffectChunk GetChunk(Vector2 pos)
	{
		return EffectChunk.FindChunk(pos.x, pos.y, chunks, false);
	}

	static void UpdateChunks()
	{
		let handler = ChunkHandler.Get();
		if (!handler) { return; }

		if (handler.lastupdate > level.time - 5) { return; }
		handler.lastupdate = level.time;

		handler.SetChunkInfo();
	}

	// Iterate through all players and set each chunk's spawn info 
	// based on the chunk's distance from players and players' view heights
	void SetChunkInfo()
	{
		// Reset values to default
		for (int e = 0; e < chunks.Size(); e++)
		{
			chunks[e].distance = MAXINTERVAL * CHUNKSIZE;
			chunks[e].range = MAXINTERVAL;
			chunks[e].infov = false;
			chunks[e].maxplayerz = -0x7FFFFFFF;
		}

		int maxval = MAPMAX * 2 / CHUNKSIZE;

		// Iterate through all possible interval values and set those values
		// as appropriate for each player (without overwriting values set by
		// presence of other players)
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p]) { continue; } // Only process if player is in the game

			// Convert player position to a chunk offset
			int chunkx, chunky;
			[chunkx, chunky] = EffectChunk.GetChunk(players[p].camera.pos.x, players[p].camera.pos.y);

			for (int c = 0; c <= MAXINTERVAL; c++)
			{
				// Iterate through chunks surrounding the player
				for (int x = chunkx - c; x <= chunkx + c; x++)
				{
					if (x < 0 || x >= maxval) { continue; }

					for (int y = chunky - c; y <= chunky + c; y++)
					{
						if (y < 0 || y >= maxval) { continue; }

						if (
							(x != chunkx - c && x != chunkx + c) &&
							(y != chunky - c && y != chunky + c)
						) { continue; }

						// Find the chunk info and set the spawn info
						EffectChunk chunk = EffectChunk.FindChunk(x, y, chunks);

						int range = max(1, c - 1);

						if (range < chunk.range)
						{
							chunk.range = range;
							chunk.nearestplayer = players[p].mo;
						}

						chunk.distance = chunk.range * CHUNKSIZE;
						chunk.maxplayerz = max(players[p].viewheight, chunk.maxplayerz);

						if (c > 4)
						{
							double playerangle = Actor.Normalize180(players[p].camera.angle);
							double relangle = atan2(y - chunky, x - chunkx);

							if (Actor.absangle(playerangle, relangle) < 80) { chunk.infov = true; }
						}
						else { chunk.infov = true; }
					}
				}
			}
		}
	}
}