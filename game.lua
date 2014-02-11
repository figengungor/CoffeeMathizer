local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------


-- local forward references should go here --
W=display.contentWidth
H=display.contentHeight
math.randomseed(os.time())

--hide status bar
display.setStatusBar( display.HiddenStatusBar )

--include and start physics for second game
local physics= require "physics"


--activate multitouch 
system.activate("multitouch")

--accelerometer for character
system.setAccelerometerInterval( 100 )

 -- __      __     _____  _____          ____  _      ______  _____ 
 -- \ \    / /\   |  __ \|_   _|   /\   |  _ \| |    |  ____|/ ____|
 --  \ \  / /  \  | |__) | | |    /  \  | |_) | |    | |__  | (___  
 --   \ \/ / /\ \ |  _  /  | |   / /\ \ |  _ <| |    |  __|  \___ \ 
 --    \  / ____ \| | \ \ _| |_ / ____ \| |_) | |____| |____ ____) |
 --     \/_/    \_\_|  \_\_____/_/    \_\____/|______|______|_____/ 
                                                                 

--positions for alignments and dimensions--
local verticalBarW = 10
local boxW = (W-verticalBarW)/2
local firstMiddleX = (W-verticalBarW)/4
local secondMiddleX =  W-((W-verticalBarW)/4)
local upperBoxH = 50
local upperY = upperBoxH/2
local bottomBoxH = 50
local bottomY = H-bottomBoxH/2

local verticalBar

--upper boxes for time and energy--
local time
local tc
local tbg
local tt

local energy
local ec
local ebg
local et

--second game variables--
local ground
local character
local secondBg
local detectArea
local collisionFilter
local items
local goodItemCount
local verticalBar2
local miss
local catch
local energyDecrease

--first game variables--
local firstBg
local numbers
local operations
local number
local equality
local circle1
local circle2
local currentNumber
local currentSelectedNumber
local currentOperation
local currentSelectedOperation
local isActive = false
local timeUp = false
local timeUpTxt

--first game functions forward declarations
local onNumberTouch
local onOperationTouch
local onCircleTouch
local changeNumbers
local timeGoesBy


--score
local score
local numberOfMoves --for each unequality
local totalMoves --overallMoves
local numberOfEqualities

--second game functions forward declarations
local createItem
local onCollision
local drag
local moveCharacter

--game sounds
local bgChannel 
local bgAudio 

--game Over
local gameOverGroup
local got
local gameOverText
local text
local statistics

--timers
local changeNumbersTimer
local createItemTimer

--restart
local restartText
local restart --function declaration

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
--Game Over
function gameOver(cause, group)

	timer.cancel(createItemTimer)
	if(changeNumbersTimer) then
		timer.cancel( changeNumbersTimer )
	end

	Runtime:removeEventListener("enterFrame", timeGoesBy)
	Runtime:removeEventListener("accelerometer", moveCharacter)
	Runtime:removeEventListener("enterFrame", checkEquality)

	character:removeEventListener( "touch", character)
	character:removeEventListener( "collison", character )


	gameOverGroup = display.newGroup()

	if(cause=="energy") then
		got = "You wasted your coffee.\n No energy to keep up!"
	elseif(cause=="timeIsUp") then
		got = "Time is Up, my friend!\n"
	end

	gameOverText = display.newText(got, secondMiddleX, upperBoxH+50, native.systemFont, 30)
	gameOverGroup:insert(gameOverText)

	restartText = display.newText("PLAY AGAIN", firstMiddleX, H/2, "PWChalk", 30)
	restartText.touch = function(event) storyboard.gotoScene("reload")  end
	restartText:addEventListener( "touch", restartText)
	gameOverGroup:insert(restartText)

	text="Total Moves:"..totalMoves.."\nTotal Equalities:"..numberOfEqualities.."\nYour score:"..score-totalMoves
	
	statistics = display.newText(text,0,0,native.systemFont,30) 
	statistics.y=H/2; statistics.x=secondMiddleX
	transition.to(statistics, {time=500, alpha=1})
	gameOverGroup:insert(statistics)

	display.remove(items)

	audio.stop()

	numbers:removeSelf()
	operations:removeSelf()
	equality:removeSelf()	

	group:insert(gameOverGroup)	

