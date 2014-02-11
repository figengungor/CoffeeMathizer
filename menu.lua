local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
W=display.contentWidth
H=display.contentHeight
----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

-- local forward references should go here --
local play
local about
local credit
local textGroup
local titleBg
local title
local beans
local aboutText
local instructions
local scrollView
local back
local developer

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
function onAbout(event)
	textGroup.isVisible = false
	beans.isVisible = false

	back = display.newText("<= BACK", title.x+title.height/2+50, 50, "PWChalk", 30)
	back.anchorX = 1
	back:rotate(-90)
	back.tap = function(event) 
		scrollView:removeSelf()
		back:removeSelf() 	
		back:removeEventListener( "tap", back)
		textGroup.isVisible = true
		beans.isVisible =true
	end
	back:addEventListener( "tap", back)

	instructions = [[This is a multitask game. You race against time.
	In first half screen, you should solve the inequality by making numbers in circles equal. 
	You choose a number and an operation, then you tap on one of the circles to apply the operation. 
	In order to get high scores, you need to solve the inequality by applying fewer number of operations. 
	For each inequality solved, extra time is given and by the time, in second half screen, you need to 
	keep your energy high by drinking cup of coffee that drops from the sky. If you miss 4 cups of coffee, 
	then the game is over. In order to move character, you use accelerometer.
	Good luck;)]]

	aboutText = display.newEmbossedText(instructions, 0, H/2, W/2, 0, native.systemFont, 30)
	aboutText.anchorX = 0.5; aboutText.anchorY = 0
	aboutText:rotate(-90)

	

	scrollView = widget.newScrollView
		{
			top=0,
			left=200,
			width=W,
			height=H,
			rightPadding=300,
			verticalScrollDisabled=true,
			horizontalScrollDisabled=false,
			hideBackground=true  
		}

	scrollView:insert(aboutText)
	scene.view:insert(back)
	scene.view:insert(scrollView)
	
	title:toFront()


end

function onCredit(event)
	textGroup.isVisible = false
	beans.isVisible = false
	developer = display.newText("©2014 FIGEN GUNGOR", W/2, H/2, "PWChalk", 40)
	developer:rotate(-90)
	developer.tap = function(event)
		developer:removeSelf() 	
		developer:removeEventListener( "tap", back)
		textGroup.isVisible = true
		beans.isVisible =true 
	end
	developer:addEventListener( "tap", developer)
	scene.view:insert(developer)
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      CREATE display objects and add them to 'group' here.
        --      Example use-case: Restore 'group' from previously saved state.

        -----------------------------------------------------------------------------

        textGroup = display.newGroup()

        titleBg = display.newRect(W/2, H/2, H, W)
        titleBg:setFillColor( 212/255,85/255,0 )
        titleBg:rotate(-90)

        title = display.newText("COFFEEMATHaZER", 40, H/2, "PWChalk", 40)
        title:setFillColor(0,0,0)
        title:rotate(-90)


        play = display.newText("PLAY", W/2, H/2,"PWChalk", 30)
        play:rotate(-90)
        play:setFillColor(0,0,0)
        play.tap = function(event) storyboard.gotoScene("game") end
        textGroup:insert(play)

        about = display.newText("ABOUT", W/2+80, H/2, "PWChalk", 30)
        about:rotate(-90)
        about:setFillColor(0,0,0)
        about.tap = onAbout
        textGroup:insert(about)


        credit = display.newText("CREDITS", W/2+160, H/2, "PWChalk", 30)
		credit:rotate(-90)
		credit:setFillColor(0,0,0)
		credit.tap = onCredit 
		textGroup:insert(credit)

		textGroup.anchorChildren = true
		textGroup.x = W/2 ; textGroup.y = H/2

		--add coffee beans
		beans = display.newGroup()
		for i=1,3 do
			local bean = display.newImageRect("coffeeBean.png", 50,50)
			bean.x =  textGroup[i].contentBounds.xMin+10; bean.y=H/2+ textGroup[i].width/2 + 50
			beans:insert(bean)
		end

		group:insert(titleBg)
		group:insert(textGroup)
		group:insert(beans)
		group:insert(title)		

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
        play:addEventListener( "tap", play)
        about:addEventListener( "tap", about)
        credit:addEventListener( "tap", credit )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

        -----------------------------------------------------------------------------

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