require 'sdl2/ttf'
require 'sdl2/image'

class Screen
  def initialize
    SDL2.init!(:EVERYTHING)
    @window = SDL2::Window.create(title: "Hi Pat", width: 480, height: 320)
    @window.fullscreen = SDL2::Window::FLAGS::FULLSCREEN
    @screen = @window.surface
    SDL2::TTF.init!

    @font_size = 64
    @font_name = 'font.ttf'
    font = SDL2::TTF::Font.open(@font_name, @font_size)
    @fonts = {}
    @fonts[@font_size] = font

    @backgroundColor = SDL2::Color.cast(r: 255, g: 255, b: 255, a: 255)    
    @textColor = SDL2::Color.cast(r: 255, g: 0, b: 255, a: 255)    
  end

  def get_font(size)
    result = @fonts[size]
    if result.nil?
      result = SDL2::TTF::Font.open(@font_name, size)
      @fonts[size] = result
    end
    result
  end

  def text(msg, x = 0, y = 0, size = @font_size)
    msg = msg.to_s
    return if msg.length == 0
    msg = get_font(size).render_text_blended_wrapped(msg, @screen.w, @textColor)
    msg.blit_out(@screen, x: x, y: y)
  end

  def update
    @screen.fill_rect(nil, @backgroundColor)
    yield self
    @window.update_surface
  end

  def quit
    @running = false
  end

  def poll
    @running = true
    while @running do
      begin
        event = SDL2::Event.poll()
        update do 
          yield event, self
        end
      rescue StandardError => e
        puts "Unexpected error #{e}"
      end
      sleep(0.25)
    end
  end

  def cleanup
    SDL2::TTF.quit
    SDL2::quit
  end
end

