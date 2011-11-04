require 'robot'

class LcfVersion01
   include Robot

  def tick events

    #get_angle_to_location 0,0
    puts "#{events}"
    say "Inconceivable!" if got_hit(events)
    unless @dead
      if energy > 90
        sniper_mode
        if time == 0 then
          turn_radar 15
        else
          turn_radar 30 - (60 * (time % 2))
        end
      else
        turn_radar 1 if time == 0
        turn_gun 30 if time < 3
        accelerate 1
        turn 2
        fire 3 unless events['robot_scanned'].empty?
        broadcast "LcfVersion01"
        #say "#{events['broadcasts'].inspect}"
      end
    else
      say "Inconceivable"
    end
  end

  def got_hit(events)
    return events.has_key? "got_hit"
  end
  def sniper_mode
    go_to_nearest_corner
  end

  def go_to_nearest_corner
    #corners are:
    #top left     0, Battlefield_height
    #top right    Battlefield_width, Battlefield_height
    #bottom right Battlefield_width, 0
    #bottom left  0, 0
    puts

    if @battlefield_width.to_i / 2 < x then
      x_corner = @battlefield_width
    else
      x_corner = 0
    end
    if @battlefield_height.to_i / 2 < y then
      y_corner = @battlefield_height
    else
      y_corner = 0
    end
    go_to_location x_corner, y_corner
  end

  def go_to_location x, y
    if(get_angle_to_location(x,y) == heading)
      accelerate 1 #unless speed > 0
    else
      turn (get_angle_to_location x, y) - heading
    end
  end

  def get_angle_to_location x, y
    angle = Math.atan2(get_y - y, x - get_x) / Math::PI * 180 % 360
    puts "Angle to location #{x},#{y} == #{angle}"
    return angle
  end

  def get_x
    x
  end

  def get_y
    y
  end

end