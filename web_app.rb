#!/usr/bin/env ruby

$: << "./lib"
require "sinatra"
require "color_pair"

def generate_css(fg, bg)
  <<~EOF
    body {
      padding: 1em;
      font-family: monospace;
      max-width: 60ch;
      margin: auto;
      font-size: 120%;
      color: #{fg};
      background: #{bg};
    }

    a { color: inherit; }
    input, textarea {
      padding: 1em;
      color: inherit;
    }
    input[type=text], textarea {
      background: rgba(0, 0, 0, 0.2);
    }
    input[type=submit], input[type=button] {
      background: rgba(255, 255, 255, 0.2);
    }

    textarea {
      width: 100%;
      overflow: hidden;
    }
  EOF
end

def pair_from(params)
  if params[:fg]
    raw_fg = ColorPair::RGB.parse(params[:fg])
  else
    raw_fg = ColorPair::RGB.random
  end

  if params[:bg]
    raw_bg = ColorPair::RGB.parse(params[:bg])
  else
    raw_fg, raw_bg = ColorPair.pair_from(raw_fg)
  end

  [raw_fg, raw_bg]
end

get "/" do
  # ASSUMPTION: The theoretical potential for an endless loop will probably not be realized.
  raw_fg, raw_bg = pair_from(params) while raw_fg.nil? || raw_bg.nil?

  fg, bg = [raw_fg, raw_bg].map(&:to_css)

  css = generate_css(fg, bg)

<<-EOF
<style>
#{css}
</style>
<p><a href="/?fg=#{fg}&bg=#{bg}">Permalink.</a> <a href="/">Random.</a> <a href="https://contrast-ratio.com/##{fg}-on-#{bg}">Details.</a></p>
<form>
<p><label>Foreground: <input name="fg" type="text" value="#{fg}"></label></p>
<p><label>Background: <input name="bg" type="text" value="#{bg}"></label></p>
<p><input type="submit" value="Submit"></p>
</form>
<p>Contrast ratio: #{ColorPair.contrast_ratio(raw_fg, raw_bg).round(2)}:1</p>

<textarea rows=#{css.split("\n").length + 1}>
#{css}
</textarea>
EOF
end
