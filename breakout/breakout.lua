-- init

function restart()
    score = 0
    
    init_racket()
    init_ball()
    load_bricks_map(0)
   end

function _init()
	-- gui --
	score = 0
	
	header_h = 6
	 
	-- racket --
	racket_width = 24
	racket_height = 4
	racket_speed = 2
	
	-- ball --
	balls_table = {}
	
	-- bricks --
    bricks_offset_y = header_h+10
	brick_height = 4
	brick_width = 8
    brick_start_index = 192
	
	-- levels --
	bricks_table = {}
	
	-- camera --
	shake_vel = 4
	shake_amplitude = 0
	shake_duration = 0
	max_shake_amplitude = 4
	
	-- power up --
	restart_on_racket = true 
	sticky = false

    restart()

end


function init_racket()
 racket_width = 24
	racket_height = 4
	racket_x = 64-(racket_width/2)
	racket_speed = 2
end


function init_ball()
	add_ball(50, 50, 2, 0.5, 1, 0)
	add_ball(80, 90, 2, 0.5, -1, 0)
end

function add_ball(x, y, radius, vel_x, vel_y, power)
	add(balls_table, {x=x, y=y, radius=radius, vel_x=vel_x, vel_y=vel_y, power=power})
end

function load_bricks_map(level, debug)
    for y=0, 7 do
        bricks_table[y] = {}
        for x=0, 15 do
            bricks_table[y][x] = mget(x, y+8*level) - brick_start_index
        end
    end
    -- debug
    if not debug then return end
    for k,v in ipairs(bricks_table) do
        for a,b in ipairs(v) do
            printh(tostr(a).." = "..tostr(b))
        end
    end

end



-- player

function move_racket()
	-- left
	if btn(⬅️) then
		racket_x -= racket_speed
	end
	-- right
	if btn(➡️) then
		racket_x += racket_speed
	end
	
	if racket_x < 0 then racket_x = 0 end
	if racket_x+racket_width > 128 then racket_x = 128-racket_width end
end 

-- ball

function ball_wall_colide(ball)

	-- top
	if ball["y"] - ball["radius"] - 1 <= header_h then
		if ball["vel_y"] < 0 then
			ball["vel_y"] *= -1
		end
		return true
	end
	
	-- left
	if ball["x"] - ball["radius"] - 1 <= 0 then
		if ball["vel_x"] < 0 then
			ball["vel_x"] *= -1
		end
		return true
	end
	-- right
	if ball["x"] + ball["radius"] + 1 >= 127 then
		if ball["vel_x"] > 0 then
			ball["vel_x"] *= -1
		end
		return true
	end
	return false
end


function ball_bottom_colide(ball)
	-- bottom
	if ball["y"] + ball["radius"] + 1 >= 127 then
		return true
	else
		return false
	end
end


function ball_brick_colide(ball)

    if ball["y"] - ball["radius"] - 1 <= bricks_offset_y then return end
    if ball["y"] - ball["radius"] - 1 > bricks_offset_y+(brick_height*8) then return end

    printh("Collide")

	-- top
	if ball["y"] - ball["radius"] - 1 <= header_h then
		if ball["vel_y"] < 0 then
			ball["vel_y"] *= -1
		end
		return true
	end
	
	-- left
	if ball["x"] - ball["radius"] - 1 <= 0 then
		if ball["vel_x"] < 0 then
			ball["vel_x"] *= -1
		end
		return true
	end
	-- right
	if ball["x"] + ball["radius"] + 1 >= 127 then
		if ball["vel_x"] > 0 then
			ball["vel_x"] *= -1
		end
		return true
	end
	return false
end


function ball_racket_colide(ball)
	-- bottom
	if ball["y"] + ball["radius"] + 1 >= 127 - racket_height then
		if ball["x"]+ball["radius"]+1 > racket_x and ball["x"]-ball["radius"]-1 < racket_x+racket_width then
			if ball["vel_y"] < 0 then
				return false
			end
			ball["vel_x"] = ball_racket_x_vel(ball)
			ball["vel_y"] *= -1 			
			return true
		end
	else
		return false
	end
end


function ball_racket_x_vel(ball)
	local racket_center = racket_x + (racket_width/2)
	
	if ball["x"] > racket_center then
		return (ball["x"]-racket_center)/(racket_width/2)
	elseif ball["x"] < racket_center then
		 return ((racket_center-ball["x"])/(racket_width/2))*-1
	else
		return 0
	end
end


function ball_racket_y_vel(ball)
	local racket_center = racket_x + (racket_width/2)
	
	if ball["x"] > racket_center then
		return (ball["x"]-racket_center)/(racket_width/2)
	elseif ball["x"] < racket_center then
		 return ((racket_center-ball["x"])/(racket_width/2))*-1
	else
		return 0
	end
end


-- bricks


function draw_bricks_table(bricks_table)
    for y=0, #bricks_table do
        for x=0, #bricks_table[y] do
            local brick_life = bricks_table[y][x]
            -- printh("Brick Life:"..brick_life)
            if brick_life > 0 then
                rectfill(brick_width*x, brick_height*y+bricks_offset_y, brick_width*x+brick_width, brick_height*y+bricks_offset_y+brick_height, brick_life)
            end
        end
    end
end



-- camera

function shake_update()
	
	
	-- intensity
	if shake_amplitude > 0 then
		shake_amplitude -= 0.1
	else
		shake_amplitude = 0
	end
	
	-- duration
	if shake_duration >= 1 then
		camera(sin(time()*shake_vel)*shake_amplitude, cos(time()*shake_vel)*(shake_amplitude/2))
		shake_duration -= 1
	else
		camera(0, 0)
		shake_duration = 0
	end

end

-- update

function _update()
end

-- update 60

function _update60()
	
	-- 
	if #balls_table == 0 do
		restart()
	end
	
	-- racket --
	move_racket()
	
	-- ball colision --
	local temp_balls_table = balls_table
	
	for ball in all(temp_balls_table) do
		local wall_collide = ball_wall_colide(ball)
		local racket_collide = ball_racket_colide(ball)

        -- wall collide
		if wall_collide or racket_collide then
			sfx(rnd(2))
			score += 1
			shake_duration = 50
			if shake_amplitude < max_shake_amplitude then
				shake_amplitude += 0.2
			end
		end
        -- racket collide
		if racket_collide then
			shake_duration = 100
			if shake_amplitude < max_shake_amplitude then
				shake_amplitude += 1
			end
		end
		
        -- bricks collide
         ball_brick_colide(ball)

		ball["x"] += ball["vel_x"]
		ball["y"] += ball["vel_y"]
		
		local bottom_colide = ball_bottom_colide(ball)
		if bottom_colide then
			del(balls_table, ball)
		end
		
	end
	
	
	
	-- ball movement --
	
	
	
	-- camera --
	shake_update()
	
end

-- draw

function _draw()
	cls(0)
	
	-- gui --
	rectfill(0, 0, 127, header_h, 5)
	print("score:"..score, 1, 1, 6)
	
	-- racket --	
	rectfill(racket_x, 127-racket_height, racket_x+racket_width, 127, 6)
	
	-- balls --
	for ball in all(balls_table) do
		circfill(ball["x"], ball["y"], ball["radius"], 9)
	end
	-- bricks --
	draw_bricks_table(bricks_table)
	
end

-- game state

function restart()
 score = 0
 
 init_racket()
 init_ball()
 load_bricks_map(0)
end