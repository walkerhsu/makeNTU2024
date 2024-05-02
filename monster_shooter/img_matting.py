from rembg import remove
import cv2  
  
input_path = './pictuers/input.png' 
output_path = './pictures/output.png'
input = cv2.imread(input_path)
output = remove(input)
cv2.imwrite(output_path, output)