import pygame
from setting import *

def get_player_info():
    name = "Player"
    max_health = 100
    strength = 10
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

    def aim_display(self, screen, player_pos):
        screen.blit(self.aim_pic, (player_pos[0]-50, player_pos[1]-50))

    def is_on(self):
        return True
    
    def get_pos(self):
        return pygame.mouse.get_pos()
    
    def shoot(self, player_shoot, monster_pos, monster_pic, player_pos):
        if player_shoot and self.ammo > 0:
            self.shoot_sfx.play()
            self.ammo -= 1
            if player_pos[0] >= monster_pos[0] and player_pos[0] <= monster_pos[0] + monster_pic.get_rect().size[0]:
                if player_pos[1] >= monster_pos[1] and player_pos[1] <= monster_pos[1] + monster_pic.get_rect().size[1]:
                    return self.strength
        return 0

    def take_damage(self, damage):
        if damage > 0:
            self.damage_sfx.play()
            self.cur_health -= damage

    def heal(self, amount):
        self.health += amount

    def gain_strength(self, amount):
        self.strength += amount

    def display_info(self, screen):
        font = pygame.font.Font(None, 36)
        health_text = font.render(f"Health: ", True, BLUE)
        screen.blit(health_text, (10, 10))
        pygame.draw.rect(screen, RED, (health_text.get_width() + 10, 10, self.cur_health / self.health_ratio, int(SCREEN_HEIGHT / 32)))
        pygame.draw.rect(screen, BLACK, (health_text.get_width() + 10, 10, self.health_bar_length, int(SCREEN_HEIGHT / 32)), 4)

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