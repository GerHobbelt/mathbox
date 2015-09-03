Primitive = require '../../primitive'
Util      = require '../../../util'

class Face extends Primitive
  @traits = ['node', 'object', 'visible', 'style', 'line', 'mesh', 'face', 'geometry', 'position', 'bind', 'shade']

  constructor: (node, context, helpers) ->
    super node, context, helpers

    @face = null

  resize: () ->
    return unless @bind.points?

    dims = @bind.points.getActiveDimensions()
    {items, width, height, depth} = dims

    @face.geometry.clip width, height, depth, items if @face
    @line.geometry.clip items, width, height, depth if @line

    if @bind.map?
      map  = @bind.map.getActiveDimensions()
      @face.geometry.map  map.width, map.height, map.depth, map.items if @face

  make: () ->
    # Bind to attached data sources
    @_helpers.bind.make [
      { to: 'geometry.points', trait: 'source' }
      { to: 'geometry.colors', trait: 'source' }
      { to: 'mesh.map',        trait: 'source' }
    ]

    return unless @bind.points?

    # Fetch position and transform to view
    position = @bind.points.sourceShader @_shaders.shader()
    position = @_helpers.position.pipeline position

    # Prepare bound uniforms
    styleUniforms = @_helpers.style.uniforms()
    lineUniforms  = @_helpers.line.uniforms()

    # Fetch geometry dimensions
    dims    = @bind.points.getDimensions()
    {items, width, height, depth} = dims

    # Get display properties
    outline = @props.outline
    shaded  = @props.shaded
    fill    = @props.fill

    # Build color lookup
    if @bind.colors
      color = @_shaders.shader()
      @bind.colors.sourceShader color

    # Build transition mask lookup
    mask = @_helpers.object.mask()

    # Build texture map lookup
    map = @_helpers.shade.map @bind.map?.sourceShader @_shaders.shader()

    # Build fragment material lookup
    material = @_helpers.shade.pipeline() || shaded

    objects = []

    # Make line renderable
    if outline
      # Swizzle face edges into segments
      swizzle = @_shaders.shader()
      swizzle.pipe Util.GLSL.swizzleVec4 'yzwx'
      swizzle.pipe position

      uniforms = Util.JS.merge lineUniforms, styleUniforms
      @line = @_renderables.make 'line',
                uniforms: uniforms
                samples:  items
                ribbons:  width
                strips:   height
                layers:   depth
                position: swizzle
                color:    color
                mask:     mask
      objects.push @line

    # Make face renderable
    if fill
      uniforms = Util.JS.merge styleUniforms, {}
      @face = @_renderables.make 'face',
                uniforms: uniforms
                width:    width
                height:   height
                depth:    depth
                items:    items
                position: position
                color:    color
                material: material
                mask:     mask
                map:      map
      objects.push @face

    @_helpers.visible.make()
    @_helpers.object.make objects

  made: () -> @resize()

  unmake: () ->
    @_helpers.bind.unmake()
    @_helpers.visible.unmake()
    @_helpers.object.unmake()

    @face = @line = null

  change: (changed, touched, init) ->
    return @rebuild() if changed['geometry.points'] or touched['mesh']

module.exports = Face