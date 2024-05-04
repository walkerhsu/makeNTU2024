import pygame
import random
import cv2
import numpy as np
from monster import Monster, get_monster_info
from player import Player, get_player_info
from setting import *

droid_cam_url = "http://10.10.2.250:4747/video" #If you are using DroidCam

camera_on = True
if camera_on:
    cap = cv2.VideoCapture(droid_cam_url) #If you are using DroidCam
    fps = cap.get(cv2.CAP_PROP_FPS)
    print("fps:", fps)
    cap.set(cv2.CAP_PROP_FPS, FPS)


pygame.init()
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption('Monster Shooter')
clock = pygame.time.Clock()

def main():
    running = True
    player = Player(*get_player_info())
    monster = Monster(*get_monster_info())
    score = 0
    while running:
        clock.tick(FPS)
        player_shoot = False
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.MOUSEBUTTONUP:
                player_shoot = True

        if camera_on:
            ret, frame = cap.read()
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame = cv2.flip(frame, 1)
            frame = np.rot90(frame)
            frame = cv2.resize(frame, (SCREEN_HEIGHT, SCREEN_WIDTH))
            frame = pygame.surfarray.make_surface(frame)
            screen.blit(frame, (0, 0))
        else:
            screen.fill(WHITE)

        if monster.is_alive():
            monster.display(screen)
            player.take_damage(monster.attack(player.cur_health))
        else:
            score += 1
            monster = Monster(*get_monster_info())

        if player.is_on():
            player_pos = player.get_pos()
            monster.move(player_pos)
            player.aim_display(screen, player_pos)
            monster.take_damage(player.shoot(player_shoot, monster.pos, monster.pic, player_pos))
                
        player.display_info(screen)

        pygame.display.flip()

    pygame.quit()


if __name__ == "__main__":
    main()