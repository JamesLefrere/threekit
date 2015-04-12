Template.index.onCreated ->
	@cameras = []
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
	@sphere = undefined
	@cube = undefined
	@material = undefined
	@mesh = undefined
	@stats = undefined
	return

Template.index.onRendered ->
	window.Index = t = this
	
	@init = ->
		t.stats = new Stats
		t.stats.setMode 0
		t.stats.domElement.style.position = "absolute"
		t.stats.domElement.style.left = "5px"
		t.stats.domElement.style.top = "5px"
		document.body.appendChild t.stats.domElement

		t.video = document.createElement("video")
		# t.video.src = "/gipsstr360.mp4"
		t.video.src = "/schunemann360.mp4"
		t.video.load()
		t.container = document.getElementById("3")

		for i in [0..5] by 1
			t.cameras[i] = new (THREE.PerspectiveCamera)(90, 1, 1, 1100)

		t.cameras[0].lookAt new (THREE.Vector3)(0, 90, 0) # up
		t.cameras[1].lookAt new (THREE.Vector3)(0, -90, 0) # down
		t.cameras[2].lookAt new (THREE.Vector3)(0, 0, 90) # left
		t.cameras[3].lookAt new (THREE.Vector3)(90, 0, 0) # right
		t.cameras[4].lookAt new (THREE.Vector3)(0, 0, -90) # front
		t.cameras[5].lookAt new (THREE.Vector3)(-90, 0, 0) # back

		t.scene = new (THREE.Scene)
		t.sphere = new (THREE.SphereGeometry)(500, 32, 16)
		t.sphere.applyMatrix (new (THREE.Matrix4)).makeScale(-1, 1, 1)

		t.texture = new (THREE.VideoTexture)(t.video)
		t.texture.minFilter = THREE.LinearFilter
		t.texture.magFilter = THREE.LinearFilter
		t.material = new (THREE.MeshBasicMaterial)(
			map: t.texture
			overdraw: true
			side: THREE.FrontSide
		)

		t.mesh = new (THREE.Mesh)(t.sphere, t.material)
		t.scene.add t.mesh

		t.cube = new THREE.BoxGeometry(1, 1, 1)

		# t.mesh = new (THREE.Mesh)(t.cube, t.material)

		# basicMaterial = new (THREE.MeshBasicMaterial)(color: 0x000000)
		# basicMesh = new (THREE.Mesh)(t.sphere, basicMaterial)
		# edges = new THREE.EdgesHelper(basicMesh, 0xeebb00)
		# edges.material.linewidth = 4
		# t.scene.add edges

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
		t.stats.begin()
		# if t.isUserInteracting == false
			# t.lon += 0.1
		t.lat = Math.max(-85, Math.min(85, t.lat))
		t.phi = THREE.Math.degToRad(90 - t.lat)
		t.theta = THREE.Math.degToRad(t.lon)

		t.mesh.rotateY(t.theta)

		# t.cameras[2].target.x = 500 * Math.sin(t.phi) * Math.cos(t.theta)
		# t.cameras[2].target.y = 500 * Math.cos(t.phi)
		# t.cameras[2].target.z = 500 * Math.sin(t.phi) * Math.sin(t.theta)
		# t.cameras[2].lookAt t.cameras[2].target
		# t.cameras[5].target.x = 500 * Math.sin(t.phi) * Math.cos(t.theta)
		# t.cameras[5].target.y = 500 * Math.cos(t.phi)
		# t.cameras[5].target.z = 500 * Math.sin(t.phi) * Math.sin(t.theta)
		# t.cameras[5].lookAt t.cameras[5].target

		###
		// distortion
		t.camera.position.copy( t.camera.target ).negate();
		###

		width = window.innerWidth / 2
		height = window.innerHeight

		# up
		# t.renderer.setViewport 120, 240, width, height
		# t.renderer.setScissor 120, 240, width, height
		# t.renderer.enableScissorTest true
		# t.renderer.render t.scene, t.cameras[0]

		# down
		# t.renderer.setViewport 120, 0, width, height
		# t.renderer.setScissor 120, 0, width, height
		# t.renderer.enableScissorTest true
		# t.renderer.render t.scene, t.cameras[1]

		# left
		t.renderer.setViewport 0, 0, width, height
		t.renderer.setScissor 0, 0, width, height
		t.renderer.enableScissorTest true
		t.renderer.render t.scene, t.cameras[2]

		# right
		# t.renderer.setViewport 360, 120, width, height
		# t.renderer.setScissor 360, 120, width, height
		# t.renderer.enableScissorTest true
		# t.renderer.render t.scene, t.cameras[3]

		# front
		# t.renderer.setViewport 240, 120, width, height
		# t.renderer.setScissor 240, 120, width, height
		# t.renderer.enableScissorTest true
		# t.renderer.render t.scene, t.cameras[4]

		# back
		t.renderer.setViewport width, 0, width, height
		t.renderer.setScissor width, 0, width, height
		t.renderer.enableScissorTest true
		t.renderer.render t.scene, t.cameras[5]

		t.stats.end()
		return

	$(window).resize ->
		# t.camera.aspect = window.innerWidth / window.innerHeight
		# for camera in t.cameras
			# camera.updateProjectionMatrix()
		t.cameras[2].updateProjectionMatrix()
		t.cameras[5].updateProjectionMatrix()
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