end


function firstGame(group)
 --  ______ _____ _____   _____ _______    _____          __  __ ______ 
	 -- |  ____|_   _|  __ \ / ____|__   __|  / ____|   /\   |  \/  |  ____|
	 -- | |__    | | | |__) | (___    | |    | |  __   /  \  | \  / | |__   
	 -- |  __|   | | |  _  / \___ \   | |    | | |_ | / /\ \ | |\/| |  __|  
	 -- | |     _| |_| | \ \ ____) |  | |    | |__| |/ ____ \| |  | | |____ 
	 -- |_|    |_____|_|  \_\_____/   |_|     \_____/_/    \_\_|  |_|______|
	                                                                     

	firstBg = display.newImageRect("board.png", boxW, H-upperBoxH)
	firstBg.x = firstMiddleX; firstBg.y = H/2+upperBoxH/2
	group:insert(firstBg)

	--operations function
	function onOperationTouch(self, event)
		if(event.phase=="began") then
			if(currentSelectedOperation) then
					currentSelectedOperation[1]:setFillColor(0,0,0)
			end
			currentOperation = self.label
			self[1]:setFillColor(1,0,0)
			currentSelectedOperation = self
		end
	end
	--operations
	number = 1

	operations = display.newGroup()
	opElements = {{"+"}, {"-"}, {"*"}, {"/"}}

	for i=1,table.getn(opElements) do
		local opGroup = display.newGroup()
		local opRect = display.newRect(0,0,50,50)
		local opTxt = display.newText(opElements[i][1],0,0,"PWChalk",35)
		opTxt:setFillColor(1,1,1)
		opRect:setFillColor( 0,0,0 )
		opGroup:insert(opRect); opGroup:insert(opTxt)
		opGroup.x =50+i*60;
		opGroup.label=opElements[i][1]
		opGroup.touch = onOperationTouch
		opGroup:addEventListener("touch", opGroup)
		number = number + 1
		operations:insert(opGroup)
	end

	operations.anchorChildren=true
	operations.x = firstMiddleX; operations.y = H-25
	group:insert(operations)

	--numbers function
	function onNumberTouch(self, event)
		if(event.phase=="began") then
			if(currentSelectedNumber) then
				currentSelectedNumber[1]:setFillColor(1,1,1)
			end
			currentNumber = self.label
			self[1]:setFillColor(0,1,0)
			currentSelectedNumber = self
		end
	end

	--numbers
	numbers = display.newGroup()
	number=1
	for i=1,3 do
		for j=1,3 do
			local noGroup = display.newGroup()
			local noRect = display.newRect(0,0,60,60)
			local noTxt = display.newText(""..number, 0,0,"PWChalk",35)
			noTxt:setFillColor(0,0,0)
			noGroup:insert(noRect); noGroup:insert(noTxt)
			noGroup.x =50+j*80; noGroup.y = i*80
			noGroup.label=number
			noGroup.touch = onNumberTouch
			noGroup:addEventListener("touch", noGroup)
			number = number + 1
			numbers:insert(noGroup)
		end
	end

	numbers.anchorChildren=true
	numbers.x = firstMiddleX; numbers.y = operations.y-operations.height/2-numbers.height/2-30
	group:insert(numbers)

	--change numbers in circles function
	function changeNumbers(c1,c2)
		local circleNo1 = math.random(1,100)
		local circleNo2=math.random(1,100)
		while(circleNo1==circleNo2) do
			circleNo1 = math.random(1,100)
		end
		c1[2].text=""..circleNo1
		c2[2].text=""..circleNo2
		c1.label=circleNo1
		c2.label=circleNo2	
	end

	--onTap circle function
	function onCircleTouch(self, event)
		if(event.phase=="began") then
			local temp
			if(currentNumber==nil or currentOperation==nil) then
				self[1]:setFillColor(1,0,0)
				timer.performWithDelay( 500, function() self[1]:setFillColor(1,1,1) end)
			else
				if(currentOperation=="+") then
					temp =  self.label + currentNumber
				elseif(currentOperation=="-") then
					temp =  self.label - currentNumber
				elseif(currentOperation=="*") then
					temp =  self.label * currentNumber
				elseif(currentOperation=="/") then
					temp =  self.label / currentNumber
				end
				
				if(temp>100 or temp<0) then
					self[1]:setFillColor(1,0,0)
					timer.performWithDelay( 500, function() self[1]:setFillColor(1,1,1) end)
				else
					self.label = math.floor(temp)
					self[2].text=""..self.label
					numberOfMoves = numberOfMoves+1
				end
			end	
		end
	end

	--circles and equality
	equality = display.newGroup()
	circleGroup1 = display.newGroup()
	circleGroup2 = display.newGroup()

	circle1 = display.newCircle(0, 0, 40)
	cTxt1 = display.newText("", 0, 0, "PWChalk" , 30)
	cTxt1:setFillColor(0,0,1); cTxt1.x=circle1.x; cTxt1.y=circle1.y
	circleGroup1:insert(circle1); circleGroup1:insert(cTxt1)
	circleGroup1.label=0
	circleGroup1.touch=onCircleTouch
	circleGroup1:addEventListener("touch", circleGroup1)
	equality:insert(circleGroup1)
		
	equal = display.newText("=", 0, 0, "PWChalk", 50); equal.x = 100;
	equalNot = display.newText("/", 0,0, nil, 50); equalNot.x=100;
	equality:insert(equal)
	equality:insert(equalNot)
		
	circle2 = display.newCircle(200, 0, 40 )
	cTxt2 = display.newText("", 0, 0, "PWChalk" , 30)
	cTxt2:setFillColor(0,0,1); cTxt2.x=circle2.x; cTxt2.y=circle2.y
	circleGroup2:insert(circle2); circleGroup2:insert(cTxt2)
	circleGroup2.label=0
	circleGroup2.touch=onCircleTouch
	circleGroup2:addEventListener("touch", circleGroup2)
	equality:insert(circleGroup2)

	equality.anchorChildren = true
	equality.x = firstMiddleX; equality.y = numbers.y-numbers.height/2-70 
	group:insert(equality)
	--start changing numbers
	changeNumbers(circleGroup1, circleGroup2)

	numberOfMoves = 0
	totalMoves = 0
	score = 0
	numberOfEqualities = 0
	--check equality each enterFrame
	function checkEquality()
		if circleGroup1.label == circleGroup2.label and isActive==false and timeUp==false then
			equalNot.isVisible=false
			isActive=true
			equal:setFillColor(0,1,0)
			transition.to(equal, {time=200, alpha=0})
			transition.to(equal, {time=200, alpha=1})
			changeNumbersTimer = timer.performWithDelay ( 400, function() changeNumbers(circleGroup1, circleGroup2); isActive=false; equal:setFillColor(1,1,1); equalNot.isVisible=true; end, 1 )
			score = score + 5
			numberOfEqualities=numberOfEqualities+1
			totalMoves=totalMoves+numberOfMoves
			numberOfMoves=0
			tc.width=tc.width+50
		end
	end

	function timeGoesBy()	
		tc.width=tc.width-0.5
		tc:setFillColor(0,255,0)
		if(tc.width==0) then
			timeUp=true
			gameOver("timeIsUp",group)
		end
	end
