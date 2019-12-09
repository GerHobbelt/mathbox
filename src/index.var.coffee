THREE   = require 'three'
MathBox = require './index'

# Reproduce the global assignments of original MathBox
window.THREE = THREE
window.MathBox = MathBox
window.mathBox = MathBox.mathBox
window.π = Math.PI
window.τ = π * 2
window.e = Math.E