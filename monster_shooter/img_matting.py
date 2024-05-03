from rembg import remove
import cv2  
  
input_path = './monster.png' 
output_path = './output.png'
input = cv2.imread(input_path)
img = remove(input)

top = (0, 0)
bottom = (0, 0)
left = (0, 0)
right = (0, 0)
for i in range(len(img)):
    for j in range(len(img[0])):
        if not all(img[i][j] == [0, 0, 0, 0]):
            top = (i, j)
            break
    if top != (0, 0):
        break
for i in range(len(img)-1, -1, -1):
    for j in range(len(img[0])):
        if not all(img[i][j] == [0, 0, 0, 0]):
            bottom = (i, j)
            break
    if bottom != (0, 0):
        break
for j in range(len(img[0])):
    for i in range(len(img)):
        if not all(img[i][j] == [0, 0, 0, 0]):
            left = (i, j)
            break
    if left != (0, 0):
        break
for j in range(len(img[0])-1, -1, -1):
    for i in range(len(img)):
        if not all(img[i][j] == [0, 0, 0, 0]):
            right = (i, j)
            break
    if right != (0, 0):
        break

cut_img = img[top[0]:bottom[0], left[1]:right[1]]

cv2.imwrite(output_path, cut_img)