end


function secondGame(group)
	--   _____ ______ _____ ____  _   _ _____     _____          __  __ ______ 
	 --  / ____|  ____/ ____/ __ \| \ | |  __ \   / ____|   /\   |  \/  |  ____|
	 -- | (___ | |__ | |   | |  | |  \| | |  | | | |  __   /  \  | \  / | |__   
	 --  \___ \|  __|| |   | |  | | . ` | |  | | | | |_ | / /\ \ | |\/| |  __|  
	 --  ____) | |___| |___| |__| | |\  | |__| | | |__| |/ ____ \| |  | | |____ 
	 -- |_____/|______\_____\____/|_| \_|_____/   \_____/_/    \_\_|  |_|______|

	--Add horizontal-only move to the character
	function drag(self, event)
		if system.getInfo('environment')=="simulator" then
			if event.phase=="began" then
			    --set focus on the moved object, so it won't interfere with other objects
			    display.getCurrentStage():setFocus(self,event.id)
			    self.isFocus=true
			    --record first position of the object
			    self.x0=self.x; self.y0=self.y
			elseif event.phase=="moved" then
			    self.y=self.y0 --we force the object not to change its first y location
			    self.x=self.x0+(event.x-event.xStart) 
			    if(self.x<W/2+verticalBarW+character.width/2) then
			        self.x=W/2+verticalBarW+character.width/2
			    elseif(self.x>W-character.width/2) then
			        self.x=W-character.width/2
			    end
			elseif event.phase=="cancelled" or event.phase=="ended" then
			    display.getCurrentStage():setFocus(self, nil)
			    self.isFocus=false
			end
		end
		return true
	end

	--Move character with accelerometer
	function moveCharacter(event)
		character.x = W/2 - (W/2 *(event.yGravity*3))
		if((character.x - character.width * 0.5) < W/2+verticalBarW+character.width/2 ) then
			character.x = W/2+verticalBarW+character.width/2
		elseif((character.x + character.width * 0.5) > W) then
			character.x = W - character.width * 0.5
		end
	end

	catch=0
	--Create collision detection
	function onCollision(self, event)
		if event.phase=="began" then
			if event.target.type=="character" and event.other.type=="good" then
				catch=catch+1
				event.other:removeSelf()
				event.other=nil
			elseif event.other.type == "bad" then			
				timer.cancel(createItemTimer);
				event.other:removeSelf()
				event.other=nil
				items:removeSelf()
				items=nil
			end
		end
	end


	secondBg = display.newImageRect("sky.jpg", boxW, H-bottomBoxH-upperBoxH)
	secondBg.x = secondMiddleX; secondBg.y = H/2
	group:insert(secondBg)

	ground = display.newImageRect("tablecloth.png", boxW, bottomBoxH)
	ground.x = secondMiddleX; ground.y = bottomY
	group:insert(ground)

	character = display.newImageRect( "moni.png", 70, 70 )
	character.x = secondMiddleX; character.y = bottomY-bottomBoxH/2
	group:insert(character)
	                                                                         
	character.touch = drag
	character:addEventListener("touch", character)
	character.type="character"
	physics.addBody (character, "static", {density = 1.0, friction = 0.0, bounce = 0, radius = 25 })

	--add collision listener to character
	character.collision=onCollision
	character:addEventListener("collision", character)

	--when food reaches the bottom(touches to detect area), it is removed.
	detectArea = display.newRect(secondMiddleX,H-10,boxW,2)
	detectArea.alpha = 0
	detectArea.type = "detectArea"
	physics.addBody(detectArea,"static",{isSensor = false})
	group:insert(detectArea)

	verticalBar2 = display.newRect(W-verticalBarW/2, H/2, verticalBarW, H )
	physics.addBody(verticalBar2,"static",{isSensor = false})
	verticalBar2.alpha=0
	group:insert(verticalBar2)

	--to make similar type items pass through each other when they collide
	collisionFilter = { groupIndex = -2 }
	items = display.newGroup()
	goodItemCount=0
	miss=0
	energyDecrease = ec.width/4
	--create and drop item (image path, type of item)
	function createItem(imgName, itemType)	
	    local item = display.newImageRect(imgName,100,80)
	    item.x = math.random(W/2+verticalBarW+item.width/2, W-item.width); item.y=-50
	    item.isSensor=true
	    physics.addBody(item, { filter=collisionFilter })
	    if(itemType==1) then
	    	item.type = "good"
	    	goodItemCount = goodItemCount+1
	    else 
	     	if(goodItemCount%5==0 ) then
	 			item:applyForce( 0, 100, item.x, item.y )
	     	end
	    	item.type="bad"
	    end
		items:insert(item)  
	    item.collision = function(self,event)
	        if event.phase == "began" and event.other.type == "detectArea" then
	            event.target:removeSelf()
	            if(self.type=="good") then
	            	ec.width = ec.width-energyDecrease
	            	miss = miss+1
	            end
	            if(miss==4) then
	            	gameOver("energy", group)
	            end
	        end
	    end
	    item:addEventListener("collision")
	end

	group:insert(items)

	--for items to drop beneath the energy bar
	energy:toFront()

end


-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    -----------------------------------------------------------------------------

    --      CREATE display objects and add them to 'group' here.
    --      Example use-case: Restore 'group' from previously saved state.

    -----------------------------------------------------------------------------
    physics.start()

    --creating variables--
	tbg = display.newRect( firstMiddleX, upperY, boxW, upperBoxH )
	tc = display.newRect( firstMiddleX, upperY, boxW, upperBoxH )
	tc:setFillColor( 0,1,0 )
	tt = display.newText("TIME", firstMiddleX, upperY, "PWChalk", 30)
	tt:setFillColor(0,0,0)

	time = display.newGroup(tbg,tc,tt)
	group:insert(time)

	ebg = display.newRect( secondMiddleX, upperY, boxW, upperBoxH )
	ec = display.newRect( secondMiddleX, upperY, boxW, upperBoxH )
	ec:setFillColor( 0,1,0 )
	et = display.newText("ENERGY", secondMiddleX, upperY, "PWChalk", 30)
	et:setFillColor(0,0,0)

	energy = display.newGroup(ebg,ec,et)
	group:insert(energy)

	verticalBar = display.newRect(W/2, H/2, verticalBarW, H )
	verticalBar:setFillColor(0,0,0)
	physics.addBody(verticalBar,"static",{isSensor = false})
	group:insert(verticalBar)


	firstGame(group)
	secondGame(group)
	 

end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      This event requires build 2012.782 or later.

        -----------------------------------------------------------------------------

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. start timers, load audio, start listeners, etc.)

        -----------------------------------------------------------------------------
        --game sounds
        bgChannel = audio.loadStream("awake.wav")
		bgAudio = audio.play(bgChannel)
		
		--timer
		createItemTimer = timer.performWithDelay(2000, function() createItem("coffee.png",1) end, 0 )		

		--runtime listeners
        Runtime:addEventListener("enterFrame", checkEquality)
        Runtime:addEventListener("enterFrame", timeGoesBy)
		Runtime:addEventListener("accelerometer", moveCharacter)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view
        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

        -----------------------------------------------------------------------------
        audio.stop(bgAudio)
        audio.dispose(bgChannel) 
        bgAudio=nil
        bgChannel=nil

        storyboard.purgeScene("game")
        storyboard.removeScene("game")
        physics.stop( )

end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      This event requires build 2012.782 or later.

        -----------------------------------------------------------------------------

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

        -----------------------------------------------------------------------------

end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene

        -----------------------------------------------------------------------------

        --      This event requires build 2012.797 or later.

        -----------------------------------------------------------------------------

end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene

        -----------------------------------------------------------------------------

        --      This event requires build 2012.797 or later.

        -----------------------------------------------------------------------------

end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene





                                                                                 