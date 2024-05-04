import pygame
import time
from setting import *

def get_player_info():
    name = "Player"
    max_health = 200
    strength = 25
    max_ammo = 20
    max_reload_time = 100
    max_picture_wait_time = 300
    return name, max_health, strength, max_ammo, max_reload_time, max_picture_wait_time

class Player:
    def __init__(self, name, max_health, strength, max_ammo, max_reload_time, max_picture_wait_time, screen_width, screen_height):
        self.name = name
        self.max_health = max_health
        self.cur_health = max_health
        self.health_bar_length = screen_width / 10
        self.health_ratio = self.max_health / self.health_bar_length
        self.strength = strength
        self.max_ammo = max_ammo
        self.ammo = max_ammo
        self.max_reload_time = max_reload_time
        self.reload_time = max_reload_time
        self.max_picture_wait_time = max_picture_wait_time
        self.picture_wait_time = 0
        self.aim_pic = pygame.image.load("./pictures/aim.png")
        self.shoot_sfx = pygame.mixer.Sound("./sound_effect/shoot_sfx.mp3")
        self.shoot_sfx.set_volume(0.3)
        self.reload_sfx = pygame.mixer.Sound("./sound_effect/reload_sfx.mp3")
        self.damage_sfx = pygame.mixer.Sound("./sound_effect/damage_sfx.mp3")
        self.bullet_pic = pygame.image.load("./pictures/bullet_hole.png")
        self.bullet_pos = None

    def is_alive(self):
        return self.cur_health > 0

    def aim_display(self, screen, player_pos):
        screen.blit(self.aim_pic, (player_pos[0]-50, player_pos[1]-50))
    
    def shoot(self, shoot_flag, monster_pos, monster_pic, player_pos, monster_type, weak_point_pos, weak_point_size):
        if self.ammo > 0 and shoot_flag:
            self.shoot_sfx.play()
            self.bullet_pos = player_pos
            self.ammo -= 1
            if player_pos[0] >= monster_pos[0] and player_pos[0] <= monster_pos[0] + monster_pic.get_rect().size[0] and player_pos[1] >= monster_pos[1] and player_pos[1] <= monster_pos[1] + monster_pic.get_rect().size[1]:
                if monster_type == 0:
                    return self.strength
                else:
                    if player_pos[0] >= weak_point_pos[0] and player_pos[0] <= weak_point_pos[0] + weak_point_size and player_pos[1] >= weak_point_pos[1] and player_pos[1] <= weak_point_pos[1] + weak_point_size:
                        return self.strength * 3
                    else:
                        return self.strength
        return 0
    
    def shoot_air(self, player_pos, shoot_flag):
        if self.ammo > 0 and shoot_flag:
            self.shoot_sfx.play()
            self.bullet_pos = player_pos
            self.ammo -= 1

    def take_damage(self, damage):
        if damage > 0:
            self.damage_sfx.play()
            self.cur_health -= damage

    def heal(self, amount):
        self.cur_health += amount
        if self.cur_health > self.max_health:
            self.max_health = self.cur_health

    def gain_strength(self, amount):
        self.strength += amount

    def gain_max_ammo(self, amount):
        self.max_ammo += amount

    def gain_max_reload_time(self, amount):
        self.max_reload_time += amount

    def take_picture(self, frame):
        if self.picture_wait_time >= 0:
            if self.picture_wait_time == 0:
                pygame.image.save(frame, f"./pictures/{time.time()}.png")
                self.picture_wait_time = self.max_picture_wait_time
            self.picture_wait_time -= 1

    def display_info(self, screen, screen_width, screen_height):
        font = pygame.font.Font(None, 36)
        health_text = font.render(f"Health: ", True, BLUE)
        screen.blit(health_text, (10, 10))
        pygame.draw.rect(screen, RED, (health_text.get_width() + 10, 10, self.cur_health / self.health_ratio, int(screen_height / 32)))
        pygame.draw.rect(screen, BLACK, (health_text.get_width() + 10, 10, self.health_bar_length, int(screen_height / 32)), 4)

        atk_text = font.render(f"Attack: {self.strength}", True, BLUE)
        screen.blit(atk_text, (10, 50))
        if self.ammo == 0:
            self.reload_time -= 1
            if self.reload_time == 0:
                self.reload_sfx.play()
                self.ammo = self.max_ammo
                self.reload_time = self.max_reload_time
            font = pygame.font.Font(None, 36)
            reload_text = font.render("Reloading...", True, RED)
            screen.blit(reload_text, (screen.get_size()[0] - reload_text.get_width() - 10, 10))
        else:              
            font = pygame.font.Font(None, 36)
            ammo_text = font.render(f"Ammo: {self.ammo} / {self.max_ammo}", True, RED)
            screen.blit(ammo_text, (screen.get_size()[0] - ammo_text.get_width() - 10, 10))
        if self.bullet_pos and self.bullet_pos[0] >= 0 and self.bullet_pos[1] >= 0 and self.bullet_pos[0] <= screen_width and self.bullet_pos[1] <= screen_height:
            screen.blit(self.bullet_pic, (self.bullet_pos[0] - self.bullet_pic.get_rect().size[0] / 2, self.bullet_pos[1] - self.bullet_pic.get_rect().size[1] / 2))