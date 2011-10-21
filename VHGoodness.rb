require 'robot'

class VHGoodness
   include Robot
#battlefield_height  #the height of the battlefield
#  battlefield_width   #the width of the battlefield
#  energy              #your remaining energy (if this drops below 0 you are dead)
#  gun_heading         #the heading of your gun, 0 pointing east, 90 pointing
#                      #north, 180 pointing west, 270 pointing south
#  gun_heat            #your gun heat, if this is above 0 you can't shoot
#  heading             #your robots heading, 0 pointing east, 90 pointing north,
#                      #180 pointing west, 270 pointing south
#  size                #your robots radius, if x <= size you hit the left wall
#  radar_heading       #the heading of your radar, 0 pointing east,
#                      #90 pointing north, 180 pointing west, 270 pointing south
#  time                #ticks since match start
#  speed               #your speed (-8/8)
#  x                   #your x coordinate, 0...battlefield_width
#  y                   #your y coordinate, 0...battlefield_height
#  accelerate(param)   #accelerate (max speed is 8, max accelerate is 1/-1,
#                      #negativ speed means moving backwards)
#  stop                #accelerates negativ if moving forward (and vice versa),
#                      #may take 8 ticks to stop (and you have to call it every tick)
#  fire(power)         #fires a bullet in the direction of your gun,
#                      #power is 0.1 - 3, this power will heat your gun
#  turn(degrees)       #turns the robot (and the gun and the radar),
#                      #max 10 degrees per tick
#  turn_gun(degrees)   #turns the gun (and the radar), max 30 degrees per tick
#  turn_radar(degrees) #turns the radar, max 60 degrees per tick
#  dead                #true if you are dead
#  say(msg)            #shows msg above the robot on screen
#  broadcast(msg)      #broadcasts msg to all bots (they recieve 'broadcasts'
#                      #events with the msg and rough direction)
  def tick events
    location = [x,y]
    if events['robot_scanned'].empty?
      turn_gun(10)
    else
      #turn_gun(-1)
      navigate
      fire 3
    end
  end

  def navigate
    distance_from_edge = 250
    if speed < 4
      accelerate(1)
    end
    if x >= (battlefield_width - distance_from_edge) or x <= distance_from_edge or y >= (battlefield_height - distance_from_edge) or y <= distance_from_edge
      #turn_radar 30
      turn 10
    end
    #if y >= (battlefield_height - 40) or y <= 40
    # turn 10
    #end
  end

  def heading_up_down?
    heading == 90 or heading == 270
  end

  def heading_left_right?
    heading == 0 or heading == 180
  end
end