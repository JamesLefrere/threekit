Template.index.onCreated ->
	@camera = undefined
	@video = undefined
	@scene = undefined
	@renderer = undefined
	@isUserInteracting = false
	@onMouseDownMouseX = 0
	@onMouseDownMouseY = 0
	@onMouseDownLon = 0
	@onMouseDownLat = 0
	@onPointerDownPointerX = 0
	@onPointerDownPointerY = 0
	@onPointerDownLat = 0
	@onPointerDownLon = 0
	@lon = 0
	@lat = 0
	@phi = 0
	@theta = 0
	@container = undefined
	@mesh = undefined
	@texture = undefined
	@geometry = undefined
	@material = undefined
	@mesh = undefined
	return

Template.index.onRendered ->
	window.Index = t = this
	@init = ->
		t.video = document.createElement("video")
		# t.video.src = "/gipsstr360.mp4"
		t.video.src = "/schunemann360.mp4"
		t.video.load()
		t.container = document.getElementById("3")
		t.camera = new (THREE.PerspectiveCamera)(105, window.innerWidth / window.innerHeight, 1, 1100)
		t.camera.target = new (THREE.Vector3)(0, 0, 0)
		t.scene = new (THREE.Scene)
		t.geometry = new (THREE.SphereGeometry)(500, 24, 24)
		t.geometry.applyMatrix (new (THREE.Matrix4)).makeScale(-1, 1, 1)
		t.texture = new (THREE.VideoTexture)(t.video)
		t.texture.minFilter = THREE.LinearFilter
		t.texture.magFilter = THREE.LinearFilter
		t.material = new (THREE.MeshBasicMaterial)(
			map: t.texture
			overdraw: true
			side: THREE.DoubleSide
		)
		t.mesh = new (THREE.Mesh)(t.geometry, t.material)
		t.scene.add t.mesh
		t.renderer = new (THREE.WebGLRenderer)
		t.renderer.setPixelRatio window.devicePixelRatio
		t.renderer.setSize window.innerWidth, window.innerHeight
		t.container.appendChild t.renderer.domElement
		# t.video.play()
		return

	@animate = ->
		requestAnimationFrame t.animate
		t.update()
		return

	@update = ->
		# if t.isUserInteracting == false
			# t.lon += 0.1
		t.lat = Math.max(-85, Math.min(85, t.lat))
		t.phi = THREE.Math.degToRad(90 - t.lat)
		t.theta = THREE.Math.degToRad(t.lon)
		t.camera.target.x = -500 * Math.sin(t.phi) * Math.cos(t.theta)
		t.camera.target.y = -500 * Math.cos(t.phi)
		t.camera.target.z = -500 * Math.sin(t.phi) * Math.sin(t.theta)
		t.camera.lookAt t.camera.target

		###
		// distortion
		t.camera.position.copy( t.camera.target ).negate();
		###

		t.renderer.render t.scene, t.camera
		return

	$(window).resize ->
		t.camera.aspect = window.innerWidth / window.innerHeight
		t.camera.updateProjectionMatrix()
		t.renderer.setSize window.innerWidth, window.innerHeight
		return

	@init()
	@animate()

	return

Template.body.events
	"keyup": (e) ->
		t = Index
		e.preventDefault()
		if e.keyCode is 32
			if t.video.paused
				t.video.play()
			else
				t.video.pause()
		return
	"mousedown": (e) ->
		t = Index
		e.preventDefault()
		t.isUserInteracting = true
		t.onPointerDownPointerX = e.clientX
		t.onPointerDownPointerY = e.clientY
		t.onPointerDownLon = t.lon
		t.onPointerDownLat = t.lat
		return
	"mouseup": (e) ->
		t = Index
		t.isUserInteracting = false
		return
	"mousemove": (e) ->
		t = Index
		if t.isUserInteracting == true
			t.lon = (t.onPointerDownPointerX - e.clientX) * 0.1 + t.onPointerDownLon
			t.lat = (e.clientY - t.onPointerDownPointerY) * 0.1 + t.onPointerDownLat
		return
	"mousewheel, DOMMouseScroll": (e, t) ->
		t = Index
		t.camera.fov -= e.originalEvent.wheelDeltaY * 0.05
		t.camera.updateProjectionMatrix()
		return
