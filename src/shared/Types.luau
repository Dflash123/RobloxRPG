--[[
    Types.luau
    공용 타입 정의 모듈 (서버/클라이언트 공유)
    새로운 타입 추가 시 이 파일에만 추가
--]]

export type Role = "Tank" | "DPS" | "Healer"
export type Difficulty = "Normal" | "Hard" | "Extreme" | "Mythic"
export type Rarity = "Common" | "Rare" | "Epic" | "Legendary" | "Mythic"
export type ItemType = "Weapon" | "Armor" | "Accessory"
export type StatusEffect = "Stun" | "Slow" | "Burn" | "Silence" | "Taunt"

export type Stats = {
    MaxHP: number,
    Defense: number,
    AttackPower: number,
    HealPower: number,
    Speed: number,
    CritRate: number,    -- 0.0 ~ 1.0
    CritDamage: number,  -- 배율 (기본 1.5)
}

export type RandomOption = {
    Type: string,
    Value: number,
}

export type Item = {
    InstanceId: string,
    ItemId: string,
    Name: string,
    Type: ItemType,
    Rarity: Rarity,
    Enhancement: number,
    BaseStats: { [string]: number },
    RandomOptions: { RandomOption },
    SetID: string?,
}

export type PartyMember = {
    Player: Player,
    Role: Role,
    ClassId: string,
}

export type Party = {
    Id: string,
    Leader: Player,
    Members: { PartyMember },
    MaxSize: number,
    Status: "Idle" | "InDungeon" | "Waiting",
}

export type DungeonInstance = {
    Id: string,
    PartyId: string,
    DungeonId: string,
    Difficulty: Difficulty,
    StartTime: number,
    CurrentWave: number,
    IsActive: boolean,
}

export type BossPattern = {
    Name: string,
    TriggerHP: number,
    Action: string,
    RequiresRole: Role?,
    TimeLimit: number?,
    DPSCheck: number?,
    OnFail: "GroupDamage" | "Wipe",
}

return {}
