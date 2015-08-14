# Handlebars templates' manager

class window.TemplateManager
  constructor: ->
    @templates = new Array

  add_template: (name, template) ->
    @templates[name] = template

  load_template: (name, template_source) ->
    template = @templates[name]
    @add_template name, Handlebars.compile(template_source) if !template?

  transform: (name, context) ->
    template = @templates[name]
    template context
