import pygame
import random
from setting import *

def get_monster_info(monster_json):
    monster_list = []
    for monster in monster_json:
        name = monster["name"]
        max_health = monster["HP"]
        strength = monster["ATK"]
        attack_time = 300 / monster["ATKSPD"]
        pic = pygame.image.load("./pictures/output.png")
        pos = (random.randint(0, SCREEN_WIDTH - pic.get_rect().size[0]), random.randint(0, SCREEN_HEIGHT - pic.get_rect().size[1]))
        speed = monster["MVSPD"]
        monster_type = monster["TYPE"]
        monster_list.append(Monster(name, max_health, strength, attack_time, pic, pos, speed, monster_type))
    return monster_list

# def get_monster_info():
#     name = "Monster"
#     max_health = 30
#     strength = 10
#     attack_time = 200
#     pic = pygame.image.load("./pictures/output.png")
#     pos = (random.randint(0, SCREEN_WIDTH - pic.get_rect().size[0]), random.randint(0, SCREEN_HEIGHT - pic.get_rect().size[1]))
#     speed = 1
#     monster_type = 0
#     return name, max_health, strength, attack_time, pic, pos, speed, monster_type

class Monster:
    def __init__(self, name, max_health, strength, attack_time, pic, pos, speed, monster_type):
        self.name = name
        self.max_health = max_health
        self.cur_health = max_health
        self.health_bar_len = pic.get_rect().size[0] / 2
        self.health_ratio = self.max_health / self.health_bar_len
        self.strength = strength
        self.attack_time = attack_time
        self.cooldown = attack_time
        self.pic = pic
        self.pos = pos
        self.speed = speed
        self.monster_type = monster_type
        self.weak_point_size_min = 10
        self.weak_point_size_max = 40
        self.weak_point_size = 10
        self.weak_point_pos = (random.randint(self.pos[0] + 50, self.pos[0] + self.pic.get_rect().size[0] - 50), random.randint(self.pos[1] + 50, self.pos[1] + self.pic.get_rect().size[1] - 50))

    def is_on(self):
        return True

    def attack(self, player_health):
        if self.is_on():
            if player_health > 0:
                self.cooldown -= 1
                if self.cooldown == 0:
                    self.cooldown = self.attack_time
                    return self.strength
            return 0

    def take_damage(self, damage):
        if damage > 0:
            self.cur_health -= damage


    def is_alive(self):
        return self.cur_health > 0
    
    def display(self, screen):
        screen.blit(self.pic, self.pos)
        pygame.draw.rect(screen, RED, (self.pos[0] + int(self.pic.get_rect().size[0] / 2 - self.health_bar_len / 2), self.pos[1] - 15, self.cur_health / self.health_ratio, int(SCREEN_HEIGHT / 32)))
        pygame.draw.rect(screen, BLACK, (self.pos[0] + int(self.pic.get_rect().size[0] / 2 - self.health_bar_len / 2), self.pos[1] - 15, self.health_bar_len, int(SCREEN_HEIGHT / 32)), 4)
        #draw weak point that will change size
        if self.monster_type == 1:
            if self.weak_point_size <= self.weak_point_size_max and self.weak_point_size >= self.weak_point_size_min:
                self.weak_point_size += 0.2
            else:
                self.weak_point_size = self.weak_point_size_min
            pygame.draw.circle(screen, GREEN, self.weak_point_pos, self.weak_point_size, 3)
        
    def move(self, player_pos):
        if self.pos[0] + self.pic.get_rect().size[0] < SCREEN_WIDTH and self.pos[1] + self.pic.get_rect().size[0] < SCREEN_HEIGHT and self.pos[0] > 0 and self.pos[1] > 0:
            if player_pos[0] >= self.pos[0] and player_pos[0] <= self.pos[0] + self.pic.get_rect().size[0]:
                if player_pos[1] >= self.pos[1] and player_pos[1] <= self.pos[1] + self.pic.get_rect().size[1]:
                    if player_pos[0] > self.pos[0] + self.pic.get_rect().size[0] / 2:
                        self.pos = (self.pos[0] - self.speed, self.pos[1])
                    else:
                        self.pos = (self.pos[0] + self.speed, self.pos[1])
                    if player_pos[1] > self.pos[1] + self.pic.get_rect().size[1] / 2:
                        self.pos = (self.pos[0], self.pos[1] - self.speed)
                    else:
                        self.pos = (self.pos[0], self.pos[1] + self.speed)
    

