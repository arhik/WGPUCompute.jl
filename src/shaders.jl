using WGPUCore
using Reexport

export createShaderObj

struct ShaderObj
	src
	internal
	info
end

function createShaderObj(gpuDevice, shaderCode, shaderBuffer; savefile=false, debug = false)
	seek(shaderBuffer, 0)
	@info shaderCode
	shaderInfo = WGPUCore.loadWGSL(read(shaderBuffer))

	shaderObj = ShaderObj(
		shaderCode,
		WGPUCore.createShaderModule(
			gpuDevice,
			"shaderCode",
			shaderInfo.shaderModuleDesc,
			nothing,
			nothing
		) |> Ref,
		shaderInfo
	)

	if shaderObj.internal[].internal[] == Ptr{Nothing}()
		@error "Shader Obj creation failed"
		@info "Dumping shader to scratch.wgsl for later inspection"
		file = open("scratch.wgsl", "w")
		write(file, shaderSource)
		close(file)
		try
			run(`naga scratch.wgsl`)
		catch(e)
			@info shaderCode
			rethrow(e)
		end
	end

	return shaderObj
end

