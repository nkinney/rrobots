require 'robot'
require 'Matrix'
require 'Numeric'
require 'statemachine'

# NOTE: If you fail to load due to state machine, execute the following line in the ruby command prompt:
#
#                   gem install Statemachine

require 'PolarIce/Logging'
require 'PolarIce/Numeric'
require 'PolarIce/Vector'
require 'PolarIce/Sighting'
require 'PolarIce/Rotator'
require 'PolarIce/Driver'
require 'PolarIce/Gunner'
require 'PolarIce/Radar'
require 'PolarIce/Loader'
require 'PolarIce/Commander'

class PolarIce
  include Robot
  include DriverAccessor
  include GunnerAccessor
  include RadarAccessor
  include LoaderAccessor

  CENTER_POSITION = Vector[800,800]

  INITIAL_BROADCAST_MESSAGE = ""
  INITIAL_QUOTE = ""

  def tick events
    update_state
    if events != nil
      process_damage(events['got_hit']) if !events['got_hit'].empty?
      process_intel(events['broadcasts'])
      process_radar(events['robot_scanned'])
    end
    fire_the_gun
    commander.tick
    move_the_bot
    turn_the_gun
    turn_the_radar
    perform_actions
    store_previous_status
  end

  def update_state
    @currentPosition = Vector[x,y]

    log "time #{time}: pos=#{@currentPosition} h=#{heading} g=#{gun_heading} r=#{radar_heading} s=#{speed}\n"
    update_driver_state
    update_gunner_state
    update_radar_state

    if !@initialized
      initialize_first_tick
    end
  end

  def initialize_first_tick
    log "Position = #{@currentPosition}\n"
    log "Heading = #{radar_heading}\n"
    @initialized = true
    initialize_state_machine
  end

  def update_driver_state
    driver.currentPosition = currentPosition
    driver.currentHeading = heading
    driver.currentSpeed = speed
  end

  def update_gunner_state
    gunner.currentPosition = currentPosition
    gunner.currentHeading = gun_heading
  end

  def update_radar_state
    radar.currentPosition = currentPosition
    radar.currentHeading = radar_heading
  end

  def process_damage(hits)
    log "process_damage #{hits[0]}\n"
    @lastHitTime = time
  end

  def initialize_state_machine
    @commander.scan
  end

  def fire_the_gun
    loader.tick
  end

  def process_intel(broadcasts)
    log "process_intel #{broadcasts}\n"
    process_partner_broadcasts(broadcasts)
    send_position_to_partner
  end

  def process_partner_broadcasts(broadcasts)
    log "process_partner_broadcasts #{broadcasts}\n"
    broadcasts.each do |message|
      process_partner_message(message)
    end
  end

  def process_partner_message(message)
    log "process_partner_message #{message}\n"
    message_x, message_y = message[0][1..-1].split(',').map { |s| s.to_i(36).to_f/100 }
    if message[0][0] == "P"
      @currentPartnerPosition = Vector[message_x,message_y]
      log "currentPartnerPosition = #{@currentPartnerPosition}\n"
    end
  end

  def send_position_to_partner
    @broadcastMessage = "P" + @currentPosition.encode
  end

  def process_radar(robots_scanned)
    targets_scanned = Array.new
    if (robots_scanned != nil)
      robots_scanned.each do |target|
        targets_scanned << Sighting.new(@previousRadarHeading, radar_heading, target[0], radar.rotation.direction, currentPosition, time)
      end
    end
    radar.scanned targets_scanned
  end

  def move_the_bot
    driver.tick
    update_states_for_hull_movement
  end

  def update_states_for_hull_movement
    @previousPosition = currentPosition
    @currentPosition = driver.newPosition
    gunner.currentPosition = @currentPosition
    gunner.currentHeading = (gunner.currentHeading + driver.rotation) % 360
    radar.currentPosition = @currentPosition
    radar.currentHeading = (radar.currentHeading + driver.rotation) % 360
  end

  def turn_the_gun
    gunner.tick
    update_states_for_gun_movement
  end

  def update_states_for_gun_movement
    radar.currentHeading = (radar.currentHeading + gunner.rotation) % 360
  end

  def turn_the_radar
    radar.tick
  end

  def perform_actions
    log "perform_actions #{time}: t=#{driver.rotation} g=#{gunner.rotation} r=#{radar.rotation} a=#{driver.acceleration} f=#{loader.power} b=#{@broadcastMessage}\n"
    turn driver.rotation
    accelerate driver.acceleration
    turn_gun gunner.rotation
    fire loader.power
    turn_radar radar.rotation
    broadcast @broadcastMessage
    say @quote
  end

  def store_previous_status
    @previousHeading = heading
    @previousGunHeading = gun_heading
    @previousRadarHeading = radar_heading
    @previousSpeed = speed
  end

  def start_quick_scan
    radar.scan
  end

  def quick_scan_successful(targets)
    commander.quick_scan_successful(targets)
  end

  def quick_scan_failed
    commander.quick_scan_failed
  end

  def target(target)
    log "polarIce.target #{target}\n"
    gunner.target(target)
  end

  def update_target(target)
    log "polarIce.update_target #{target}\n"
    commander.update_target(target)
  end
  
  def track(target)
    radar.track(target)
  end

  def target_lost
    commander.target_lost
  end

  def base_test
    commander.base_test
  end

  def lock
    driver.lock
  end

  def unlock
    driver.unlock
  end
  
  def initialize
    initialize_crew
    initialize_basic_operations
  end

  def initialize_crew
    @driver = Driver.new
    @loader = Loader.new
    @gunner = Gunner.new(self)
    @radar = Radar.new(self)
    @commander = Commander.new(self)
  end

  def initialize_basic_operations
    @broadcastMessage = INITIAL_BROADCAST_MESSAGE
    @quote = INITIAL_QUOTE
  end

  attr_reader(:currentPosition)

  attr_accessor(:commander)

  attr_accessor(:broadcastMessage)

  attr_accessor(:quote)
  attr_accessor(:lastHitTime)

  attr_accessor(:previousRadarHeading)
  attr_accessor(:previousPosition)

  attr_accessor(:currentPartnerPosition)
end
