###
 Custom attribute model
 - Organizes attributes by trait
 - Provides shorthand aliases to access via flat namespace API
 - Values are stored in three.js uniform-style objects so they can be bound as uniforms
 - Type validators and setters avoid copying value objects on write
 - Coalesces update notifications per object and per trait
 
  Actual type and trait definitions are injected from Primitives
###

class Attributes
  constructor: (definitions) ->
    @traits  = definitions.Traits
    @types   = definitions.Types
    @pending = []

  make: (type) ->
    _type: type
    type:  type.uniform?() # for three.js
    value: type.make()

  apply: (object, traits = []) ->
    new Data object, traits, @

  queue: (callback) ->
    @pending.push callback

  digest: () ->
    limit = 10

    while @pending.length > 0 && --limit > 0
      [calls, @pending] = [@pending, []]
      callback() for callback in calls

    if limit == 0
      throw Error("More than #{limit} iterations in Data::digest")

    return

  getTrait: (name) ->
    @traits[name]


class Data
  constructor: (object, traits = [], attributes) ->

    # Aliases
    mapTo = {}
    mapFrom = {}
    to   = (name) -> mapTo[name]   ? name
    from = (name) -> mapFrom[name] ? name
    define = (name, alias) ->
      throw "Duplicate property `#{alias}`" if mapTo[alias]
      mapFrom[name] = alias
      mapTo[alias]  = name

    # Get/set
    get = (key) => @[key]?.value ? @[to(key)]?.value
    set = (key, value, ignore) =>
      key = to(key)
      throw "Setting unknown property '#{key}'" unless validators[key]?

      replace = validate key, value, @[key].value
      @[key].value = replace if replace != undefined
      change key, value unless ignore

    object.get = (key) =>
      if key?
        get(key)
      else
        out = {}
        out[from(key)] = value.value for key, value of @
        out

    object.set = (key, value, ignore) ->
      if key? and value?
        set(key, value, ignore)
      else
        options = key
        set(key, value, ignore) for key, value of options
      return

    # Validate value for key
    makers = {}
    validators = {}
    validate = (key, value, target) ->
      validators[key] value, target
    object.validate = (key, value) ->
      make = makers[key]
      target = make() if make?
      replace = validate key, value, target
      if replace != undefined then replace else target

    # Accumulate changes
    dirty = false
    changed = {}
    touched = {}
    getNS  = (key) -> key.split('.')[0]
    change = (key, value) =>
      if !dirty
        dirty = true
        attributes.queue digest

      trait = getNS key

      # Log change
      changed[key]   = true

      # Mark trait/namespace as dirty
      touched[trait] = true

    event =
      type: 'change'
      changed: null
      touched: null

    # Notify listeners of accumulated changes
    digest = () ->
      event.changed = changed
      event.touched = touched
      changes = {}
      touches = {}

      dirty = false

      event.type = 'change'
      object.trigger event

      for trait, dummy of event.touched
        event.type = "change:#{trait}"
        object.trigger event

    # Convert name.trait.key into keyName
    shorthand = (name) ->
      parts = name.split /\./g
      suffix = parts.pop()
      parts.pop() # Discard
      parts.unshift suffix
      parts.reduce (a, b) -> a + b.charAt(0).toUpperCase() + b.substring(1)

    # Add in traits
    list   = []
    values = {}
    for trait in traits
      [trait, ns] = trait.split ':'
      name = if ns then [ns, trait].join '.' else trait
      spec = attributes.getTrait trait
      list.push trait

      continue unless spec

      for key, options of spec
        key = [name, key].join '.'
        @[key] =
          type: options.uniform?()
          value: options.make()

        # Define flat namespace alias
        define key, shorthand key

        # Collect makers and validators
        makers[key] = options.make
        validators[key] = options.validate

    # Store array of traits
    unique = list.filter (object, i) -> list.indexOf(object) == i
    object.traits = unique

    # And hash for CSSauron
    hash = object.traits.hash = {}
    hash[trait] = true for trait in unique

    null

module.exports = Attributes