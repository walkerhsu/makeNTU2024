import pygame

#get full screen size
pygame.init()
info = pygame.display.Info()
print(info.current_w, info.current_h)
pygame.quit()
