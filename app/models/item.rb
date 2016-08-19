class Item < ActiveRecord::Base
  has_many :builds
  has_many :champions, through: :builds

  has_many :projected_builds
  has_many :champions, through: :builds

  validates :item_identifier, uniqueness: true

  serialize :gold
  serialize :stats
  serialize :effect

  def self.seed_item_list
    # The goal of this method is to create and seed the database with items from the
    # RiotAPI item static data endpoint. Most nested attributes including gold cost are going to be
    # serialized and just saved as a hash. 

    riot_item_tags = [
      "Boots",
      "ManaRegen",
      "HealthRegen",
      "Health",
      "CriticalStrike",
      "SpellDamage",
      "Mana",
      "Armor",
      "SpellBlock",
      "Damage",
      "Lane",
      "AttackSpeed",
      "OnHit",
      "LifeSteal",
      "Consumable",
      "Jungle",
      "Active",
      "Stealth",
      "Vision",
      "NonbootsMovement",
      "Tenacity",
      "SpellVamp",
      "Aura",
      "CooldownReduction",
      "MagicPenetration",
      "Slow",
      "ArmorPenetration",
      "GoldPer",
      "Trinket",
      "Bilgewater"
    ]

    # Need to still create a hash on the item that takes it's own stats and converts the bonus to a tag.
    # Will be CamelCase

    # Key:
    # good_against = good AGAINST other tags
    # good_for = COMPLIMENTS other tags
    # good_on = good on specific champiosn
    # good_at = good at what stage of the game
    item_tags = {
      "Boots of Speed" => {
        :champion_specific => nil, 
        :good_against => ["poke", "skillshots"],  
        :good_for => ["mobility", "Boots"], 
        :good_on => ["all"],
        :good_at => [:early, :first_buy]
        },
      "Faerie Charm" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["ManaRegen", "Support"], 
        :good_on => [],
        :good_at => [:early, :first_buy]
        },
      "Rejuvenation Bead" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["HealthRegen"], 
        :good_on => [],
        :good_at => []
        },
      "Giant's Belt" => {
        :champion_specific => nil, 
        :good_against => ["true_damage", "high_burst"],  
        :good_for => ["tank"], 
        :good_on => [],
        :good_at => [:early, :first_buy]
        },
      "Cloak of Agility" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman"], 
        :good_on => ["Jhin"],
        :good_at => [] 
        },
      "Blasting Wand" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Mage"], 
        :good_on => [],
        :good_at => [] 
        },
      "Sapphire Crystal" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Mana"], 
        :good_on => ["Ryze"],
        :good_at => [:first_buy] 
        },
      "Ruby Crystal" => {
        :champion_specific => nil, 
        :good_against => ["true_damage", "high_burst"],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Cloth Armor" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["Tank"], 
        :good_on => [],
        :good_at => [] 
        },
      "Chain Vest" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["Tank"], 
        :good_on => [],
        :good_at => [:early, :first_buy] 
        },
      "Null-Magic Mantle" => {
        :champion_specific => nil, 
        :good_against => ["magic_damage"],  
        :good_for => ["Tank"], 
        :good_on => [],
        :good_at => [] 
        },
      "Long Sword" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["physical_damage"], 
        :good_on => [],
        :good_at => [] 
        },
      "Pickaxe" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [:early, :first_buy] 
        },
      "B. F. Sword" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [:early, :first_buy] 
        },
      "Dagger" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [] 
        },
      "Recurve Bow" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [] 
        },
      "Brawler's Gloves" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => ["Gangplank"],
        :good_at => [] 
        },
      "Amplifying Tome" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["cooldowns", "Mage"], 
        :good_on => [],
        :good_at => [:early, :first_buy] 
        },
      "Vampiric Scepter" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Negatron Cloak" => {
        :champion_specific => nil, 
        :good_against => ["magic_damage", "Mage"],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Needlessly Large Rod" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Mage"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Cull" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [:never] 
        },
      "Health Potion" => {
        :champion_specific => nil, 
        :good_against => ["poke"],  
        :good_for => ["HealthRegen"], 
        :good_on => ["all"],
        :good_at => [:early, :first_buy] 
        },
      "Total Biscuit of Rejuvenation" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => ["all"],
        :good_at => [:early, :first_buy] 
        },
      "Kircheis Shard" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => ["Marksman", "physical_damage"],
        :good_at => [] 
        },
      "Refillable Potion" => {
        :champion_specific => nil, 
        :good_against => ["poke"],  
        :good_for => ["HealthRegen"], 
        :good_on => ["all"],
        :good_at => [:early, :first_buy, :priority] 
        },
      "Corrupting Potion" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["HealthRegen"], 
        :good_on => [],
        :good_at => [:early] 
        },
      "Oracle's Extract" => {
        :champion_specific => nil, 
        :good_against => ["steath"],  
        :good_for => ["tanky", "Tank", "Fighter"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Explorer's Ward" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [:never] 
        },
      "Guardian's Horn" => {
        :champion_specific => nil, 
        :good_against => ["Marksman", "physical_damage"],  
        :good_for => ["Tank", "tanky"], 
        :good_on => [],
        :good_at => [] 
        },
      "Elixir of Iron" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [:late] 
        },
      "Elixir of Sorcery" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [:late] 
        },
      "Elixir of Wrath" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [:late] 
        },
      "Abyssal Scepter" => {
        :champion_specific => nil, 
        :good_against => ["magic_damage", "MagicPenetration", "Mage"],  
        :good_for => ["magic_damage", "aoe_cc"], 
        :good_on => ["Amumu", "Diana", "Kassadin", "LeBlanc", "Fiddlesticks", "Malphite"],
        :good_at => [:early, :mid] 
        },
      "Archangel's Staff" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["magic_damage", "shield", "ManaRegen", "Mana"], 
        :good_on => ["Ryze", "Karthus", "Swain", "Singed", "Anivia"],
        :good_at => [:mid] 
        },
      "Manamune" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["physical_damage", "ManaRegen", "Mana"], 
        :good_on => ["Kha'Zix", "Ezreal", "Urgot", "Jayce"],
        :good_at => [:mid, :late] 
        },
      "Berserker's Greaves" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Boots of Swiftness" => {
        :champion_specific => nil, 
        :good_against => ["roots", "slows"],  
        :good_for => ["mobile", "Tank", "tanky"], 
        :good_on => ["Hecarim", "Udyr"],
        :good_at => [:early, :mid] 
        },
      "Catalyst of Aeons" => {
        :champion_specific => nil, 
        :good_against => ["poke", "good_scaling"],  
        :good_for => ["HealthRegen", "ManaRegen", "Health", "tanky", "Mana", "Mage"], 
        :good_on => ["Morgana", "Lissandra", "Lulu", "Ryze", 'Kassadin', "Singed", "Cho'gath", "Annie", "Swain", "Anivia", "Gragas", "Diana"],
        :good_at => [:early, :first_buy, :mid, :priority] 
        },
      "Sorcerer's Shoes" => {
        :champion_specific => nil, 
        :good_against => ["MagicResist"],
        # Tag doesn't exist yet. 
        :good_for => ["MagicPenetration", "Mage", "magic_damage"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Frozen Mallet" => {
        :champion_specific => nil, 
        :good_against => [ "mobile"],  
        :good_for => ["Tank", "tanky", "Health"], 
        :good_on => ["Sion", "Garen"],
        :good_at => [:late]
        },
      "Glacial Shroud" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["cooldowns", "Tank", "tanky", "Mana"], 
        :good_on => [],
        :good_at => [] 
        },
      "Iceborn Gauntlet" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["cooldowns", "Tank", "tanky", "Mana"], 
        :good_on => ["Ezreal", "Gragas", "Blitzcrank", "Malphite", "Yorick", "Skarner"],
        :good_at => [:mid, :late] 
        },
      "Rod of Ages" => {
        :champion_specific => nil, 
        :good_against => ["poke", "good_scaling"],  
        :good_for => ["HealthRegen", "ManaRegen", "Health", "tanky", "Mana", "Mage"], 
        :good_on => ["Morgana", "Lissandra", "Lulu", "Ryze", 'Kassadin', "Singed", "Cho'gath", "Annie", "Swain", "Anivia", "Gragas", "Diana"],
        :good_at => [:late, :priority] 
        },
      "Chalice of Harmony" => {
        :champion_specific => nil, 
        :good_against => ["Mage", "magic_damage"],  
        :good_for => ["ManaRegen", "MagicResist"], 
        :good_on => [],
        :good_at => [:early] 
        },
      "Hextech GLP-800" => {
        :champion_specific => nil, 
        :good_against => ["mobilie"],  
        :good_for => ["HealthRegen", "ManaRegen", "Health", "tanky", "Mana", "Mage"], 
        :good_on => [],
        :good_at => [] 
        },
      "Infinity Edge" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Marksman", "physical_damage"], 
        :good_on => ["Jhin", "Caitlyn", "Jinx", "Sivir", "Twitch"],
        :good_at => [:late] 
        },
      "Mortal Reminder" => {
        :champion_specific => nil, 
        :good_against => ["self_healing", "Support", "healer"],  
        :good_for => ["physical_damage", "Marksman"], 
        :good_on => [],
        :good_at => [:mid, :late, :priority] 
        },
      "Giant Slayer" => {
        :champion_specific => nil, 
        :good_against => ["Tank", "Fighter", "Health", "tanky"],  
        :good_for => ["physical_damage", "Marksman"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Last Whisper" => {
        :champion_specific => nil, 
        :good_against => ["Tank", "Fighter", "Health", "tanky", "Armor"],  
        :good_for => ["physical_damage", "Marksman"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Lord Dominik's Regards" => {
        :champion_specific => nil, 
        :good_against => ["Tank", "Fighter", "Health", "tanky", "Armor"],  
        :good_for => ["physical_damage", "Marksman"], 
        :good_on => [],
        :good_at => [:late, :priority] 
        },
      "Jaurim's Fist" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Health", "physical_damage"], 
        :good_on => ["Sion"],
        :good_at => [:early, :first_buy] 
        },
      "Seraph's Embrace" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["magic_damage", "shield", "ManaRegen", "Mana"], 
        :good_on => ["Ryze", "Karthus", "Swain", "Singed", "Anivia"],
        :good_at => [:late] 
        },
      "Muramana" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["physical_damage", "ManaRegen", "Mana"], 
        :good_on => ["Kha'Zix", "Ezreal", "Urgot", "Jayce"],
        :good_at => [:late] 
        },
      "Phage" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["initiator", "Fighter", "Tank", "physical_damage", "mobile", "tanky"], 
        :good_on => ["Garen", "Jarvan IV", "Sion", "Kha'Zix", "Vi"],
        :good_at => [:early, :mid] 
        },
      "Phantom Dancer" => {
        :champion_specific => nil, 
        :good_against => ["Fighter", "Mage"],  
        :good_for => ["Marksman", "physical_damage", "high_dps"], 
        :good_on => ["Caitlyn", "Jinx", "Vayne", "Draven"],
        :good_at => [:mid, :late] 
        },
      "Ninja Tabi" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage", "Marksman", "AttackSpeed"],  
        :good_for => ["Tank", "tanky", "Fighter"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Zeke's Harbinger" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Forbidden Idol" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["ManaRegen", "Support", "healer"], 
        :good_on => [],
        :good_at => [] 
        },
      "Sterak's Gage" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Tank", "tanky", "physical_damage", "Shield"], 
        :good_on => ["Sion", "Riven"],
        :good_at => [:mid, :late] 
        },
      "Sheen" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Mana", "physical_damage"], 
        :good_on => ["Ezreal", "Trundle", "Jax", "Yorick", "Vi", "Skarner", "Irelia", "Blitzcrank"],
        :good_at => [:early] 
        },
      "Banner of Command" => {
        :champion_specific => nil, 
        :good_against => ["weaveclear", "magic_damage"],  
        :good_for => ["waveclear", "siege", "Support"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Spirit Visage" => {
        :champion_specific => nil, 
        :good_against => ["Mage", "magic_damage", "poke"],  
        :good_for => ["HealthRegen", "MagicResist", "Tank", "tanky", "cooldowns", "CooldownReduction", "self_healing"], 
        :good_on => ["Volibear", "Singed", "Trundle", "Dr.Mundo"],
        :good_at => [:mid, :late] 
        },
      "Kindlegem" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Health", "cooldowns", "CooldownReduction"], 
        :good_on => [],
        :good_at => [:early, :mid] 
        },
      "Sunfire Cape" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["initiator", "Tank", "tanky", "Fighter"], 
        :good_on => ["Amumu", "Sion", "Trundle", "Renekton", "Gnar", "Dr.Mundo"],
        :good_at => [:mid] 
        },
      "Talisman of Ascension" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["Support", "healer", "initiator", "Tank", "Tanky"], 
        :good_on => [],
        :good_at => [] 
        },
      "Tear of the Goddess" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => ["Mana", "Mage", "poke"], 
        :good_on => ["Sona", "Ezreal", "Jayce", "Urgot"],
        :good_at => [:early, :mid, :priority] 
        },
      "The Black Cleaver" => {
        :champion_specific => nil, 
        :good_against => ["Armor", "Tank", "tanky", "Fighter", "Marksman"],  
        :good_for => ["physical_damage", "ArmorPenetration", "Health", "CooldownReduction", "cooldowns"], 
        :good_on => ["Wukong", "Jarvan IV", "Talon", "Lee Sin", "Pantheon", "Riven", "Urgot"],
        :good_at => [:mid, :late] 
        },
      "The Bloodthirster" => {
        :champion_specific => nil, 
        :good_against => ["Fighter", "Tank"],  
        :good_for => ["Marksman", "physical_damage", "LifeSteal"], 
        :good_on => [],
        :good_at => [:late] 
        },
      "Ravenous Hydra" => {
        :champion_specific => nil, 
        :good_against => ["squishy"],  
        :good_for => ["physical_damage", "high_burst", "LifeSteal"], 
        :good_on => ["Kha'Zix", "Riven", "Talon"],
        :good_at => [:mid] 
        },
      "Thornmail" => {
        :champion_specific => nil, 
        :good_against => ["physical_damage"],  
        :good_for => ["Tank", "Fighter", "tanky"], 
        :good_on => ["Rammus"],
        :good_at => [:late] 
        },
      "Tiamat" => {
        :champion_specific => nil, 
        :good_against => ["squishy"],  
        :good_for => ["physical_damage", "high_burst"], 
        :good_on => ["Kha'zix", "Riven", "Talon"],
        :good_at => [:early] 
        },
      "Trinity Force" => {
        :champion_specific => nil, 
        :good_against => ["squishy"],
        :good_for => ["physical_damage", "Health", "NonbootsMovement", "Mana", "cooldowns", "CooldownReduction", "AttackSpeed"], 
        :good_on => ["Jax", "Ezreal", "Wukong", "Corki", "Udyr"],
        :good_at => [:mid, :late, :priority] 
        },
      "Warden's Mail" => {
        :champion_specific => nil, 
        :good_against => ["Marksman", "AttackSpeed", "physical_damage"],  
        :good_for => ["Tank", "tanky", "Fighter"], 
        :good_on => [],
        :good_at => [:mid] 
        },
      "Warmog's Armor" => {
        :champion_specific => nil, 
        :good_against => ["true_damage", "high_burst", "poke"],  
        :good_for => ["Tank", "tanky", "CooldownReduction", "cooldowns"], 
        :good_on => [],
        :good_at => [] 
        },
      "Nashor's Tooth" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Runaan's Hurricane" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Zeal" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Statikk Shiv" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Rabadon's Deathcap" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Wit's End" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Frost Queen's Claim" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Rapid Firecannon" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Nomad's Medallion" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Targon's Brace" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Frostfang" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Lich Bane" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Stinger" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Banshee's Veil" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Aegis of the Legion" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Fiendish Codex" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Frozen Heart" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Mercury's Treads" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Guardian's Orb" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Aether Wisp" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Rylai's Crystal Scepter" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Boots of Mobility" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Executioner's Calling" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Guinsoo's Rageblade" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Caulfield's Warhammer" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Serrated Dirk" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Void Staff" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Haunting Guise" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Mercurial Scimitar" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Quicksilver Sash" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Youmuu's Ghostblade" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Randuin's Omen" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Bilgewater Cutlass" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Hextech Revolver" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Hextech Gunblade" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Duskblade of Draktharr" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Liandry's Torment" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Hextech Protobelt-01" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Guardian's Hammer" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Blade of the Ruined King" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Hexdrinker" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Maw of Malmortius" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Zhonya's Hourglass" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Ionian Boots of Lucidity" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Morellonomicon" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Athene's Unholy Grail" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Locket of the Iron Solari" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Seeker's Armguard" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "The Hex Core mk-1" => {
        :champion_specific => "Viktor", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "The Hex Core mk-2" => {
        :champion_specific => "Viktor", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Perfect Hex Core" => {
        :champion_specific => "Viktor", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Prototype Hex Core" => {
        :champion_specific => "Viktor", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Spectre's Cowl" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Mikael's Crucible" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Luden's Echo" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Ancient Coin" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Relic Shield" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Spellthief's Edge" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Sweeping Lens (Trinket)" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Farsight Alteration" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Oracle Alteration" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Face of the Mountain" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Ardent Censer" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Essence Reaver" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Dead Man's Plate" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Titanic Hydra" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Bami's Cinder" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Righteous Glory" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Crystalline Bracer" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Lost Chapter" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Death's Dance" => {
        :champion_specific => nil, 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Fire at Will" => {
        :champion_specific => "Gangplank", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Death's Daughter" => {
        :champion_specific => "Gangplank", 
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => [] 
        },
      "Raise Morale" => {
        :champion_specific => "Gangplank",
        :good_against => [],  
        :good_for => [], 
        :good_on => [],
        :good_at => []  
        }
    }

    # .gsub("<[^>]*>", ""); A regex to strip tags out from the description if need be.

    request = "http://ddragon.leagueoflegends.com/cdn/6.12.1/data/en_US/item.json"
    response = HTTParty.get(request)
    items = response.parsed_response

    # puts JSON.pretty_generate(items)

    items["data"].each do |key, data|
      item = Item.new
      item.item_identifier = key
      item.name = data['name']
      item.image = "http://ddragon.leagueoflegends.com/cdn/6.14.1/img/item/#{key}.png"
      item.description = data['description']
      item.short_description = data['plaintext']

      item.group = data['group']
      item.tags = data['tags']
      item.aram_item = data['maps']['12'] == true || false
      item.build_depth = data['depth'].to_i

      item.gold = data['gold']
      item.stats = data['stats']
      item.effect = data['effect']

      if item_tags.key? data['name']
        item.good_against = item_tags[data['name']][:good_against]
        item.good_on = item_tags[data['name']][:good_on]
        item.good_at = item_tags[data['name']][:good_at]
      end

      if item.save
        puts "#{item.name} was saved!"
      else
        puts 'Item was not saved.'
      end
    end
  end
end
