from diffusers import DiffusionPipeline
import torch

# print(torch.__version__)
# print(torch.cuda.is_available())

pipe = DiffusionPipeline.from_pretrained("stabilityai/stable-diffusion-xl-base-1.0", torch_dtype=torch.float16, use_safetensors=True, variant="fp16")
pipe.to("cuda")

# if using torch < 2.0
# pipe.enable_xformers_memory_efficient_attention()

prompt = "An endearing scene of a tiny, fluffy creature exploring a whimsical garden filled with oversized flowers and mushrooms, its pastel-colored fur blending harmoniously with the surreal surroundings, its heart-shaped tail wagging with excitement."

images = pipe(prompt=prompt).images[0]
#save the image
images.save("monster.png")