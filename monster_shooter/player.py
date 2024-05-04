import pygame
import time
from setting import *

def get_player_info():
    name = "Player"
    max_health = 200
    strength = 25
    max_ammo = 20
    max_reload_time = 100
    return name, max_health, strength, max_ammo, max_reload_time

class Player:
    def __init__(self, name, max_health, strength, max_ammo, max_reload_time):
        self.name = name
        self.max_health = max_health
        self.cur_health = max_health
        self.health_bar_length = SCREEN_WIDTH / 10
        self.health_ratio = self.max_health / self.health_bar_length
        self.strength = strength
        self.max_ammo = max_ammo
        self.ammo = max_ammo
        self.max_reload_time = max_reload_time
        self.reload_time = max_reload_time
        self.aim_pic = pygame.image.load("./pictures/aim.png")
        self.shoot_sfx = pygame.mixer.Sound("./sound_effect/shoot_sfx.mp3")
        self.shoot_sfx.set_volume(0.3)
        self.reload_sfx = pygame.mixer.Sound("./sound_effect/reload_sfx.mp3")
        self.damage_sfx = pygame.mixer.Sound("./sound_effect/damage_sfx.mp3")
        self.bullet_pic = pygame.image.load("./pictures/bullet_hole.png")
        self.bullet_pos = None
        self.skill_pic = pygame.image.load("./pictures/camera.png")
        self.health_pic = pygame.image.load("./pictures/health_pic.png")
        self.strength_pic = pygame.image.load("./pictures/atk_pic.png")
        self.ammo_pic = pygame.image.load("./pictures/ammo_pic.png")

    def is_alive(self):
        return self.cur_health > 0

    def aim_display(self, screen, player_pos):
        screen.blit(self.aim_pic, (player_pos[0]-50, player_pos[1]-50))
    
    def shoot(self, shoot_flag, monster, player_pos):
        if self.ammo > 0 and shoot_flag:
            self.shoot_sfx.play()
            self.bullet_pos = player_pos
            self.ammo -= 1
            if player_pos[0] >= monster.pos[0] and player_pos[0] <= monster.pos[0] + monster.pic.get_rect().size[0] and player_pos[1] >= monster.pos[1] and player_pos[1] <= monster.pos[1] + monster.pic.get_rect().size[1]:
                if monster.type == 0:
                    return self.strength
                else:
                    if player_pos[0] >= monster.weak_point_pos[0] and player_pos[0] <= monster.weak_point_pos[0] + monster.weak_point_size and player_pos[1] >= monster.weak_point_pos[1] and player_pos[1] <= monster.weak_point_pos[1] + monster.weak_point_size:
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
        pygame.image.save(frame, f"./pictures/{time.time()}.png")

    def display_info(self, screen, picture_wait_time):
        font = pygame.font.Font("./game_font.ttf", 36)
        screen.blit(self.health_pic, (10, 10))
        pygame.draw.rect(screen, RED, (self.health_pic.get_rect().size[0] + 10, 10 + self.health_pic.get_rect().size[1]/2 - int(SCREEN_HEIGHT / 64) , self.cur_health / self.health_ratio, int(SCREEN_HEIGHT / 32)))
        pygame.draw.rect(screen, BLACK, (self.health_pic.get_rect().size[0] + 10, 10 + self.health_pic.get_rect().size[1]/2 - int(SCREEN_HEIGHT / 64) , self.cur_health / self.health_ratio, int(SCREEN_HEIGHT / 32)), 4)
        screen.blit(self.strength_pic, (10, 20 + self.health_pic.get_rect().size[1]))
        atk_text = font.render(f"{self.strength}", True, BLUE)
        screen.blit(atk_text, (10 + self.strength_pic.get_rect().size[0] + 10, 20 + self.health_pic.get_rect().size[1] + self.strength_pic.get_rect().size[1]/2 - atk_text.get_height()/2))
        if self.ammo == 0:
            self.reload_time -= 1
            if self.reload_time == 0:
                self.reload_sfx.play()
                self.ammo = self.max_ammo
                self.reload_time = self.max_reload_time
            reload_text = font.render("RELOADING...", True, RED)
            screen.blit(reload_text, (screen.get_size()[0] - reload_text.get_width() - 10, 10))
        else:
            screen.blit(self.ammo_pic, (screen.get_size()[0] - self.ammo_pic.get_rect().size[0] - 10, 10))
            ammo_text = font.render(f"{self.ammo} / {self.max_ammo}", True, RED)
            screen.blit(ammo_text, (screen.get_size()[0] - ammo_text.get_width() - 10, 20 + self.ammo_pic.get_rect().size[1]))
        if self.bullet_pos:
            if self.bullet_pos[0] >= 0 and self.bullet_pos[1] >= 0 and self.bullet_pos[0] <= SCREEN_WIDTH and self.bullet_pos[1] <= SCREEN_HEIGHT:
                screen.blit(self.bullet_pic, (self.bullet_pos[0] - self.bullet_pic.get_rect().size[0] / 2, self.bullet_pos[1] - self.bullet_pic.get_rect().size[1] / 2))
        skill_pos = (SCREEN_WIDTH - 5*self.skill_pic.get_rect().size[0]/4, SCREEN_HEIGHT- 5*self.skill_pic.get_rect().size[1]/4)
        screen.blit(self.skill_pic, skill_pos)
        picture_text = font.render(f"{int(picture_wait_time/30)} SEC", True, BLUE)
        screen.blit(picture_text, (skill_pos[0] + self.skill_pic.get_rect().size[0]/2 - picture_text.get_width()/2, skill_pos[1] - picture_text.get_height() - 10))
        