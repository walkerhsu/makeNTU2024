import pygame
import time
import cv2
import numpy as np
import requests as req
from monster import Monster, get_monster_info
from player import Player, get_player_info
from setting import *
from gesture_predictor import GesturePredictor

monsters_info_http = "http://10.10.2.97:8000/get_monsters_info"
player_info_http = "http://10.10.2.97:8000/get_user_info"
post_url = "http://10.10.2.97:8000/game_ended"

def fetch_monster_info():
    monsters_info = req.get(monsters_info_http)
    return monsters_info.json()

def update_player_info(player):
    player_info = req.get(player_info_http)
    player_info = player_info.json()[0]
    print(player_info)
    player.heal(player_info["HP"])
    player.gain_strength(player_info["ATK"])
    player.gain_max_ammo(player_info["MAXAMMO"])
    player.gain_max_reload_time(player_info["RELTIME"])

GESTURES = ['aim', 'shoot', 'observe', 'idle']
g = GesturePredictor()
g.run()

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
    shoot_flag = True
    fetch_count_down = 0
    monster_list = []
    cur_monster_index = 0
    idle_flag = True
    while running:
        clock.tick(FPS)
        gesture, pos, _ =  g.get_gesture()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

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

        if gesture == 'observe':
            player.take_picture(frame)

        if idle_flag:
            if fetch_count_down == 0:
                update_player_info(player)
                monster_json = fetch_monster_info()
                if monster_json:
                    monster_list = get_monster_info(monster_json)
                    if len(monster_list) > 0:
                        cur_monster_index = 0
                        idle_flag = False
                fetch_count_down = 60
            else:
                fetch_count_down -= 1

        if idle_flag:
            if gesture == 'aim' or gesture == 'shoot':
                player_pos = pos
                player.aim_display(screen, player_pos)
                if gesture == 'shoot':
                    player.shoot_air(shoot_flag)
                    shoot_flag = False
                else:
                    shoot_flag = True
            player.display_info(screen)
        else:
            monster = monster_list[cur_monster_index]
            if monster.is_alive():
                monster.display(screen)
                player.take_damage(monster.attack(player.cur_health))
                if not player.is_alive():
                    idle_flag = True
                    req.post(post_url, json = {'status': "loss"})
                    continue
            else:
                cur_monster_index += 1
                if cur_monster_index >= len(monster_list):
                    idle_flag = True
                    #post win or loss to server
                    req.post(post_url, json = {'status': "win"})
                    continue
            if gesture == 'aim' or gesture == 'shoot':
                player_pos = pos
                monster.move(player_pos)
                player.aim_display(screen, player_pos)
                if gesture == 'shoot':
                    monster.take_damage(player.shoot(shoot_flag, monster.pos, monster.pic, player_pos, monster.monster_type, monster.weak_point_pos, monster.weak_point_size))
                    shoot_flag = False
                else:
                    shoot_flag = True
            player.display_info(screen)

        pygame.display.flip()

    pygame.quit()


if __name__ == "__main__":
    main()