# frozen_string_literal: true

module FairShare
  # a
  class ViewRenderer
    def initialize(app, content:, layouts: [], locals: {})
      @app = app
      @content = content
      @layouts = layouts
      @locals = locals
    end

    def render
      output = @app.view(@content, layout: false, locals: @locals)
      @layouts.each do |layout|
        output = @app.view(layout, layout: false) { output }
      end
      output
    end
  end
end
