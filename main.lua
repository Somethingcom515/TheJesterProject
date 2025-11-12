SMODS.Atlas{
    key = 'Jesters',
    path = 'Jesters.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Blinds',
    path = 'Blinds.png',
    frames = 21,
    atlas_table = 'ANIMATION_ATLAS',
    px = 34,
    py = 34
}

JESTERPROJECT = SMODS.current_mod
JESTERPROJECT.no_marquee = true
JESTERPROJECT.optional_features = function()
    return {
        retrigger_joker = true,
        post_trigger = true
    }
end

local configoptions = {}

configoptions[#configoptions + 1] = create_toggle({
    label = "Disable Vanilla Jokers and Boss Blinds (Requires Restart)",
    ref_table = JESTERPROJECT.config,
    ref_value = "novanilla",
    callback = function()
    end,
})

JESTERPROJECT.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cl",
            minh = G.ROOM.T.h * 0.25,
            padding = 0.0,
            r = 0.1,
            colour = G.C.GREY,
        },
        nodes = configoptions,
    }
end

if JESTERPROJECT.config.novanilla then
    for _, v in ipairs({G.P_CENTER_POOLS.Joker, G.P_BLINDS}) do
        for _, vv in pairs(v) do
            if not vv.mod and (vv.set == 'Joker' or vv.boss) then
                (vv.set == 'Joker' and SMODS.Joker or SMODS.Blind):take_ownership(vv.key, {
                    in_pool = function() return false end,
                    no_collection = true
                }, true)
            end 
        end
    end
end

to_big = to_big or function(x) return x end

function JESTERPROJECT.event(func, trigger, delay, blocking, blockable)
    G.E_MANAGER:add_event(Event({
        trigger = trigger,
        delay = delay,
        blocking = blocking,
        blockable = blockable,
        func = func,
    }))
end

function table.contains(table, element)
    if table and type(table) == "table" then
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
        return false
    end
end

SMODS.Joker{
    key = 'jester',
    atlas = 'Jesters',
    pos = {x = 0, y = 0},
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Jester',
        text = {
            '{X:mult,C:white}X#1#{} Mult',
        }
    },
    config = {extra = {xmult = 40}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

for i, v in ipairs({{name = 'Rapacious', suit = 'Diamonds'}, {name = 'Sensual', suit = 'Hearts'}, {name = 'Vicious', suit = 'Spades'}, {name = 'Ravenous', suit = 'Clubs'}}) do
    SMODS.Joker{
        key = v.name:lower()..'jester',
        atlas = 'Jesters',
        pos = {x = 5+i, y = 1},
        rarity = 1,
        eternal_compat = true,
        perishable_compat = true,
        blueprint_compat = true,
        loc_txt = {
            name = v.name..' Jester',
            text = {
                'Played cards with {C:'..v.suit:lower()..'}'..v.suit:sub(1, -2)..'{} suit give',
                '{X:mult,C:white}X#1#{} Mult for every card with {C:'..v.suit:lower()..'}'..v.suit:sub(1, -2)..'{} suit',
                'in your full deck when scored',
                '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)',

            }
        },
        config = {extra = {xmult_gain = 0.1}},
        loc_vars = function (self, info_queue, card)
            local count = 0
            if G.playing_cards then
                for _, vv in ipairs(G.playing_cards) do
                    if vv:is_suit(v.suit) then count = count + card.ability.extra.xmult_gain end
                end
            end
            return {vars = {card.ability.extra.xmult_gain, count+1}}
        end,
        calculate = function (self, card, context)
            if context.individual and context.cardarea == G.play and context.other_card:is_suit(v.suit) then
                local count = 0
                if G.playing_cards then
                    for _, vv in ipairs(G.playing_cards) do
                        if vv:is_suit(v.suit) then count = count + card.ability.extra.xmult_gain end
                    end
                end
                return {xmult = count+1}
            end
        end
    }
end

for i, v in ipairs({{name = 'Manic', hand = 'Pair', xmult = 4}, {name = 'Ludicrous', hand = 'Three of a Kind', xmult = 6}, {name = 'Furious', hand = 'Two Pair', xmult = 5}, {name = 'Psychotic', hand = 'Straight', xmult = 6}, {name = 'Wry', hand = 'Flush', xmult = 5}}) do
    SMODS.Joker{
        key = v.name:lower()..'jester',
        atlas = 'Jesters',
        pos = {x = 1+i, y = 0},
        rarity = 1,
        eternal_compat = true,
        perishable_compat = true,
        blueprint_compat = true,
        loc_txt = {
            name = v.name..' Jester',
            text = {
                '{X:mult,C:white}X#1#{} Mult if played',
                'hand contains',
                'a {C:attention}'..v.hand..'{}',
            }
        },
        config = {extra = {xmult = v.xmult}},
        loc_vars = function (self, info_queue, card)
            return {vars = {card.ability.extra.xmult}}
        end,
        calculate = function (self, card, context)
            if context.joker_main and next(context.poker_hands[v.hand]) then
                return {xmult = card.ability.extra.xmult}
            end
        end
    }
end

for i, v in ipairs({{name = 'Cunning', hand = 'Pair', chips = 200}, {name = 'Shrewd', hand = 'Three of a Kind', chips = 400}, {name = 'Ingenious', hand = 'Two Pair', chips = 300}, {name = 'Diabolical', hand = 'Straight', chips = 666}, {name = 'Conniving', hand = 'Flush', chips = 300}}) do
    SMODS.Joker{
        key = v.name:lower()..'jester',
        atlas = 'Jesters',
        pos = {x = i-1, y = 14},
        rarity = 1,
        eternal_compat = true,
        perishable_compat = true,
        blueprint_compat = true,
        loc_txt = {
            name = v.name..' Jester',
            text = {
                '{C:chips}+#1#{} Chips if played',
                'hand contains',
                'a {C:attention}'..v.hand..'{}',
            }
        },
        config = {extra = {chips = v.chips}},
        loc_vars = function (self, info_queue, card)
            return {vars = {card.ability.extra.chips}}
        end,
        calculate = function (self, card, context)
            if context.joker_main and next(context.poker_hands[v.hand]) then
                return {xmult = card.ability.extra.xmult}
            end
        end
    }
end

SMODS.Joker{
    key = 'markedjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_half.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Marked Jester',
        text = {
            '{X:mult,C:white}X#1#{} Mult if played',
            'hand contains',
            '{C:attention}#2#{} or fewer cards',
        }
    },
    config = {extra = {xmult = 10, size = 3}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.size}}
    end,
    calculate = function (self, card, context)
        if context.joker_main and #context.full_hand <= card.ability.extra.size then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'jestercutout',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_stencil.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Jester Cutout',
        text = {
            '{X:mult,C:white}X#1#{} Mult for each',
            'filled {C:attention}Joker{} slot',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive})',
        }
    },
    config = {extra = {xmult = 3}},
    loc_vars = function (self, info_queue, card)
        local count = G.jokers and #G.jokers.cards or 1
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult*count}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            return {xmult = card.ability.extra.xmult*#G.jokers.cards}
        end
    end
}

local oldsmodsfourfingers = SMODS.four_fingers
function SMODS.four_fingers(hand_type)
    if SMODS.find_card('j_tjp_onefinger')[1] then
        return math.min(oldsmodsfourfingers(hand_type), 1)
    end
    return oldsmodsfourfingers(hand_type)
end

SMODS.Joker{
    key = 'onefinger',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_four_fingers.pos,
    rarity = 3,
    loc_txt = {
        name = 'One Finger',
        text = {
            'All {C:attention}Flushes{} and',
            '{C:attention}Straights{} can be',
            'made with {C:attention}1{} card',
        }
    },
}

SMODS.Joker{
    key = 'charade',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_mime.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Charade',
        text = {
            'Retrigger all',
            'card {C:attention}held in',
            '{C:attention}hand{} abilities {C:attention}#1#{} times',
        }
    },
    config = {extra = {retriggers = 4}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.retriggers}}
    end,
    calculate = function (self, card, context)
        if context.repetition and context.cardarea == G.hand and (next(context.card_effects[1]) or #context.card_effects > 1) then
            return {
                repetitions = card.ability.extra.retriggers
            }
        end
    end
}

SMODS.Joker{
    key = 'blackcard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_credit_card.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Black Card',
        text = {
            {
                'Go up to',
                '{C:red}-$#1#{} in debt',
            },
            {
                'If money is less than {C:attention}0{}',
                'at the end of the shop,',
                'set money to {C:money}$0'
            }
        }
    },
    config = {extra = {bankrupt_at = 80}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.bankrupt_at}}
    end,
    calculate = function (self, card, context)
        if context.ending_shop and to_big(G.GAME.dollars) < to_big(0) then
            return {func = function()
                JESTERPROJECT.event(function()
                    ease_dollars(-G.GAME.dollars, true)
                    card:juice_up()
                    return true
                end)
            end, no_retrigger = true}
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.bankrupt_at
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.bankrupt_at
    end
}

SMODS.Joker{
    key = 'dulldagger',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ceremonial.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Dull Dagger',
        text = {
            'When {C:attention}Blind{} is selected,',
            'permanently add {C:attention}one fifth{}',
            'of the Joker to the rights',
            'sell value to this {X:mult,C:white}XMult{}',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult = 1}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            local my_pos
            for i=1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                    break
                end
            end
            if my_pos and G.jokers.cards[my_pos + 1] then
                local sliced_card = G.jokers.cards[my_pos + 1]
                JESTERPROJECT.event(function()
                    local scalar = {value = sliced_card.sell_cost/5}
                    SMODS.scale_card(card, {
                        ref_table = card.ability.extra,
                        ref_value = 'xmult',
                        scalar_table = scalar,
                        scalar_value = 'value',
                        no_message = true
                    })
                    card:juice_up(0.8, 0.8)
                    return true
                end)
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult + (sliced_card.sell_cost/5) } },
                    colour = G.C.RED,
                    no_juice = true
                }
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

local oldgfuncsdiscardcardsfromhighlighted = G.FUNCS.discard_cards_from_highlighted
G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    if G.GAME and not hook then
        G.GAME.tjp_discard_usage_total = (G.GAME.tjp_discard_usage_total or 0) + 1
    end
    return oldgfuncsdiscardcardsfromhighlighted(e, hook)
end

SMODS.Joker{
    key = 'flag',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_banner.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Flag',
        text = {
            '{C:chips}+#1#{} Chips per {C:attention}discard{}',
            'used this run',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive})',
        }
    },
    config = {extra = {chip_gain = 50}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.chip_gain*(G.GAME.tjp_discard_usage_total or 0)}}
    end,
    calculate = function (self, card, context)
        if context.pre_discard and not context.hook and not context.blueprint then
            return {message = localize({type = 'variable', key = 'a_chips', vars = {card.ability.extra.chip_gain*G.GAME.tjp_discard_usage_total}}), colour = G.C.CHIPS}
        end
        if context.joker_main then
            return {chips = card.ability.extra.chip_gain*(G.GAME.tjp_discard_usage_total or 0)}
        end
    end
}

SMODS.Joker{
    key = 'mysticpeak',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_mystic_summit.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Mystic Peak',
        text = {
            '{X:mult,C:white}X#1#{} Mult when',
            '{C:attention}#2#{} discards',
            'remaining',
        }
    },
    config = {extra = {d_remaining = 0, xmult = 8}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.d_remaining}}
    end,
    calculate = function (self, card, context)
        if context.joker_main and G.GAME.current_round.discards_left == card.ability.extra.d_remaining then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'onyxjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_marble.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Onyx Jester',
        text = {
            'Adds three {C:attention}Stone{} cards',
            'to hand when',
            'a hand is played',
        }
    },
    config = {extra = {d_remaining = 0, xmult = 8}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.d_remaining}}
    end,
    calculate = function (self, card, context)
        if context.before then
            local effects = {}
            for _=1, 3 do
                table.insert(effects, {
                    func = function()
                        local stone_card = SMODS.add_card({set = "Base", enhancement = "m_stone", area = G.hand})
                        stone_card.states.visible = false
                        JESTERPROJECT.event(function()
                            SMODS.calculate_effect({message = localize('k_plus_stone'), colour = G.C.SECONDARY_SET.Enhanced, instant = true}, card)
                            stone_card:start_materialize()
                            return true
                        end)
                        delay(0.9375)
                        SMODS.calculate_context({ playing_card_added = true, cards = {stone_card} })
                    end
                })
            end
            return SMODS.merge_effects(effects)
        end
    end
}

SMODS.Joker{
    key = 'vippass',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_loyalty_card.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'VIP Pass',
        text = {
            'Every {C:attention}sixth{} card drawn',
            'permanently gains {X:mult,C:white}X#1#{} Mult',
        }
    },
    config = {extra = {xmult = 4, count = 0}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.hand_drawn and not context.blueprint then
            local effects = {}
            for i=1, #context.hand_drawn do
                card.ability.extra.count = card.ability.extra.count + 1
                if card.ability.extra.count % 6 == 0 then
                    local _card = context.hand_drawn[i]
                    _card.ability.perma_x_mult = (_card.ability.perma_x_mult or 0) + card.ability.extra.xmult
                    table.insert(effects, {message = localize('k_upgrade_ex'), colour = G.C.MULT, message_card = _card, juice_card = card})
                end
            end
            return SMODS.merge_effects(effects)
        end
    end
}

SMODS.Joker{
    key = '9ball',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_8_ball.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = '9 Ball',
        text = {
            'Each played {C:attention}9{} will create a',
            '{C:dark_edition}Negative{} {C:spectral}Spectral{} card when scored',
        }
    },
    config = {extra = {xmult = 4, count = 0}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 9 then
            return {func = function()
                JESTERPROJECT.event(function()
                    SMODS.add_card({set = 'Spectral', edition = 'e_negative'})
                    SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Enhanced, instant = true}, card)
                    return true
                end)
                delay(0.9375)
            end}
        end
    end
}

SMODS.Joker{
    key = 'defect',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_misprint.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Defect',
        text = {
            '{X:mult,C:white}X#1#-#2#{} Mult',
            'cap raises by #3# when a Joker is {C:attention}sold{}'
        }
    },
    config = {extra = {min = 1, max = 15, increase = 1}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.min, card.ability.extra.max, card.ability.extra.increase}}
    end,
    calculate = function (self, card, context)
        if context.selling_card and context.card.ability.set == 'Joker' then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'max',
                scalar_value = 'increase',
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = pseudorandom(self.key, card.ability.extra.min, card.ability.extra.max)}
        end
    end
}

SMODS.Joker{
    key = 'night',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_dusk.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Night',
        text = {
            "Retrigger all played",
            "cards twice after {C:attention}first",
            "{C:attention}hand{} of round",
        }
    },
    calculate = function (self, card, context)
        if context.repetition and context.cardarea == G.play and G.GAME.current_round.hands_played > 0 then
            return {repetitions = 2}
        end
    end
}

SMODS.Joker{
    key = 'sellout',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_raised_fist.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Sellout',
        text = {
            'Gives the rank',
            'of {C:attention}highest{} ranked card',
            'held in hand as {X:mult,C:white}XMult{}',
        }
    },
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            local temp_Mult, temp_ID = 0, 0
            local raised_card
            for i = 1, #G.hand.cards do
                if temp_ID <= G.hand.cards[i].base.id and not SMODS.has_no_rank(G.hand.cards[i]) then
                    temp_Mult = G.hand.cards[i].base.nominal
                    temp_ID = G.hand.cards[i].base.id
                    raised_card = G.hand.cards[i]
                end
            end
            if raised_card == context.other_card then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED
                    }
                else
                    return {
                        xmult = temp_Mult
                    }
                end
            end
        end
    end
}

local oldcalculatererollcost = calculate_reroll_cost
function calculate_reroll_cost(skip_increment)
    if SMODS.find_card('j_tjp_cataclysmthecarny')[1] and not skip_increment then
        G.GAME.current_round.reroll_cost_increase = (G.GAME.current_round.reroll_cost_increase or 0) - (1-(1/(5^#SMODS.find_card('j_tjp_cataclysmthecarny'))))
    end
    return oldcalculatererollcost(skip_increment)
end

SMODS.Joker{
    key = 'cataclysmthecarny',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_chaos.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Cataclysm The Carny',
        text = {
            'Price of {C:green}rerolls{}',
            'scales {C:attention}five times{}',
            'as slow'
        }
    },
}

SMODS.Joker{
    key = 'goldenratio',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_fibonacci.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Golden Ratio',
        text = {
            'Each {C:attention}Ace{}, {C:attention}3{}, {C:attention}4{},',
            '{C:attention}6{}, {C:attention}7{}, {C:attention}8{}, or {C:attention}9{} gives',
            '{X:mult,C:white}X#1#{} Mult when held in hand',
        }
    },
    config = {extra = {xmult = 4}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card:get_id() == 3 or
                context.other_card:get_id() == 4 or
                context.other_card:get_id() == 6 or
                context.other_card:get_id() == 7 or
                context.other_card:get_id() == 8 or
                context.other_card:get_id() == 9 or
                context.other_card:get_id() == 14 then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'titaniumjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_steel_joker.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Titanium Jester',
        text = {
            'Gives {X:mult,C:white}X#1#{} Mult',
            'for each {C:attention}Steel Card',
            'remaining in {C:attention}deck',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        }
    },
    config = {extra = {xmult = 0.8}},
    loc_vars = function (self, info_queue, card)
        local count = 0
        if G.deck then
            for i, v in ipairs(G.deck.cards) do
                if SMODS.has_enhancement(v, 'm_steel') then
                    count = count + 1
                end
            end
        end
        return {vars = {card.ability.extra.xmult, (card.ability.extra.xmult*count)+1}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local count = 0
            if G.deck then
                for i, v in ipairs(G.deck.cards) do
                    if SMODS.has_enhancement(v, 'm_steel') then
                        count = count + 1
                    end
                end
            end
            return {xmult = (card.ability.extra.xmult*count)+1}
        end
    end
}

SMODS.Joker{
    key = 'horrifyingface',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_scary_face.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Horrifying Face',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:chips}+#1#{} Chips',
            'for each {C:attention}face card',
            'in your {C:attention}full deck',
            'when scored',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        }
    },
    config = {extra = {chips = 10}},
    loc_vars = function (self, info_queue, card)
        local count = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v:is_face() then
                    count = count + 1
                end
            end
        end
        return {vars = {card.ability.extra.chips, card.ability.extra.chips*count}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local count = 0
            if G.playing_cards then
                for _, v in ipairs(G.playing_cards) do
                    if v:is_face() then
                        count = count + 1
                    end
                end
            end
            return {chips = card.ability.extra.chips*count}
        end
    end
}

SMODS.Joker{
    key = 'meaninglessjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_abstract.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Meaningless Jester',
        text = {
            '{X:mult,C:white}X#1#{} Mult for',
            'each {C:attention}Jester{} card',
            'in the game',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult = 0.1}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult*150}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            return {xmult = card.ability.extra.xmult*150}
        end
    end
}

SMODS.Joker{
    key = 'copingstrategy',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_delayed_grat.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Coping Strategy',
        text = {
            'Earn {C:money}$#1#{} per {C:attention}discard{} used if',
            'less than {C:attention}#2#{} cards were discarded',
            'by end of the round',
        }
    },
    config = {extra = {money = 7, cards = 10, count = 0}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.money, card.ability.extra.cards}}
    end,
    calculate = function (self, card, context)
        if context.discard then
            card.ability.extra.count = card.ability.extra.count + 1
        end
        if context.starting_shop then
            card.ability.extra.count = 0
        end
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.count < card.ability.extra.cards and G.GAME.current_round.discards_used > 0 and (card.ability.extra.money*G.GAME.current_round.discards_used) or nil
    end
}

local function reset_tjp_improv_ranks()
    G.GAME.current_round.tjp_improv_ranks = {}
    local valid_ranks = {}
    for _, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_rank(v) and not table.contains(valid_ranks, v.base.value) then
            table.insert(valid_ranks, v.base.value)
        end
    end
    if #valid_ranks < 5 then
        for i=1, #valid_ranks do
            table.insert(G.GAME.current_round.tjp_improv_ranks, valid_ranks[i])
        end
        for i=1, 5-#valid_ranks do
            local rank = pseudorandom_element(SMODS.Ranks, 'tjp_improv'..G.GAME.round_resets.ante..i).key
            table.insert(G.GAME.current_round.tjp_improv_ranks, rank)
        end
        return nil
    end
    for i=1, 5 do
        local rank, index = pseudorandom_element(valid_ranks, pseudoseed('tjp_improv'..G.GAME.round_resets.ante..i))
        table.remove(valid_ranks, index)
        G.GAME.current_round.tjp_improv_ranks[i] = rank
    end
end

SMODS.Joker{
    key = 'improv',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hack.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Improv',
        text = {
            'Retrigger',
            'each played',
            '{C:attention}#1#{}, {C:attention}#2#{}, {C:attention}#3#{}, {C:attention}#4#{} or {C:attention}#5#{}',
            '{C:attention}four{} additional times',
            'ranks change every round'
        }
    },
    loc_vars = function (self, info_queue, card)
        local vars = {}
        for i, v in ipairs(G.GAME.current_round.tjp_improv_ranks) do
            if i>5 then break end
            table.insert(vars, localize(v, 'ranks'))
        end
        return {vars = vars}
    end,
    calculate = function (self, card, context)
        if context.repetition and context.cardarea == G.play then
            for i, v in ipairs(G.GAME.current_round.tjp_improv_ranks) do
                if i>5 then break end
                if context.other_card:get_id() == ((SMODS.Ranks or {})[v] or {}).id then
                    return {repetitions = 4}
                end
            end
        end
    end
}

local oldcardgetid = Card.get_id
function Card:get_id()
    if SMODS.find_card('j_tjp_delusion')[1] then
        return 13
    end
    return oldcardgetid(self)
end

local oldcardisface = Card.is_face
function Card:is_face(from_boss)
    if self.debuff and not from_boss then return end
    if SMODS.find_card('j_tjp_delusion')[1] then
        return true
    end
    return oldcardisface(self, from_boss)
end

local oldcardgetseal = Card.get_seal
function Card:get_seal(bypass_debuff)
    return oldcardgetseal(self, bypass_debuff) or (SMODS.find_card('j_tjp_delusion')[1] and self.playing_card and 'Red')
end

assert(SMODS.load_file('quantum.lua'))()

SMODS.Joker{
    key = 'delusion',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_pareidolia.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Delusion',
        text = {
            'All cards are',
            'considered',
            '{C:red}Red Seal{} Steel {C:dark_edition}Polychrome{} {C:attention}Kings{}',
        }
    },
}

SMODS.Joker{
    key = 'grossestmichel',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_gros_michel.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Grossest Michel',
        text = {
            {
                '{X:mult,C:white}X#1#{} Mult',
                '{C:green}#2# in #3#{} chance to double',
                'at end of round',
            },
            {
                '{C:green}#4# in #5#{} chance this',
                'card is destroyed',
                'at end of round',
            }
        }
    },
    config = {extra = {xmult = 8, odds1 = 3, odds2 = 6}},
    loc_vars = function (self, info_queue, card)
        local numerator1, denominator1 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds1, self.key)
        local numerator2, denominator2 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds2, self.key)
        return {vars = {card.ability.extra.xmult, numerator1, denominator1, numerator2, denominator2}}
    end,
    calculate = function (self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            local effects = {}
            if SMODS.pseudorandom_probability(card, self.key, 1, card.ability.extra.odds1) then
                local scalar = {value = 2}
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'xmult',
                    scalar_table = scalar,
                    scalar_value = 'value',
                    operation = 'X',
                    no_message = true
                })
                table.insert(effects, {message = localize('k_upgrade_ex'), colour = G.C.MULT})
            end
            if SMODS.pseudorandom_probability(card, self.key, 1, card.ability.extra.odds2) then
                table.insert(effects, {message = localize('k_extinct_ex'), func = function()
                    SMODS.destroy_cards(card, nil, nil, true)
                end})
            else
                table.insert(effects, {message = localize('k_safe_ex')})
            end
            if effects[1] then
                return SMODS.merge_effects(effects)
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'symmetricalsteve',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_even_steven.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Symmetrical Steve',
        text = {
            'Played cards with',
            '{C:attention}even{} rank give',
            '{X:mult,C:white}X#1#{} Mult when scored',
            '{C:inactive}(10, 8, 6, 4, 2){}',
        }
    },
    config = {extra = {xmult = 2}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id()%2 == 0 then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'godtodd',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_odd_todd.pos,
    soul_pos = {x = 1, y = 9},
    rarity = 4,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'God Todd',
        text = {
            'Played cards with',
            '{C:attention}odd{} rank give',
            '{C:chips}+#1#{} Chips when scored',
            '{C:inactive}(A, 9, 7, 5, 3){}',
        }
    },
    config = {extra = {chips = 3100001}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.chips}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and ((context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id()%2 == 1) or context.other_card:get_id() == 14) then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'intellectual',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_scholar.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Intellectual',
        text = {
            'Gains {X:mult,C:white}X#1#{} Mult',
            'if played hand contains an {C:attention}Ace{}',
            'otherwise, loses {X:mult,C:white}X#2#{} Mult',
            '{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 1, xmult_loss = 2}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult_loss, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            local passed = false
            for _, v in ipairs(context.full_hand) do
                if v:get_id() == 14 then
                    passed = true
                    break
                end
            end
            if passed then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'xmult',
                    scalar_value = 'xmult_gain',
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
            elseif card.ability.extra.xmult > 1 then
                local scalar = {value = (-card.ability.extra.xmult)+math.max(card.ability.extra.xmult-card.ability.extra.xmult_loss, 1)}
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'xmult',
                    scalar_table = scalar,
                    scalar_value = 'value',
                    no_message = true
                })
                return {message = 'Degrade!', colour = G.C.MULT}
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'signature',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_business.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Signature',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:money}$#1#{} when scored',
            'increases by {C:money}$#2#{} for every',
            '{C:attention}#3#{} {C:inactive}[#4#]{} face cards played',
        }
    },
    config = {extra = {dollars = 1, dollar_gain = 1, faces = 5, count = 0}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollar_gain, card.ability.extra.faces, card.ability.extra.faces-card.ability.extra.count}}
    end,
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            local passed = false
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then
                    card.ability.extra.count = card.ability.extra.count + 1
                    if card.ability.extra.count >= card.ability.extra.faces then
                        passed = true
                        card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_gain
                        card.ability.extra.count = 0
                    end
                end
            end
            if passed then
                return {message = localize('k_upgrade_ex'), colour = G.C.MONEY}
            end
        end
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return {dollars = card.ability.extra.dollars}
        end
    end
}

local oldgfuncsplaycardsfromhighlighted = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    if G.GAME then
        G.GAME.tjp_play_usage_total = (G.GAME.tjp_play_usage_total or 0) + 1
    end
    return oldgfuncsplaycardsfromhighlighted(e)
end

SMODS.Joker{
    key = 'quasar',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_supernova.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Quasar',
        text = {
            '{X:mult,C:white}X#1#{} Mult per {C:attention}hand{}',
            'played this run',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive})',
        }
    },
    config = {extra = {xmult_gain = 0.25}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, (card.ability.extra.xmult_gain*(G.GAME.tjp_play_usage_total or 0))+1}}
    end,
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            return {message = localize({type = 'variable', key = 'a_xmult', vars = {(card.ability.extra.xmult_gain*G.GAME.tjp_play_usage_total)+1}}), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = (card.ability.extra.xmult_gain*(G.GAME.tjp_play_usage_total or 0))+1}
        end
    end
}

SMODS.Joker{
    key = 'delay',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ride_the_bus.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Delay',
        text = {
            'This Jester gains {X:mult,C:white}X#1#{} Mult',
            'per {C:attention}consecutive{} hand',
            'played with less than',
            '3 {C:attention}non-face{} cards',
            'held in hand',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult_gain = 1, xmult = 1}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local count = 0
            for _, v in ipairs(G.hand.cards) do
                if not v:is_face() then
                    count = count + 1
                end
            end
            if count >= 3 then
                local last_mult = card.ability.extra.xmult
                card.ability.extra.xmult = 1
                if last_mult > 1 then
                    return {
                        message = localize('k_reset')
                    }
                end
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_value = "xmult_gain",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'voidjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_space.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Void Jester',
        text = {
            "Upgrades level of",
            "played {C:attention}poker hand{} three times",
            'if last played poker hand was the same poker hand'
        }
    },
    config = {extra = {}},
    calculate = function(self, card, context)
        if context.before then
            if card.ability.extra.last_poker_hand == context.scoring_name then
                return {level_up = 3, message = localize('k_level_up_ex')}
            end
            card.ability.extra.last_poker_hand = context.scoring_name
        end
    end
}

SMODS.Joker{
    key = 'eggcarton',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_egg.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Egg Carton',
        text = {
            "Gains half of current",
            "{C:attention}sell value{} at",
            "end of round",
        }
    },
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            SMODS.scale_card(card, {
                ref_table = card.ability,
                ref_value = "extra_value",
                scalar_table = card,
                scalar_value = "sell_cost",
                no_message = true
            })
            card:set_cost()
            return {message = localize('k_val_up'), colour = G.C.MULT}
        end
    end
}

SMODS.Joker{
    key = 'lifeserver',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_burglar.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Life Server',
        text = {
            "When {C:attention}Blind{} is selected,",
            "permanently gain {C:blue}+#1#{} Hand#2# and",
            "{C:attention}lose all discards",
            'resets when sold or destroyed'
        }
    },
    config = {extra = {hands = 1}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.hands, card.ability.extra.hands == 1 and '' or 's'}}
    end,
    add_to_deck = function (self, card, from_debuff)
        G.GAME.tjp_oldhands = G.GAME.round_resets.hands
    end,
    remove_from_deck = function (self, card, from_debuff)
        ease_hands_played(G.GAME.tjp_oldhands - G.GAME.round_resets.hands)
        G.GAME.round_resets.hands = G.GAME.tjp_oldhands
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            return {func = function()
                G.E_MANAGER:add_event(Event({
                    func = function()
                        ease_discard(-G.GAME.current_round.discards_left, nil, true)
                        ease_hands_played(card.ability.extra.hands)
                        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
                        SMODS.calculate_effect(
                            { message = localize { type = 'variable', key = 'a_hands', vars = { card.ability.extra.hands } } },
                            context.blueprint_card or card)
                        return true
                    end
                }))
            end}
        end
    end
}

SMODS.Joker{
    key = 'whiteboard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_blackboard.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Whiteboard',
        text = {
            "{X:red,C:white}X#1#{} Mult if",
            "at least one card of",
            "each suit is held in hand",
        }
    },
    config = {extra = {xmult = 10}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local passed_suits = {}
            for _, v in ipairs(SMODS.Suit.obj_buffer) do
                passed_suits[v] = true
            end
            for _, v in ipairs(G.hand.cards) do
                passed_suits[v.base.suit] = nil
            end
            if not next(passed_suits) then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'hitthewall',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_runner.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Hit the Wall',
        text = {
            'Gains {C:chips}+#1#{} Chips',
            'for every straight held in hand',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        }
    },
    config = {extra = {chip_gain = 50, chips = 0}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.chips}}
    end,
    calculate = function(self, card, context)
        if context.before then
            local straights = get_straight(G.hand.cards, SMODS.four_fingers('straight'), SMODS.shortcut(), SMODS.wrap_around_straight())
            local scalar = {value = #straights*card.ability.extra.chip_gain}
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "chips",
                scalar_table = scalar,
                scalar_value = "value",
                no_message = true
            })
            return {message = localize({type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}), colour = G.C.CHIPS}
        end
        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'gelato',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ice_cream.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Gelato',
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:chips}-#2#{} Chips for",
            "every card played",
        }
    },
    config = {extra = {chips = 400, chip_loss = 5}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.chips, card.ability.extra.chip_loss}}
    end,
    calculate = function(self, card, context)
        if context.before then
            if card.ability.extra.chips - card.ability.extra.chip_loss*#context.full_hand <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_melted_ex'),
                    colour = G.C.CHIPS
                }
            else
                local scalar = {value = card.ability.extra.chip_loss*#context.full_hand}
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "chips",
                    scalar_table = scalar,
                    scalar_value = "value",
                    operation = "-",
                    no_message = true
                })
                return {message = localize({type = 'variable', key = 'a_chips_minus', vars = {card.ability.extra.chip_loss*#context.full_hand}}), colour = G.C.CHIPS}
            end
        end
        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'chromosome',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_dna.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Chromosome',
        text = {
            "Create a permanent {C:attention}copy{} of",
            "the {C:attention}first{} card played",
            "and immediately {C:attention}score{} it",
        }
    },
    calculate = function(self, card, context)
        if context.initial_scoring_step then
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            local _card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
            _card:add_to_deck()
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, _card)
            G.hand:emplace(_card)
            _card.states.visible = nil
            G.E_MANAGER:add_event(Event({
                func = function()
                    _card:start_materialize()
                    return true
                end
            }))
            return {
                message = localize('k_copied_ex'),
                playing_cards_created = {_card},
                func = function()
                    SMODS.score_card(_card, {cardarea = G.play})
                end
            }
        end
    end
}

local oldsmodsscorecard = SMODS.score_card
function SMODS.score_card(card, context)
    if not G.tjp_teardrop and SMODS.find_card('j_tjp_teardrop')[1] and context.cardarea == G.hand then
        G.tjp_teardrop = true
        context.cardarea = G.play
        SMODS.score_card(card, context)
        context.cardarea = G.hand
        G.tjp_teardrop = nil
    end
    return oldsmodsscorecard(card, context)
end

SMODS.Joker{
    key = 'teardrop',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_splash.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Teardrop',
        text = {
            'All cards',
            'held in hand',
            'are {C:attention}scored{}',
        }
    },
}

SMODS.Joker{
    key = 'indigojester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_blue_joker.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Indigo Jester',
        text = {
            'Gains {C:chips}+#1#{} Chips',
            'for every card in {C:attention}deck{}',
            'at end of round',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        }
    },
    config = {extra = {chips = 0, chip_gain = 2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.chips}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            local scalar = {value = card.ability.extra.chip_gain*#G.deck.cards}
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "chips",
                scalar_table = scalar,
                scalar_value = "value",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.CHIPS}
        end
        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'seventhsense',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_sixth_sense.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Seventh Sense',
        text = {
            'Create a {C:dark_edition}Negative{} {C:spectral}Spectral{} card',
            'if a {C:attention}7{} is held in hand',
            'at the end of the round',
        }
    },
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            for _, v in ipairs(G.hand.cards) do
                if v:get_id() == 7 then
                    return {
                        func = function ()
                            JESTERPROJECT.event(function()
                                SMODS.add_card({set = 'Spectral', edition = 'e_negative'})
                                SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral, instant = true}, card)
                                return true
                            end)
                            delay(0.9375)
                        end
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = 'zodiacjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_constellation.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Zodiac Jester',
        text = {
            "This Jester gains",
            "{X:mult,C:white} X#1# {} Mult every time",
            "a {C:attention}consumable{} is used",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize({type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult}}), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'explorer',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hiker.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Explorer',
        text = {
            "Every {C:attention}card{} held in hand",
            "permanently gains",
            "{X:mult,C:white}X#1#{} Mult",
            'at end of round'
        }
    },
    config = {extra = {xmult_gain = 0.2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and context.end_of_round then
            context.other_card.ability.perma_x_mult = (context.other_card.ability.perma_x_mult or 0) + card.ability.extra.xmult_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker{
    key = 'featurelessjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_faceless.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Featureless Jester',
        text = {
            "Earn {C:money}$#1#{} for every",
            "{C:attention}face card{} discarded,",
            'gain increases by {C:money}$#2#{} if',
            'discard contains #3# or more {C:attention}face cards{}'
        }
    },
    config = {extra = {dollars = 1, dollar_gain = 1, faces = 3}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollar_gain, card.ability.extra.faces}}
    end,
    calculate = function(self, card, context)
        if context.pre_discard and not context.blueprint then
            local face_cards = 0
            for _, v in ipairs(context.full_hand) do
                if v:is_face() then face_cards = face_cards + 1 end
            end
            if face_cards >= card.ability.extra.faces then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "dollars",
                    scalar_value = "dollar_gain",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MONEY}
            end
        end
        if context.discard and context.other_card:is_face() then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}

SMODS.Joker{
    key = 'emeraldjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_green_joker.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Emerald Jester',
        text = {
            {
                "This Jester gains {X:mult,C:white}X#1#{} Mult",
                "per {C:attention}consecutive{} hand",
                "played without discarding",
                "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
            },
            {
                'Resets to Mult',
                '{C:attention}three{} rounds ago',
                'when discarding',
            }
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.5, immutable = {rounds_ago = {1, 1, 1}}}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.pre_discard and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.immutable.rounds_ago[3]
            return {message = localize('k_reset')}
        end
        if context.end_of_round and context.main_eval and not context.blueprint then
            table.insert(card.ability.extra.immutable.rounds_ago, 1, card.ability.extra.xmult)
            table.remove(card.ability.extra.immutable.rounds_ago, 4)
        end
        if context.before and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'coexistence',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_superposition.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Coexistence',
        text = {
            "Create a {C:dark_edition}Negative{} {C:spectral}Spectral{} card if",
            "two or fewer {C:attention}Aces{}",
            "are remaining in deck",
            "at end of round",
        }
    },
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            local count = 0
            for _, v in ipairs(G.deck.cards) do
                if v:get_id() == 14 then
                    count = count + 1
                end
            end
            if count <= 2 then
                return {
                    func = function ()
                        JESTERPROJECT.event(function()
                            SMODS.add_card({set = 'Spectral', edition = 'e_negative'})
                            SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral, instant = true}, card)
                            return true
                        end)
                        delay(0.9375)
                    end
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'masterplan',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_todo_list.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Master Plan',
        text = {
            "Earn {C:money}$#1#{} if {C:attention}poker hand{}",
            "contains a {C:attention}#2#{},",
            "poker hand changes",
            "when it is played",
        }
    },
    config = {extra = {dollars = 15, poker_hand = 'High Card'}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, localize(card.ability.extra.poker_hand, 'poker_hands') } }
    end,
    calculate = function(self, card, context)
        if context.before and next(context.poker_hands[card.ability.extra.poker_hand]) then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            local _poker_hands = {}
            for handname, _ in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                    _poker_hands[#_poker_hands + 1] = handname
                end
            end
            card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, self.key)
            return {
                dollars = card.ability.extra.dollars,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end,
                extra = {
                    message = localize('k_reset')
                }
            }
        end
    end,
    set_ability = function(self, card, initial, delay_sprites)
        local _poker_hands = {}
        for handname, _ in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(handname) and handname ~= card.ability.extra.poker_hand then
                _poker_hands[#_poker_hands + 1] = handname
            end
        end
        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, self.key)
    end
}

SMODS.Joker{
    key = 'cavennestdish',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_cavendish.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Cavennest Dish',
        text = {
            {
                '{X:mult,C:white}X#1#{} Mult',
                '{C:green}#2# in #3#{} chance to',
                'multiply by {X:attention,C:white}X#6#{}',
                'at end of round',
            },
            {
                '{C:green}#4# in #5#{} chance this',
                'card is not destroyed',
                'at end of round',
            }
        }
    },
    config = {extra = {xmult = 400, odds1 = 10, odds2 = 1e7, multiply = 1.1}},
    loc_vars = function (self, info_queue, card)
        local numerator1, denominator1 = SMODS.get_probability_vars(card, 1, card.ability.extra.odds1, self.key)
        local numerator2, denominator2 = SMODS.get_probability_vars(card, 9999999, card.ability.extra.odds2, self.key)
        return {vars = {card.ability.extra.xmult, numerator1, denominator1, numerator2, denominator2, card.ability.extra.multiply}}
    end,
    calculate = function (self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            local effects = {}
            if SMODS.pseudorandom_probability(card, self.key, 1, card.ability.extra.odds1) then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'xmult',
                    scalar_value = 'multiply',
                    operation = 'X',
                    no_message = true
                })
                table.insert(effects, {message = localize('k_upgrade_ex'), colour = G.C.MULT})
            end
            if not SMODS.pseudorandom_probability(card, self.key, 9999999, card.ability.extra.odds2) then
                table.insert(effects, {message = localize('k_extinct_ex'), func = function()
                    SMODS.destroy_cards(card, nil, nil, true)
                end})
            else
                table.insert(effects, {message = localize('k_safe_ex')})
            end
            if effects[1] then
                return SMODS.merge_effects(effects)
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'cardcollector',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_card_sharp.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Card Collector',
        text = {
            '{X:mult,C:white}X#1#{} Mult for',
            'every time the {C:attention}highest{}',
            'poker hand held in hand has',
            'been played this run',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)'
        }
    },
    config = {extra = {xmult_gain = 1}},
    loc_vars = function (self, info_queue, card)
        local cards, poker_hand
        if G.hand and G.hand.cards[1] then
            if G.STATE == G.STATES.HAND_PLAYED then
                cards = G.hand.cards
            else
                cards = {}
                for _, v in ipairs(G.hand.cards) do
                    if not v.highlighted then
                        table.insert(cards, v)
                    end
                end
            end
            poker_hand = G.FUNCS.get_poker_hand_info(cards)
        end
        return {vars = {card.ability.extra.xmult_gain, (card.ability.extra.xmult_gain*(G.hand and G.hand.cards[1] and G.GAME.hands[poker_hand].played or 1))}}
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local poker_hand = G.FUNCS.get_poker_hand_info(G.hand.cards)
            return {xmult = card.ability.extra.xmult_gain*G.GAME.hands[poker_hand].played}
        end
    end
}

SMODS.Joker{
    key = 'scarletcard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_red_card.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Scarlet Card',
        text = {
            "This Jester gains",
            "{X:mult,C:white}X#1#{} Mult when any",
            "{C:attention}Booster Pack{} is opened",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.4}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.open_booster then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'frenzy',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_madness.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Frenzy',
        text = {
            "When {C:attention}Blind{}",
            "is selected, gain {X:mult,C:white}X#1#{} Mult",
            "and {C:attention}debuff{} a random Joker",
            'for one round',
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 2}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            local valid_jokers = {}
            for _, v in ipairs(G.jokers.cards) do
                if not v.ability.tjp_debuffed_by_frenzy then
                    table.insert(valid_jokers, v)
                end
            end
            local joker = pseudorandom_element(valid_jokers, self.key)
            joker.ability.tjp_debuffed_by_frenzy = true
            SMODS.recalc_debuff(joker)
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.end_of_round and context.main_eval and not context.blueprint then
            for _, v in ipairs(G.jokers.cards) do
                if v.ability.tjp_debuffed_by_frenzy then
                    v.ability.tjp_debuffed_by_frenzy = nil
                    SMODS.recalc_debuff(v)
                end
            end
        end
        if context.debuff_card and context.debuff_card.ability.tjp_debuffed_by_frenzy then
            return {debuff = true}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'boxedjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_square.pos,
    pixel_size = { h = 71 },
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Boxed Jester',
        text = {
            'This Jester gains {C:chips}+#1#{} Chips',
            'for every {C:attention}#2#{} {C:inactive}[#3#]{} cards scored',
            "{C:inactive}(Currently {C:chips}+#4#{C:inactive} Chips)",
        }
    },
    config = {extra = {chips = 0, chip_gain = 16, cards = 16, count = 0}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.cards, card.ability.extra.cards-card.ability.extra.count, card.ability.extra.chips}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count >= card.ability.extra.cards then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "chips",
                    scalar_value = "chip_gain",
                    no_message = true
                })
                card.ability.extra.count = 0
                return {message = localize('k_upgrade_ex'), colour = G.C.CHIPS}
            end
        end
        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'conjuring',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_seance.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Conjuring',
        text = {
            'If played hand contains',
            'a {C:attention}Straight{} or a {C:attention}Flush{},',
            'create {C:attention}#1#{} random {C:spectral}Spectral{} card#2#',
        }
    },
    config = {extra = {spectrals = 2}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.spectrals, card.ability.extra.spectrals == 1 and '' or 's'}}
    end,
    calculate = function (self, card, context)
        if context.before and (next(context.poker_hands['Straight']) or next(context.poker_hands['Flush'])) then
            return {func = function()
                for _=1, card.ability.extra.spectrals do
                    JESTERPROJECT.event(function()
                        SMODS.add_card({set = 'Spectral'})
                        SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral, instant = true}, card)
                        return true
                    end)
                    delay(0.9375)
                end
            end}
        end
    end
}

SMODS.Joker{
    key = 'comedyclub',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_riff_raff.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Comedy Club',
        text = {
            "When {C:attention}Blind{} is selected,",
            "create {C:dark_edition}Negative{} {C:attention}Jokers{}",
            "equal to a fourth of the amount of owned Jokers",
        }
    },
    calculate = function (self, card, context)
        if context.setting_blind then
            return {func = function()
                for _=1, math.floor(#G.jokers.cards/4) do
                    JESTERPROJECT.event(function()
                        SMODS.add_card({set = 'Joker', edition = 'e_negative'})
                        SMODS.calculate_effect({message = localize('k_plus_joker'), instant = true}, card)
                        return true
                    end)
                    delay(0.9375)
                end
            end}
        end
    end
}

SMODS.Joker{
    key = 'dracula',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_vampire.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Dracula',
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "per scoring {C:attention}Modified card{} played,",
            'then duplicate them to hand',
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.3}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            local cards = {}
            for _, v in ipairs(context.full_hand) do
                if JESTERPROJECT.get_seals(v)[1] or JESTERPROJECT.get_enhancements(v)[1] or (v.edition or JESTERPROJECT.get_quantum_editions(v)[1]) or (function() for _, vv in ipairs(SMODS.Sticker.obj_buffer) do if v.ability[vv] then return true end end end)() then
                    table.insert(cards, v)
                end
            end
            if #cards > 0 then
                local scalar = {value = card.ability.extra.xmult_gain*#cards}
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_table = scalar,
                    scalar_value = "value",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MULT, extra = {func = function()
                    for _, v in ipairs(cards) do
                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                        local _card = copy_card(v, nil, nil, G.playing_card)
                        _card:add_to_deck()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        table.insert(G.playing_cards, _card)
                        G.hand:emplace(_card)
                        _card.states.visible = nil
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                _card:start_materialize()
                                SMODS.calculate_effect({message = localize('k_copied_ex'), instant = true}, card)
                                return true
                            end
                        }))
                        delay(0.9375)
                    end
                end}}
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

local oldsmodsshortcut = SMODS.shortcut
function SMODS.shortcut()
    if SMODS.find_card('j_tjp_express')[1] then
        return 4
    end
    return oldsmodsshortcut()
end

SMODS.Joker{
    key = 'express',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_shortcut.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Express',
        text = {
            "Allows {C:attention}Straights{} to be",
            "made with gaps of {C:attention}4 ranks",
            "{C:inactive}(ex: {C:attention}A 9 4{C:inactive})",
        }
    }
}

SMODS.Joker{
    key = 'phantom',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hologram.pos,
    soul_pos = G.P_CENTERS.j_hologram.soul_pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Phantom',
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "every time the amount of cards",
            "in your full deck is {C:attention}changed{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.75}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if (context.playing_card_added or context.remove_playing_cards) and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'drifter',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_vagabond.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Drifter',
        text = {
            "Create a {C:spectral}Spectral{} card",
            "if hand is played",
            "with {C:money}$#1#{} or less",
        }
    },
    config = {extra = {dollars = 15}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,
    calculate = function (self, card, context)
        if context.before and to_big(G.GAME.dollars) <= to_big(card.ability.extra.dollars) then
            return {func = function()
                JESTERPROJECT.event(function()
                    SMODS.add_card({set = 'Spectral'})
                    SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral, instant = true}, card)
                    return true
                end)
                delay(0.9375)
            end}
        end
    end
}

SMODS.Joker{
    key = 'tyrant',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_baron.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Tyrant',
        text = {
            "Each {C:attention}King{}",
            "held in hand",
            "gives {X:mult,C:white}X#1#{} Mult for",
            'every scoring {C:attention}King{} in played hand',
        }
    },
    config = {extra = {xmult = 4}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == 13 then
            local count = 0
            for _, v in ipairs(context.scoring_hand) do
                if v:get_id() == 13 then
                    count = count + 1
                end
            end
            if count > 0 then
                return {xmult = card.ability.extra.xmult*count}
            end
        end
    end
}

SMODS.Joker{
    key = '10clouds',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_cloud_9.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = '10 Clouds',
        text = {
            "Earn {C:money}$#1#{} for each",
            "{C:attention}10{} in your {C:attention}full deck",
            "at end of round",
            "{C:inactive}(Currently {C:money}$#2#{}{C:inactive})",
        }
    },
    config = {extra = {dollars = 4}},
    loc_vars = function (self, info_queue, card)
        local ten_tally = 0
        if G.playing_cards then
            for _, v in ipairs(G.playing_cards) do
                if v:get_id() == 10 then ten_tally = ten_tally + 1 end
            end
        end
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollars*ten_tally}}
    end,
    calc_dollar_bonus = function (self, card)
        local ten_tally = 0
        for _, v in ipairs(G.playing_cards) do
            if v:get_id() == 10 then ten_tally = ten_tally + 1 end
        end
        return card.ability.extra.dollars*ten_tally
    end
}

SMODS.Joker{
    key = 'vessel',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_rocket.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Vessel',
        text = {
            "Earn {C:money}$#1#{} at end of round",
            "Payout increases by {C:money}$#2#{}",
            "when {C:attention}Boss Blind{} is defeated",
        }
    },
    config = {extra = {dollars = 4, dollar_gain = 8}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollar_gain}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and context.beat_boss then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "dollars",
                scalar_value = "dollar_gain",
                no_message = true
            })
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MONEY
            }
        end
    end,
    calc_dollar_bonus = function (self, card)
        local ten_tally = 0
        for _, v in ipairs(G.playing_cards) do
            if v:get_id() == 10 then ten_tally = ten_tally + 1 end
        end
        return card.ability.extra.dollars*ten_tally
    end
}

SMODS.Joker{
    key = 'monolith',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_obelisk.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Monolith',
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "per {C:attention}consecutive{} hand played",
            "that contains your",
            "most played {C:attention}poker hand",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.5}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            local hand, played = 'High Card', 0
            for k, v in pairs(G.GAME.hands) do
                if SMODS.is_poker_hand_visible(k) and v.played > played then
                    played = v.played
                    hand = k
                end
            end
            if next(context.poker_hands[hand]) then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_value = "xmult_gain",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
            else
                card.ability.extra.xmult = 1
                return {message = localize('k_reset'), colour = G.C.MULT}
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'aureusveil',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_midas_mask.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = "Aureus' Veil",
        text = {
            "All played {C:attention}face{} cards",
            "become {C:attention}Gold{} cards with a {C:attention}Gold Seal{}",
            "when scored",
        }
    },
    calculate = function (self, card, context)
        if context.before and not context.blueprint then
            local faces = 0
            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card:is_face() then
                    faces = faces + 1
                    scored_card:set_ability('m_gold', nil, true)
                    scored_card:set_seal('Gold')
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end
            if faces > 0 then
                return {
                    message = localize('k_gold'),
                    colour = G.C.MONEY
                }
            end
        end
    end
}

function JESTERPROJECT:calculate(context)
    if G.GAME.tjp_champion_enabled then
        if context.setting_blind and context.blind.boss then
            if SMODS.pseudorandom_probability(self, 'j_tjp_champion', G.GAME.tjp_champion_enabled.numerator, G.GAME.tjp_champion_enabled.denominator) then
                G.GAME.tjp_champion_enabled.numerator = G.GAME.tjp_champion_enabled.numerator - G.GAME.tjp_champion_enabled.decrease
                return {func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.blind:disable()
                                    play_sound('timpani')
                                    delay(0.4)
                                    return true
                                end
                            }))
                            SMODS.calculate_effect({message = localize('ph_boss_disabled')}, G.GAME.blind.children.animatedSprite)
                            return true
                        end
                    }))
                end, no_retrigger = true}
            else
                G.GAME.tjp_champion_enabled = nil
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.calculate_effect({message = 'Faliure!'}, G.GAME.blind.children.animatedSprite)
                        return true
                    end
                }))
            end
        end
    end
end

SMODS.Joker{
    key = 'champion',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_luchador.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Champion',
        text = {
            "Sell this card for a {C:green}#1# in #2#{}",
            "chance to disable the {C:attention}Boss Blind{} every Ante",
            "until failure, chance decreases by {C:attention}#3#{} every Ante",
        }
    },
    config = {extra = {numerator = 10, denominator = 10, decrease = 1}},
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.numerator, card.ability.extra.denominator, self.key)
        return {vars = {numerator, denominator, card.ability.extra.decrease}}
    end,
    calculate = function (self, card, context)
        if context.selling_self then
            G.GAME.tjp_champion_enabled = card.ability.extra
            return {message = 'Enabled!'}
        end
    end
}

SMODS.Joker{
    key = 'snapshot',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_photograph.pos,
    pixel_size = { h = 95 / 1.2 },
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Snapshot',
        text = {
            "Played {C:attention}face{} cards",
            "give {X:mult,C:white}X#1#{} Mult",
            "when scored",
        }
    },
    config = {extra = {xmult = 6}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'treasurecard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_gift.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Treasure Card',
        text = {
            "{X:attention,C:white}X#1#{} {C:attention}sell value",
            "to a random {C:attention}Joker{} or",
            "{C:attention}Consumable{} card when",
            "{C:attention}Blind{} is selected"
        }
    },
    config = {extra = {sell_value = 10}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.sell_value}}
    end,
    calculate = function (self, card, context)
        if context.setting_blind and not context.blueprint then
            local valid_cards = {}
            for _, area in ipairs({G.jokers, G.consumables}) do
                for _, v in ipairs(area.cards) do
                    table.insert(valid_cards, v)
                end
            end
            local chosen = pseudorandom_element(valid_cards, self.key)
            chosen.ability.extra_value = (chosen.ability.extra_value or 0) + ((chosen.sell_cost * card.ability.extra.sell_value) - chosen.sell_cost)
            chosen:set_cost()
            return {message = localize('k_val_up'), message_card = card, juice_card = chosen, colour = G.C.MONEY}
        end
    end
}

SMODS.Joker{
    key = 'beanbug',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_turtle_bean.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Bean Bug',
        text = {
            "{C:attention}+#1#{} hand size,",
            "increases by",
            "{C:attention}#2#{} every #3# Antes",
        }
    },
    config = {extra = {h_size = 5, h_gain = 1, antes = 8, count = 0}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.h_size, card.ability.extra.h_gain, card.ability.extra.antes}}
    end,
    calculate = function(self, card, context)
        if context.ante_change and context.ante_end then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count >= card.ability.extra.antes then
                card.ability.extra.h_size = card.ability.extra.h_size + card.ability.extra.h_gain
                card.ability.extra.count = 0
                return {message = localize('k_upgrade_ex')}
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
}

SMODS.Joker{
    key = 'devastation',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_erosion.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Devastation',
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult for each",
            "card below {C:attention}#3#{}",
            "in your full deck",
            'when {C:attention}Blind{} is selected',
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.25}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult, G.GAME.starting_deck_size}}
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local scalar = {value = card.ability.extra.xmult_gain*(G.GAME.starting_deck_size - #G.playing_cards)}
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_table = scalar,
                scalar_value = "value",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'exclusiveparking',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_reserved_parking.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Exclusive Parking',
        text = {
            "Each {C:attention}face{} card",
            "held in hand gives {C:money}$#1#{}",
            'gain increases by {C:money}$#2#{} if',
            'hand contains #3# or more {C:attention}face cards{}'
        }
    },
    config = {extra = {dollars = 1, dollar_gain = 2, faces = 3}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollar_gain, card.ability.extra.faces}}
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local face_cards = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_face() then face_cards = face_cards + 1 end
            end
            if face_cards >= card.ability.extra.faces then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "dollars",
                    scalar_value = "dollar_gain",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MONEY}
            end
        end
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card:is_face() then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED
                    }
                else
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                    return {
                        dollars = card.ability.extra.dollars,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.dollar_buffer = 0
                                    return true
                                end
                            }))
                        end
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = 'expressrefund',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_mail.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Express Refund',
        text = {
            "Earn {C:money}$#1#{} for each",
            "discarded {C:attention}#2#{} or {C:attention}#3#{}, ranks",
            "change when discarded",
        }
    },
    config = {extra = {dollars = 15}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars, localize(card.ability.extra.rank1.rank or 'Ace', 'ranks'), localize(card.ability.extra.rank2.rank or 'Ace', 'ranks')}}
    end,
    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and (context.other_card:get_id() == card.ability.extra.rank1.id or context.other_card:get_id() == card.ability.extra.rank2.id) then
            local valid_cards = {}
            for _, v in ipairs(G.playing_cards) do
                if not SMODS.has_no_rank(v) then
                    valid_cards[#valid_cards+1] = v
                end
            end
            if context.other_card:get_id() == card.ability.extra.rank1.id then
                local card1 = pseudorandom_element(valid_cards, self.key..1)
                card.ability.extra.rank1 = {rank = card1.base.value, id = card1.base.id}
            elseif context.other_card:get_id() == card.ability.extra.rank2.id then
                local card2 = pseudorandom_element(valid_cards, self.key..2)
                card.ability.extra.rank2 = {rank = card2.base.value, id = card2.base.id}
            end
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            return {
                dollars = card.ability.extra.dollars,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end,
    set_ability = function (self, card, initial, delay_sprites)
        if G.playing_cards then
            local valid_cards = {}
            for _, v in ipairs(G.playing_cards) do
                if not SMODS.has_no_rank(v) then
                    valid_cards[#valid_cards+1] = v
                end
            end
            local card1 = pseudorandom_element(valid_cards, self.key..1)
            card.ability.extra.rank1 = {rank = card1.base.value, id = card1.base.id}
            local card2 = pseudorandom_element(valid_cards, self.key..2)
            card.ability.extra.rank2 = {rank = card2.base.value , id = card2.base.id}
        else
            card.ability.extra.rank1 = {rank = 'Ace', id = 14}
            card.ability.extra.rank2 = {rank = '5', id = 5}
        end
    end
}

SMODS.Joker{
    key = 'tothestars',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_to_the_moon.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'To the Stars',
        text = {
            "Earn an extra {C:money}$#1#{} of",
            "{C:attention}interest{} for every {C:money}$5{} you",
            "have at end of round",
        }
    },
    config = {extra = {interest = 3}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.interest}}
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount + card.ability.extra.interest
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount - card.ability.extra.interest
    end
}

SMODS.Joker{
    key = 'illusion',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hallucination.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Illusion',
        text = {
            "Create a {C:dark_edition}Negative{}",
            '{C:spectral}Spectral{} card when any',
            "{C:attention}Booster Pack{} is opened",
        }
    },
    calculate = function(self, card, context)
        if context.open_booster then
            return {
                func = function()
                    JESTERPROJECT.event(function()
                        SMODS.add_card({set = 'Spectral', edition = 'e_negative'})
                        SMODS.calculate_effect({message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral, instant = true}, card)
                        return true
                    end)
                    delay(0.9375)
                end
            }
        end
    end
}

SMODS.Joker{
    key = 'omenseer',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_fortune_teller.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Omen Seer',
        text = {
            "{X:mult,C:white}X#1#{} Mult per {C:attention}consumable{}",
            "used this run",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive})",
        }
    },
    config = {extra = {xmult_gain = 0.75}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, (card.ability.extra.xmult_gain*(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.all or 0))+1}}
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = {(card.ability.extra.xmult_gain*G.GAME.consumeable_usage_total.all)+1} },
            }
        end
        if context.joker_main then
            return {xmult = (card.ability.extra.xmult_gain*(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.all or 0))+1}
        end
    end
}

SMODS.Joker{
    key = 'magician',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_juggler.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Magician',
        text = {
            "{C:attention}+#1#{} hand size,",
            'decreases by {C:attention}#2#{} if less',
            'than {C:attention}#3#{} cards are held in hand',
            'at the end of round'
        }
    },
    config = {extra = {h_size = 4, decrease = 1, cards = 8}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.h_size, card.ability.extra.decrease, card.ability.extra.cards}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and #G.hand.cards < card.ability.extra.cards then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "h_size",
                scalar_value = "decrease",
                operation = "-",
                no_message = true
            })
            return {message = localize({type = 'variable', key = 'a_handsize_minus', vars = {card.ability.extra.decrease}})}
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end
}

SMODS.Joker{
    key = 'alcoholic',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_drunkard.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Alcoholic',
        text = {
            "{C:attention}+#1#{} discards,",
            'decreases by {C:attention}#2#{} if two',
            'hands are played without discarding',
        }
    },
    config = {extra = {d_size = 4, decrease = 1, count = 0}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.d_size, card.ability.extra.decrease}}
    end,
    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count >= 2 then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "d_size",
                    scalar_value = "decrease",
                    operation = "-",
                    no_message = true
                })
                return {message = '-'..card.ability.extra.decrease..' Discard'..(card.ability.extra.decrease == 1 and '' or 's'), colour = G.C.RED}
            end
        end
        if context.pre_discard then
            card.ability.extra.count = 0
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
        ease_discard(card.ability.extra.d_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
        ease_discard(-card.ability.extra.d_size)
    end
}

SMODS.Joker{
    key = 'rockyjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_stone.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Rocky Jester',
        text = {
            "Gives {C:chips}+#1#{} Chips for",
            "each {C:attention}Stone Card",
            "in your {C:attention}full deck",
            "when a {C:attention}Stone Card{} is scored",
            "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
        }
    },
    config = {extra = {chips = 50}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_stone
        local stone_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
            end
        end
        return {vars = {card.ability.extra.chips, card.ability.extra.chips*stone_tally}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local stone_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
            end
            return {chips = card.ability.extra.chips*stone_tally}
        end
    end,
    enhancement_gate = 'm_stone'
}

SMODS.Joker{
    key = 'radiantjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_golden.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Radiant Jester',
        text = {
            "Earn {C:money}$#1#{} at",
            "end of round",
        }
    },
    config = {extra = {dollars = 20}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,
    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end
}

SMODS.Joker{
    key = 'unluckycat',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_lucky_cat.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Unlucky Cat',
        text = {
            'This Jester gains {X:mult,C:white}X#1#{} Mult',
            'every time a {C:attention}Lucky{} card',
            'does not trigger',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult_gain = 0.5, xmult = 1}},
    loc_vars = function (self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_lucky') and not context.other_card.lucky_trigger and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end,
    enhancement_gate = 'm_lucky'
}

SMODS.Joker{
    key = 'autograph',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_baseball.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Autograph',
        text = {
            "Jokers have a {C:green}#1# in Z{} chance",
            'to give {X:mult,C:white}XZ{} Mult',
            '{C:attention}Z{} is the number of owned Jokers'
        }
    },
    config = {extra = {numerator = 3}},
    loc_vars = function (self, info_queue, card)
        local numerator, _ = SMODS.get_probability_vars(card, card.ability.extra.numerator, G.jokers and #G.jokers.cards or 0, self.key)
        return {vars = {numerator}}
    end,
    calculate = function (self, card, context)
        if context.other_joker then
            if SMODS.pseudorandom_probability(card, self.key, card.ability.extra.numerator, #G.jokers.cards) then
                return {xmult = #G.jokers.cards}
            end
        end
    end,
}

local oldeasedollars = ease_dollars
function ease_dollars(mod, instant)
    if to_big(mod) > to_big(0) then
        G.GAME.tjp_dollars_gained = (G.GAME.tjp_dollars_gained or 0) + mod
    end
    local g = oldeasedollars(mod, instant)
    if not G.GAME.tjp_highest_money or to_big(G.GAME.tjp_highest_money) < to_big(G.GAME.dollars) then
        G.GAME.tjp_highest_money = G.GAME.dollars
    end
    return g
end

SMODS.Joker{
    key = 'bear',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_bull.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Bear',
        text = {
            "{C:chips}+#1#{} Chips for",
            "each {C:money}$1{} in your",
            'highest money this run',
            "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
        }
    },
    config = {extra = {chip_gain = 10}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.chip_gain, card.ability.extra.chip_gain*(G.GAME.tjp_highest_money or 0)}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {chips = card.ability.extra.chip_gain*(G.GAME.tjp_highest_money or 0)}
        end
    end
}

SMODS.Joker{
    key = 'energydrink',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_diet_cola.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Energy Drink',
        text = {
            "Sell this card to",
            "create {C:attention}#1#{} of the tag of",
            "the current or next blind"
        }
    },
    config = {extra = {tags = 5}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.tags}}
    end,
    calculate = function(self, card, context)
        if context.selling_self then
            local nextblind
            if not G.GAME.blind.in_blind then
                for k, v in pairs(G.GAME.round_resets.blind_states) do
                    if k ~= 'Boss' and v == 'Select' then
                        nextblind = k
                        break
                    end
                end
                if not nextblind then return nil end
            end
            return {func = function()
                JESTERPROJECT.event(function()
                    for _=1, card.ability.extra.tags do
                        local _tag = Tag(G.GAME.round_resets.blind_tags[nextblind or G.GAME.blind:get_type()])
                        _tag:set_ability()
                        add_tag(_tag)
                    end
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end)
            end}
        end
    end
}

SMODS.Joker{
    key = 'collectorscard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_trading.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = "Collector's Card",
        text = {
            "If only {C:attention}1{} card is discarded",
            "destroy it and earn {C:money}$#1#",
        }
    },
    config = {extra = {dollars = 10}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint and #context.full_hand == 1 then
            return {
                dollars = card.ability.extra.dollars,
                remove = true
            }
        end
    end
}

SMODS.Joker{
    key = 'memorygame',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_flash.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Memory Game",
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "per {C:attention}reroll{} in the shop",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 2}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {
                message = localize({type = 'variable', key = 'a_xmult', vars = {card.ability.extra.xmult}}),
                colour = G.C.MULT,
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'caramelcorn',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_popcorn.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Caramel Corn",
        text = {
            "{C:mult}+#1#{} Mult",
            "{C:mult}-#2#{} Mult per",
            "round played",
        }
    },
    config = {extra = {mult = 150, mult_loss = 50}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_loss}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.mult - card.ability.extra.mult_loss <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.RED
                }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "mult",
                    scalar_value = "mult_loss",
                    operation = "-",
                    no_message = true
                })
                return {
                    message = localize { type = 'variable', key = 'a_mult_minus', vars = { card.ability.extra.mult_loss } },
                    colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker{
    key = 'splittrousers',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_trousers.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Split Trousers",
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "if two consecutive hands",
            "contain a {C:attention}Pair{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 1, count = 0}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.before then
            if next(context.poker_hands['Pair']) then
                card.ability.extra.count = card.ability.extra.count + 1
                if card.ability.extra.count >= 2 then
                    SMODS.scale_card(card, {
                        ref_table = card.ability.extra,
                        ref_value = "xmult",
                        scalar_value = "xmult_gain",
                        no_message = true
                    })
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.MULT,
                    }
                end
            else
                card.ability.extra.count = 0
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

local function reset_tjp_prehistoricjester_suit()
    G.GAME.current_round.tjp_prehistoricjester_suit = G.GAME.current_round.tjp_prehistoricjester_suit or 'Spades'
    local prehistoric_cards = {}
    for _, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(v) then prehistoric_cards[#prehistoric_cards+1] = v end
    end
    local prehistoric_card = pseudorandom_element(prehistoric_cards, 'tjp_prehistoricjester'..G.GAME.round_resets.ante)
    G.GAME.current_round.tjp_prehistoricjester_suit = prehistoric_card.base.suit
end

SMODS.Joker{
    key = 'prehistoricjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ancient.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Prehistoric Jester",
        text = {
            "Each played card with",
            "{V:1}#2#{} suit gives",
            "{X:mult,C:white}X#1#{} Mult for every",
            "card with {V:1}#2#{} suit held in hand when scored,",
            "{s:0.8}suit changes at end of round",
        }
    },
    config = {extra = {xmult = 3}},
    loc_vars = function(self, info_queue, card)
        local suit = G.GAME.current_round.tjp_prehistoricjester_suit or 'Spades'
        return {vars = {card.ability.extra.xmult, localize(suit, 'suits_singular'), colours = {G.C.SUITS[suit]}}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(G.GAME.current_round.tjp_prehistoricjester_suit) then
            local count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_suit(G.GAME.current_round.tjp_prehistoricjester_suit) then
                    count = count + card.ability.extra.xmult
                end
            end
            if count > 0 then
                return {xmult = card.ability.extra.xmult*count}
            end
        end
    end
}

SMODS.Joker{
    key = 'miso',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ramen.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Miso",
        text = {
            '{X:mult,C:white}X#1#{} Mult',
            'loses {X:mult,C:white}X#2#{} Mult per',
            'unused discard at the end of round'
        }
    },
    config = {extra = {xmult = 8, xmult_loss = 0.25}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_loss}}
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            if card.ability.extra.xmult - (card.ability.extra.xmult_loss*G.GAME.current_round.discards_left) <= 1 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {message = localize('k_eaten_ex')}
            else
                local scalar = {value = card.ability.extra.xmult_loss*G.GAME.current_round.discards_left}
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_table = scalar,
                    scalar_value = "value",
                    operation = "-",
                    no_message = true
                })
                return {
                    message = localize { type = 'variable', key = 'a_xmult_minus', vars = { card.ability.extra.xmult_loss*G.GAME.current_round.discards_left } },
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'wirelessconnection',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_walkie_talkie.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Wireless Connection",
        text = {
            "Each played {C:attention}10{} or {C:attention}4",
            "gives {X:mult,C:white}X#1#{} Mult when scored,",
            "gains {X:mult,C:white}X#2#{} Mult when a",
            '{C:attention}Four of a Kind{} is played'
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 0.4}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_gain}}
    end,
    calculate = function(self, card, context)
        if context.before and context.scoring_name == 'Four of a Kind' and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
        end
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 10 or context.other_card:get_id() == 4) then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'clubsoda',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_selzer.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Club Soda",
        text = {
            "Retrigger everything for",
            "the next {C:attention}#1#{} hands",
        }
    },
    config = { extra = { hands_left = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands_left } }
    end,
    calculate = function(self, card, context)
        if context.repetition or (context.retrigger_joker_check and context.other_card ~= card) then
            return {
                repetitions = 1
            }
        end
        if context.after and not context.blueprint then
            if card.ability.extra.hands_left - 1 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_drank_ex'),
                    colour = G.C.FILTER
                }
            else
                card.ability.extra.hands_left = card.ability.extra.hands_left - 1
                return {
                    message = card.ability.extra.hands_left .. '',
                    colour = G.C.FILTER
                }
            end
        end
    end
}

local function reset_tjp_citadel_suit()
    G.GAME.current_round.tjp_citadel_suit = G.GAME.current_round.tjp_citadel_suit or 'Spades'
    local citadel_cards = {}
    for _, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(v) then citadel_cards[#citadel_cards+1] = v end
    end
    local citadel_card = pseudorandom_element(citadel_cards, 'tjp_citadel'..G.GAME.round_resets.ante)
    G.GAME.current_round.tjp_citadel_suit = citadel_card.base.suit
end

SMODS.Joker{
    key = 'citadel',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_castle.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Citadel",
        text = {
            "This Jester gains {C:chips}+#1#{} Chips",
            "per discarded {V:1}#2#{} card,",
            'gain doubles when a {V:1}#2#{} card is destroyed',
            "suit changes every round",
            "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)",
        }
    },
    config = { extra = { chips = 0, chip_mod = 4 } },
    loc_vars = function(self, info_queue, card)
        local suit = G.GAME.current_round.tjp_citadel_suit or 'Spades'
        return { vars = { card.ability.extra.chip_mod, localize(suit, 'suits_singular'), card.ability.extra.chips, colours = { G.C.SUITS[suit] } } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint and not context.other_card.debuff and context.other_card:is_suit(G.GAME.current_round.tjp_citadel_suit) then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "chips",
                scalar_value = "chip_mod",
                no_message = true
            })
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS
            }
        end
        if context.remove_playing_cards then
            for _, v in ipairs(context.removed) do
                if v:is_suit(G.GAME.current_round.tjp_citadel_suit) then
                    SMODS.scale_card(card, {
                        ref_table = card.ability.extra,
                        ref_value = "chip_mod",
                        scalar_table = {value = 2},
                        scalar_value = "value",
                        operation = "X",
                        no_message = true
                    })
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.CHIPS
                    }
                end
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'frownyface',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_smiley.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Frowny Face",
        text = {
            "Each played {C:attention}face{} card gives",
            "{X:mult,C:white}X#1#{} Mult for every",
            "{C:attention}face{} card held in hand when scored",
        }
    },
    config = {extra = {xmult = 1}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            local count = 0
            for _, v in ipairs(G.hand.cards) do
                if v:is_face() then
                    count = count + 1
                end
            end
            if count > 0 then
                return {xmult = card.ability.extra.xmult*count}
            end
        end
    end
}

SMODS.Joker{
    key = 'inferno',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_campfire.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Inferno",
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "for each card {C:attention}sold{}",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return {
                message = localize('k_upgrade_ex')
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'eticket',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ticket.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "E-Ticket",
        text = {
            "Each played {C:attention}Gold{} card gives",
            "{C:money}$#1#{} for every {C:attention}Gold{}",
            "card in played hand when scored",
        }
    },
    config = { extra = {dollars = 10} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, 'm_gold') then
            local count = 0
            for _, v in ipairs(context.full_hand) do
                if SMODS.has_enhancement(v, 'm_gold') then
                    count = count + 1
                end
            end
            if count > 0 then
                return {dollars = card.ability.extra.dollars*count}
            end
        end
    end
}

SMODS.Joker{
    key = 'mrflesh',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_mr_bones.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = "Mr. Flesh",
        text = {
            "Prevents Death",
            "if chips scored",
            "are at least {C:attention}75%",
            "of required chips",
        }
    },
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over and context.main_eval then
            if to_big(G.GAME.chips) / to_big(G.GAME.blind.chips) >= to_big(0.25) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        card:juice_up()
                        return true
                    end
                }))
                return {
                    message = localize('k_saved_ex'),
                    saved = 'Saved by Mr. Flesh',
                    colour = G.C.RED
                }
            end
        end
    end,
}

SMODS.Joker{
    key = 'gymnast',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_acrobat.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Gymnast",
        text = {
            'Gains {X:mult,C:white}X#1#{} Mult',
            'for each {C:attention}consecutive{} hand',
            'that does not win',
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = { extra = {xmult = 1, xmult_gain = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function (self, card, context)
        if context.after then
            if (SMODS.calculate_round_score()+G.GAME.chips) < G.GAME.blind.chips then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_value = "xmult_gain",
                    no_message = true
                })
                return {message = localize('k_upgrade_ex'), colour = G.C.MULT}
            else
                card.ability.extra.xmult = 1
                return {message = localize('k_reset')}
            end
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'thaliaandmelpomene',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_sock_and_buskin.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Thalia and Melpomene",
        text = {
            "Retrigger all",
            "played {C:attention}face{} cards",
            '{C:attention}#1#{} additional times',
        }
    },
    config = { extra = {repetitions = 4} },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:is_face() then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end
}

local oldcardaddtodeck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    local g = oldcardaddtodeck(self, from_debuff)
    if self.sell_cost then
        G.GAME.tjp_allownedjokerssellvalues = (G.GAME.tjp_allownedjokerssellvalues or 0) + self.sell_cost
    end
    return g
end

SMODS.Joker{
    key = 'buccaneer',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_swashbuckler.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Buccaneer",
        text = {
            "Adds {X:attention,C:white}X#1#{} the sell value",
            "of all {C:attention}Jokers{} owned",
            "this run to Mult",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
        }
    },
    config = { extra = { xsellvalue = 3 } },
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xsellvalue, (G.GAME.tjp_allownedjokerssellvalues or 0)*card.ability.extra.xsellvalue}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {mult = (G.GAME.tjp_allownedjokerssellvalues or 0)*card.ability.extra.xsellvalue}
        end
    end
}

SMODS.Joker{
    key = 'bard',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_troubadour.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = "Bard",
        text = {
            "{C:attention}+#1#{} hand size,",
            "{C:blue}-#2#{} discards each round",
        }
    },
    config = { extra = { h_size = 6, discards = -2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size, -card.ability.extra.discards } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discards
        ease_discard(card.ability.extra.discards)
        G.hand:change_size(card.ability.extra.h_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
        ease_discard(-card.ability.extra.discards)
        G.hand:change_size(-card.ability.extra.h_size)
    end
}

SMODS.Joker{
    key = 'license',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_certificate.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "License",
        text = {
            "When hand is played, add a",
            "permanent copy of a {C:attention}random{} card",
            'in your deck with a random {C:attention}seal{} to deck',
            "and draw it to {C:attention}hand",
        }
    },
    calculate = function(self, card, context)
        if context.before then
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            local random = pseudorandom_element(G.playing_cards, self.key)
            local _card = copy_card(random, nil, nil, G.playing_card)
            _card:add_to_deck()
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, _card)
            G.hand:emplace(_card)
            _card.states.visible = nil
            _card:set_seal(SMODS.poll_seal({guaranteed = true}))
            G.E_MANAGER:add_event(Event({
                func = function()
                    _card:start_materialize()
                    return true
                end
            }))
            return {
                message = localize('k_copied_ex'),
                playing_cards_created = {_card},
            }
        end
    end
}

SMODS.Joker{
    key = 'illegiblejester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_smeared.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Illegible Jester',
        text = {
            "All cards are",
            "considered",
            "{C:attention}Wild Cards{}",
        }
    }
}

local oldaddtag = add_tag
function add_tag(_tag)
    if not _tag.from_load then
        G.GAME.tjp_tags_obtained = (G.GAME.tjp_tags_obtained or 0) + 1
    end
    return oldaddtag(_tag)
end

SMODS.Joker{
    key = 'flashback',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_throwback.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Flashback",
        text = {
            "{X:mult,C:white} X#1# {} Mult for each",
            "{C:attention}Tag{} obtained this run",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = { extra = { xmult = 0.75 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, 1 + (G.GAME.tjp_tags_obtained or 0) * card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.tag_added and not context.blueprint then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { 1 + G.GAME.tjp_tags_obtained * card.ability.extra.xmult } }
            }
        end
        if context.joker_main then
            return {
                xmult = 1 + (G.GAME.tjp_tags_obtained or 0) * card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'voterfraud',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hanging_chad.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Voter Fraud',
        text = {
            "Retrigger {C:attention}first{} played",
            "card used in scoring",
            "{C:attention}#1#{} additional times",
        }
    },
    config = {extra = {repetitions = 10}},
    loc_vars = function (self, info_queue, card)
        return {vars = {card.ability.extra.repetitions}}
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end
}

SMODS.Joker{
    key = 'rawdiamond',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_rough_gem.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Raw Diamond',
        text = {
            "Played cards with {C:diamonds}Diamond{} suit",
            "earn {C:money}$#1#{} for every {C:attention}#2#{} {C:diamonds}Diamonds{}",
            "in full deck when scored",
        }
    },
    config = { extra = { dollars = 1, diamonds = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.diamonds } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Diamonds") then
            local count = 0
            for _, v in ipairs(G.playing_cards) do
                if v:is_suit("Diamonds") then
                    count = count + 0.5
                end
            end
            count = math.floor(count)
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars*count
            return {
                dollars = card.ability.extra.dollars*count,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.dollar_buffer = 0
                            return true
                        end
                    }))
                end
            }
        end
    end
}

-- Bloodstone seems to be missing from the images provided

SMODS.Joker{
    key = 'pike',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_arrowhead.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Pike',
        text = {
            "Played cards with",
            "{C:spades}Spade{} suit give",
            "{C:chips}+#1#{} Chips when scored",
        }
    },
    config = { extra = { chips = 200 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Spades") then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'blackopal',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_onyx_agate.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Black Opal',
        text = {
            "Played cards with",
            "{C:clubs}Club{} suit give",
            "{X:mult,C:white}X#1#{} Mult when scored",
            "increases by {X:mult,C:white}X#2#{} for",
            'every previously scored {C:clubs}Club{}',
            "{C:inactive}(Resets after each hand played)",
        }
    },
    config = { extra = { xmult = 2, xmult_gain = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit("Clubs") then
            local xmult = card.ability.extra.xmult
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'xmult',
                scalar_value = 'xmult_gain',
                no_message = true
            })
            return {
                xmult = xmult
            }
        end
        if context.after then
            card.ability.extra.xmult = 2
        end
    end
}

SMODS.Joker{
    key = 'crystallinejester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_glass.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Crystalline Jester',
        text = {
            "This Jester gains {X:mult,C:white}X#1#{} Mult",
            "for every {C:attention}Glass Card",
            "that is destroyed, duplicate",
            'all destroyed {C:attention}Glass Cards',
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
        }
    },
    config = { extra = { xmult = 1, xmult_gain = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local glass_cards = {}
            for _, v in ipairs(context.removed) do
                if SMODS.has_enhancement(v, 'm_glass') then table.insert(glass_cards, v) end
            end
            if #glass_cards > 0 then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'xmult',
                    scalar_table = {value = card.ability.extra.xmult_gain*#glass_cards},
                    scalar_value = 'value',
                    no_message = true
                })
                for _, v in ipairs(glass_cards) do
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(v, nil, nil, G.playing_card)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card.states.visible = nil
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:start_materialize()
                            return true
                        end
                    }))
                end
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    extra = {
                        message = localize('k_copied_ex')
                    }
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

local oldsmodsshowman = SMODS.showman
function SMODS.showman(card_key)
    if SMODS.find_card('j_tjp_virtuoso')[1] and SMODS.find_card(card_key)[1] then
        return true
    end
    return oldsmodsshowman(card_key)
end

local oldgetcurrentpool = get_current_pool
function get_current_pool(...)
    local g, _pool_key = oldgetcurrentpool(...)
    if SMODS.find_card('j_tjp_virtuoso')[1] then
        for _, virtuoso in ipairs(SMODS.find_card('j_tjp_virtuoso')) do
            for i=1, #g do
                local v = g[i]
                if v ~= 'UNAVAILABLE' and G.P_CENTERS[v] and (G.P_CENTERS[v].set == 'Joker' or G.P_CENTERS[v].consumeable) and SMODS.find_card(v)[1] then
                    for _=1, virtuoso.ability.extra.morelikely-1 do
                        g[#g+1] = v
                    end
                end
            end
        end
    end
    return g, _pool_key
end

SMODS.Joker{
    key = 'virtuoso',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_ring_master.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Virtuoso',
        text = {
            'Held {C:attention}Jokers{} and {C:attention}Consumables{}',
            'are {C:attention}X#1#{} more likely to appear'
        }
    },
    config = { extra = { morelikely = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.morelikely } }
    end
}

SMODS.Joker{
    key = 'vase',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_flower_pot.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Vase',
        text = {
            '{X:mult,C:white}X#1#{} for every {C:attention}suit{}',
            'in played hand',
            'every card counts as if',
            'it has {C:attention}#2#{} suits'
        }
    },
    config = {extra = {xmult = 3, suits = 71162389}},
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.suits } }
    end,
    calculate = function (self, card, context)
        if context.joker_main then
            local count = 0
            for _, v in ipairs(context.full_hand) do
                if not SMODS.has_no_suit(v) then
                    count = count + 1
                end
            end
            if count > 0 then
                return {xmult = card.ability.extra.xmult*count*card.ability.extra.suits}
            end
        end
    end
}

SMODS.Joker{
    key = 'prototype',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_blueprint.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Prototype',
        text = {
            'All {C:attention}Jokers{} to the right',
            'are {C:attention}retriggered{}'
        }
    },
    calculate = function (self, card, context)
        if context.retrigger_joker_check then
            local my_pos, other_pos
            for i=1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                end
                if G.jokers.cards[i] == context.other_card then
                    other_pos = i
                end
            end
            if my_pos and other_pos and other_pos > my_pos then
                return {repetitions = 1}
            end
        end
    end
}

SMODS.Joker{
    key = 'microscopicjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_wee.pos,
    display_size = { w = 71 * 0.7, h = 95 * 0.7 },
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Microscopic Jester',
        text = {
            "This Jester gains",
            "{C:chips}+#2#{} Chips when each",
            "played {C:attention}2{} or {C:attention}3{} or {C:attention}4{} is scored",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)",
        }
    },
    config = {extra = {chips = 0, chip_gain = 25}},
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 2 or context.other_card:get_id() == 3 or context.other_card:get_id() == 4) and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'chips',
                scalar_value = 'chip_gain',
                no_message = true
            })
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                message_card = card
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Joker{
    key = 'ecstaticandrew',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_merry_andy.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Ecstatic Andrew',
        text = {
            'Permanently gain #1# discard#3#',
            'for every #2# hand size you have',
            'when {C:attention}Small Blind{} is selected'
        }
    },
    config = {extra = {discards = 1, hand_size = 5}},
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.discards, card.ability.extra.hand_size, card.ability.extra.discards == 1 and '' or 's' } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and context.blind.name == "Small Blind" then
            local discards = math.floor(G.hand.config.card_limit/card.ability.extra.hand_size)
            if discards > 0 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + (card.ability.extra.discards * discards)
                ease_discard(card.ability.extra.discards * discards)
                return {message = '+'..(card.ability.extra.discards * discards)..' Discard'..(card.ability.extra.discards*discards == 1 and '' or 's'), colour = G.C.RED}
            end
        end
    end
}

local oldsmodsgetprobabilityvars = SMODS.get_probability_vars
function SMODS.get_probability_vars(trigger_obj, base_numerator, base_denominator, identifier, from_roll, no_mod)
	if SMODS.find_card('j_tjp_oopsallnaneinfs')[1] and not no_mod then
		base_numerator = base_denominator
	end
	return oldsmodsgetprobabilityvars(trigger_obj, base_numerator, base_denominator, identifier, from_roll, no_mod)
end

local oldsmodspseudorandomprobability = SMODS.pseudorandom_probability
function SMODS.pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)
	if SMODS.find_card('j_tjp_oopsallnaneinfs')[1] and not no_mod then
		SMODS.post_prob = SMODS.post_prob or {}
		SMODS.post_prob[#SMODS.post_prob + 1] = {
			pseudorandom_result = true,
			result = true,
			trigger_obj = trigger_obj,
			numerator = base_denominator,
			denominator = base_denominator,
			identifier = identifier or seed,
		}
		return true
	end
	return oldsmodspseudorandomprobability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)
end

SMODS.Joker{
    key = 'oopsallnaneinfs',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_oops.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Oops! All naneinfs',
        text = {
            "All {C:attention}listed {C:green,E:1,S:1.1}probabilities{}",
            "are {C:attention}guaranteed{} and {C:attention}retriggered{}", -- Only retriggers jokers
        }
    },
    calculate = function (self, card, context)
        if (context.repetition or context.retrigger_joker_check) and SMODS.post_prob and SMODS.post_prob[1] then
            local passed = false
            for _, v in ipairs(SMODS.post_prob) do
                if v.trigger_obj == context.other_card then
                    passed = true
                    break
                end
            end
            if passed then
                return {repetitions = 1}
            end
        end
    end
}

local function reset_tjp_thetotem_card()
    G.GAME.current_round.tjp_thetotem_card = { rank = 'Ace', suit = 'Spades' }
    local valid_totem_cards = {}
    for _, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(v) and not SMODS.has_no_rank(v) then
            valid_totem_cards[#valid_totem_cards + 1] = v
        end
    end
    local totem_card = pseudorandom_element(valid_totem_cards, 'tjp_thetotem' .. G.GAME.round_resets.ante)
    if totem_card then
        G.GAME.current_round.tjp_thetotem_card.rank = totem_card.base.value
        G.GAME.current_round.tjp_thetotem_card.suit = totem_card.base.suit
        G.GAME.current_round.tjp_thetotem_card.id = totem_card.base.id
    end
end

SMODS.Joker{
    key = 'thetotem',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_idol.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'The Totem',
        text = {
            "Gains {X:mult,C:white}X#1#{} when a {C:attention}#2#",
            "of {V:1}#3#{} is scored",
            "{s:0.8}Card changes every round",
            '{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)',
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 4}},
    loc_vars = function(self, info_queue, card)
        local totem_card = G.GAME.current_round.tjp_thetotem_card or { rank = 'Ace', suit = 'Spades' }
        return { vars = { card.ability.extra.xmult_gain, localize(totem_card.rank, 'ranks'), localize(totem_card.suit, 'suits_plural'), card.ability.extra.xmult, colours = { G.C.SUITS[totem_card.suit] } } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == G.GAME.current_round.tjp_thetotem_card.id and context.other_card:is_suit(G.GAME.current_round.tjp_thetotem_card.suit) then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'xmult',
                scalar_value = 'xmult_gain',
                no_message = true
            })
            return {message = localize('k_upgrade_ex'), colour = G.C.MULT, message_card = card}
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

local function has_two_other_suits(count, suit)
    local other_count = 0
    for k, v in pairs(count) do
        if k ~= suit then
            if v > 0 then
                other_count = other_count + v
                if other_count >= 2 then return true end
            end
        end
    end
    return false
end

local function saw_triple(count, suit)
    if count[suit] > 0 and has_two_other_suits(count, suit) then return true else return false end
end

SMODS.Joker{
    key = 'seeingtriple',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_seeing_double.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Seeing Triple',
        text = {
            "{X:mult,C:white}X#1#{} Mult if played",
            "hand has a scoring",
            "{C:clubs}Club{} card and two scoring",
            "cards of any other {C:attention}suit",
        }
    },
    config = { extra = { xmult = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local hand, suit = context.scoring_hand, 'Clubs'
            local suit_tally = {}
            for i = #SMODS.Suit.obj_buffer, 1, -1 do
                suit_tally[SMODS.Suit.obj_buffer[i]] = 0
            end
            for i = 1, #hand do
                if not SMODS.has_any_suit(hand[i]) then
                    for k, v in pairs(suit_tally) do
                        if hand[i]:is_suit(k) then suit_tally[k] = suit_tally[k] + 1 end
                    end
                end
            end
            for i = 1, #hand do
                if SMODS.has_any_suit(hand[i]) then
                    if hand[i]:is_suit(suit) and suit_tally[suit] == 0 then suit_tally[suit] = suit_tally[suit] + 1 end
                    for k, v in pairs(suit_tally) do
                        if hand[i]:is_suit(k) and suit_tally[k] == 0  then suit_tally[k] = suit_tally[k] + 1 end
                    end
                end
            end
            if saw_triple(suit_tally, suit) then return {xmult = card.ability.extra.xmult} end
        end
    end
}

SMODS.Joker{
    key = 'rodeoclown',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_matador.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Rodeo Clown',
        text = {
            'Earn {C:money}$#1#{} if played hand',
            'does not beat the {C:attention}Boss Blind{}'
        }
    },
    config = { extra = { dollars = 30 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.boss and context.after and ((SMODS.calculate_round_score()+G.GAME.chips) < G.GAME.blind.chips) then
            return {dollars = card.ability.extra.dollars}
        end
    end
}

SMODS.Joker{
    key = 'titanic',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_hit_the_road.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Titanic',
        text = {
            "This Jester gains {X:mult,C:white} X#1# {} Mult",
            "for every {C:attention}Jack{} discarded",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = { extra = { xmult_gain = 0.5, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint and not context.other_card.debuff and context.other_card:get_id() == 11 then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'xmult',
                scalar_value = 'xmult_gain',
                no_message = true
            })
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                colour = G.C.RED
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

for i, v in ipairs({{name = 'Alliance', hand = 'Pair', xmult = 10}, {name = 'Trinity', hand = 'Three of a Kind', xmult = 15}, {name = 'Bloodline', hand = 'Four of a Kind', xmult = 20}, {name = 'Chain', hand = 'Straight', xmult = 15}, {name = 'Nation', hand = 'Flush', xmult = 10}}) do
    SMODS.Joker{
        key = v.name:lower()..'jester',
        atlas = 'Jesters',
        pos = {x = 4+i, y = 4},
        rarity = 3,
        eternal_compat = true,
        perishable_compat = true,
        blueprint_compat = true,
        loc_txt = {
            name = 'The '..v.name,
            text = {
                '{X:mult,C:white}X#1#{} Mult if played',
                'hand contains',
                'a {C:attention}'..v.hand..'{}',
            }
        },
        config = {extra = {xmult = v.xmult}},
        loc_vars = function (self, info_queue, card)
            return {vars = {card.ability.extra.xmult}}
        end,
        calculate = function (self, card, context)
            if context.joker_main and next(context.poker_hands[v.hand]) then
                return {xmult = card.ability.extra.xmult}
            end
        end
    }
end

SMODS.Joker{
    key = 'daredevil',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_stuntman.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Daredevil',
        text = {
            "{C:chips}+#1#{} Chips,",
            'permanently lose {C:attention}#2#{} hand size',
            'if score at end of round is less than',
            '{X:attention,C:white}1.5X{} the required score'
        }
    },
    config = { extra = { chips = 2000, hand_size = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.hand_size } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and G.GAME.chips < (G.GAME.blind.chips*1.5) and not context.blueprint then
            G.hand:change_size(-card.ability.extra.hand_size)
        end
        if context.joker_main then
            return {chips = card.ability.extra.chips}
        end
    end
}

SMODS.Joker{
    key = 'intangiblejester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_invisible.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Intangible Jester',
        text = {
            "Sell this card to create",
            "a {C:dark_edition}Negative {C:attention}duplicate{} of the rightmost Joker",
            'for every {C:attention}#1#{} rounds this',
            'Joker has been held',
            "{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1# and {C:attention}#3#{C:inactive} duplicates{})",
        }
    },
    config = { extra = { invis_rounds = 0, total_rounds = 4, current_duplicates = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.total_rounds, card.ability.extra.invis_rounds, card.ability.extra.current_duplicates } }
    end,
    calculate = function(self, card, context)
        if context.selling_self and card.ability.extra.current_duplicates > 0 and not context.blueprint and G.jokers.cards[#G.jokers.cards] ~= card then
            local copied_joker = copy_card(G.jokers.cards[#G.jokers.cards])
            copied_joker:set_edition("e_negative", true)
            copied_joker:add_to_deck()
            G.jokers:emplace(copied_joker)
            return { message = localize('k_duplicated_ex') }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            card.ability.extra.invis_rounds = card.ability.extra.invis_rounds + 1
            if card.ability.extra.invis_rounds >= card.ability.extra.total_rounds then
                card.ability.extra.invis_rounds = 0
                card.ability.extra.current_duplicates = card.ability.extra.current_duplicates + 1
            end
        end
    end
}

SMODS.Joker{
    key = 'sketch',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_brainstorm.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Sketch',
        text = {
            'Retrigger all {C:attention}Jokers{} to the left',
            'of this {C:attention}Jester{}',
        }
    },
    calculate = function (self, card, context)
        if context.retrigger_joker_check then
            local my_pos, other_pos
            for i=1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    my_pos = i
                end
                if G.jokers.cards[i] == context.other_card then
                    other_pos = i
                end
            end
            if my_pos and other_pos and other_pos < my_pos then
                return {repetitions = 1}
            end
        end
    end
}

SMODS.Joker{
    key = 'spacecraft',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_satellite.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Spacecraft',
        text = {
            "Earn {C:money}$#1#{} at end of",
            "round per {C:planet}Planet",
            "card used this run",
            "{C:inactive}(Currently {C:money}$#2#{C:inactive})",
        }
    },
    config = {extra = {dollars = 1}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars, card.ability.extra.dollars*(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.planet or 0)}}
    end,
    calc_dollar_bonus = function (self, card)
        local bonus = card.ability.extra.dollars*(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.planet or 0)
        return bonus > 0 and bonus or nil
    end
}

SMODS.Joker{
    key = 'shootthesun',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_shoot_the_moon.pos,
    rarity = 1,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Shoot the Sun',
        text = {
            "Each {C:attention}Queen{}",
            "held in hand",
            "gives {C:mult}+#1#{} Mult",
        }
    },
    config = { extra = { mult = 50 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == 12 then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'forkliftcertification',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_drivers_license.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Forklift Certification',
        text = {
            "{X:mult,C:white}X#1#{} Mult if you have",
            "at least {C:attention}#2#{} un-Enhanced",
            "cards in your full deck",
            "{C:inactive}(Currently {C:attention}#3#{C:inactive})",
        }
    },
    config = { extra = { xmult = 30, driver_amount = 18 } },
    loc_vars = function(self, info_queue, card)
        local driver_tally = 0
        for _, v in pairs(G.playing_cards or {}) do
            if not next(SMODS.get_enhancements(v)) then driver_tally = driver_tally + 1 end
        end
        return { vars = { card.ability.extra.xmult, card.ability.extra.driver_amount, driver_tally } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local driver_tally = 0
            for _, v in pairs(G.playing_cards) do
                if not next(SMODS.get_enhancements(v)) then driver_tally = driver_tally + 1 end
            end
            if driver_tally >= card.ability.extra.driver_amount then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'augur',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_cartomancer.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Augur',
        text = {
            "Create three {C:dark_edition}Negative{} {C:tarot}Tarot{} cards",
            "when {C:attention}Blind{} is selected",
        }
    },
    calculate = function(self, card, context)
        if context.setting_blind then
            return {func = function()
                JESTERPROJECT.event(function()
                    for _=1, 3 do
                        SMODS.add_card({set = 'Tarot', edition = 'e_negative'})
                        SMODS.calculate_effect({message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot, instant = true}, card)
                    end
                    return true
                end)
                delay(0.9375)
            end}
        end
    end
}

local oldsetcost = Card.set_cost
function Card:set_cost()
    local g = oldsetcost(self)
    if (self.ability.set == 'Planet' or (self.ability.set == 'Booster' and self.config.center.kind == 'Celestial')) and SMODS.find_card("j_tjp_cosmologist")[1] then self.cost = -7 end
    return g
end


SMODS.Joker{
    key = 'cosmologist',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_astronomer.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_txt = {
        name = 'Cosmologist',
        text = {
            "All {C:planet}Planet{} cards and",
            "{C:planet}Celestial Packs{} in",
            "the shop cost {C:money}-$7{}",
        }
    },
}

SMODS.Joker{
    key = 'charredjester',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_burnt.pos,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Charred Jester',
        text = {
            "Upgrade the level of",
            "every {C:attention}discarded",
            "poker hand",
        }
    },
    calculate = function(self, card, context)
        if context.pre_discard and not context.hook then
            local text, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            return {
                level_up = true,
                level_up_hand = text
            }
        end
    end
}

SMODS.Joker{
    key = 'autonomy',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_bootstraps.pos,
    rarity = 2,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = 'Autonomy',
        text = {
            "{X:mult,C:white}X#1#{} Mult for every",
            "{C:money}$#2#{} you have gained this run",
            "{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult)",
        }
    },
    config = { extra = { xmult_gain = 0.5, dollars = 50 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.dollars, (card.ability.extra.xmult_gain * math.floor((G.GAME.tjp_dollars_gained or 0) / card.ability.extra.dollars))+1 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {xmult = (card.ability.extra.xmult_gain * math.floor((G.GAME.tjp_dollars_gained or 0) / card.ability.extra.dollars))+1}
        end
    end
}

SMODS.Joker{
    key = 'cantio',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_caino.pos,
    soul_pos = G.P_CENTERS.j_caino.soul_pos,
    rarity = 4,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Can'tio",
        text = {
            "This Jester gains {X:mult,C:white} X#1# {} Mult",
            "when a {C:attention}face{} card",
            "is discarded",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 3}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult_gain, card.ability.extra.xmult}}
    end,
    calculate = function(self, card, context)
        if context.discard and context.other_card:is_face() then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "xmult",
                scalar_value = "xmult_gain",
                no_message = true
            })
            return { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } } }
        end
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end
    end
}

SMODS.Joker{
    key = 'triboulent',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_triboulet.pos,
    soul_pos = G.P_CENTERS.j_triboulet.soul_pos,
    rarity = 4,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Triboulen't",
        text = {
            "Played {C:attention}Kings{} and",
            "{C:attention}Queens{} each give",
            "{X:mult,C:white} X#1# {} Mult when scored",
            "increases by {X:mult,C:white}X#2#{} for",
            'every previously scored {C:attention}King{} and {C:attention}Queen{}',
        }
    },
    config = {extra = {xmult = 1, xmult_gain = 2}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_gain}}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 12 or context.other_card:get_id() == 13) then
            local xmult = card.ability.extra.xmult
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'xmult',
                scalar_value = 'xmult_gain',
                no_message = true
            })
            if xmult > 1 then
                return {
                    xmult = xmult
                }
            end
        end
        if context.after then
            card.ability.extra.xmult = 1
        end
    end
}

SMODS.Joker{
    key = 'yoricknt',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_yorick.pos,
    soul_pos = G.P_CENTERS.j_yorick.soul_pos,
    rarity = 4,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "Yorickn't",
        text = {
            "This Jester gains",
            "{X:mult,C:white} X#1# {} Mult every {C:attention}#2#{C:inactive} [#3#]{}",
            "cards discarded",
            "{C:inactive}(Currently {X:mult,C:white} X#4# {C:inactive} Mult)",
        }
    },
    config = { extra = { xmult = 1, xmult_gain = 23, discards = 23, discards_remaining = 23 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult_gain, card.ability.extra.discards, card.ability.extra.discards_remaining, card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            if card.ability.extra.discards_remaining <= 1 then
                card.ability.extra.discards_remaining = card.ability.extra.discards
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "xmult",
                    scalar_value = "xmult_gain",
                    no_message = true
                })
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                    colour = G.C.RED
                }
            else
                card.ability.extra.discards_remaining = card.ability.extra.discards_remaining - 1
                return nil, true
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end
}

-- Chicon't is impossible with mod compatibility plus I don't have time to write all the effects

SMODS.Joker{
    key = 'ntperkeo',
    atlas = 'Jesters',
    pos = G.P_CENTERS.j_perkeo.pos,
    soul_pos = G.P_CENTERS.j_perkeo.soul_pos,
    rarity = 4,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    loc_txt = {
        name = "N'tperkeo",
        text = {
            "Creates a {C:dark_edition}Negative{} copy of",
            "{C:attention}1{} random {C:attention}Joker{}",
            "card in your possession",
            "at the end of the {C:attention}shop",
        }
    },
    calculate = function(self, card, context)
        if context.ending_shop and G.jokers.cards[1] then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local card_to_copy, _ = pseudorandom_element(G.jokers.cards, self.key)
                    local copied_card = copy_card(card_to_copy)
                    copied_card:set_edition("e_negative", true)
                    copied_card:add_to_deck()
                    G.jokers:emplace(copied_card)
                    return true
                end
            }))
            return { message = localize('k_duplicated_ex') }
        end
    end
}

SMODS.Blind{
    key = 'theclaw',
    atlas = 'Blinds',
    pos = {y = 0},
    config = {lost_hand_size = 0},
    boss = G.P_BLINDS.bl_hook.boss,
    boss_colour = G.P_BLINDS.bl_hook.boss_colour,
    loc_txt = {
        name = 'The Claw',
        text = {
            '-2 hand size when a hand is played',
            '(Minimum of 1)'
        }
    },
    calculate = function (self, blind, context)
        if not blind.disabled then
            if context.press_play then
                blind:wiggle()
                G.hand:change_size((-G.hand.config.card_limit)+math.max(G.hand.config.card_limit-2, 1))
                blind.effect.lost_hand_size = blind.effect.lost_hand_size - ((-G.hand.config.card_limit)+math.max(G.hand.config.card_limit-2, 1))
            end
        end
    end,
    disable = function (self)
        G.hand:change_size(G.GAME.blind.effect.lost_hand_size)
    end,
    defeat = function (self)
        if not G.GAME.blind.disabled then
            G.hand:change_size(G.GAME.blind.effect.lost_hand_size)
        end
    end
}

SMODS.Blind{
    key = 'thebull',
    atlas = 'Blinds',
    pos = {y = 1},
    boss = G.P_BLINDS.bl_ox.boss,
    boss_colour = G.P_BLINDS.bl_ox.boss_colour,
    loc_txt = {
        name = 'The Bull',
        text = {
            'Negate money if #1# is',
            'held in hand or in played hand'
        }
    },
    loc_vars = function(self)
        return {vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}}
    end,
    collection_loc_vars = function(self)
        return {vars = {localize('ph_most_played')}}
    end,
    calculate = function (self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                blind.triggered = false
                local passed = not not next(context.poker_hands[G.GAME.current_round.most_played_poker_hand])
                if not passed then
                    local _, _, poker_hands = G.FUNCS.get_poker_hand_info(G.hand.cards)
                    if next(poker_hands[G.GAME.current_round.most_played_poker_hand]) then
                        passed = true
                    end
                end
                if passed then
                    blind.triggered = true
                    if not context.check then
                        ease_dollars(-G.GAME.dollars*2)
                        blind:wiggle()
                    end
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thejail',
    atlas = 'Blinds',
    pos = {y = 2},
    boss = G.P_BLINDS.bl_house.boss,
    boss_colour = G.P_BLINDS.bl_house.boss_colour,
    loc_txt = {
        name = 'The Jail',
        text = {
            'All cards are drawn face down',
            'until last hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.stay_flipped and context.to_area == G.hand and G.GAME.current_round.hands_left > 1 then
                return {stay_flipped = true}
            end
        end
    end,
    disable = function(self)
        for i=1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for _, v in ipairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
}

SMODS.Blind{
    key = 'thebarrier',
    atlas = 'Blinds',
    pos = {y = 3},
    mult = 16,
    boss = G.P_BLINDS.bl_wall.boss,
    boss_colour = G.P_BLINDS.bl_wall.boss_colour,
    loc_txt = {
        name = 'The Barrier',
        text = {
            'Extemely large blind'
        }
    },
    disable = function(self)
        G.GAME.blind.chips = G.GAME.blind.chips / 8
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end
}

SMODS.Blind{
    key = 'thecog',
    atlas = 'Blinds',
    pos = {y = 4},
    boss = G.P_BLINDS.bl_wheel.boss,
    boss_colour = G.P_BLINDS.bl_wheel.boss_colour,
    loc_txt = {
        name = 'The Cog',
        text = {
            '#1# in #2# cards are destroyed when drawn',
            'otherwise, draw them face down'
        }
    },
    loc_vars = function(self)
        local numerator, denominator = SMODS.get_probability_vars(self, 1, 7, self.key)
        return {vars = {numerator, denominator}}
    end,
    collection_loc_vars = function(self)
        return {vars = {'1', '7'}}
    end,
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.stay_flipped and context.to_area == G.hand then
                if SMODS.pseudorandom_probability(blind, self.key, 1, 7) then
                    SMODS.destroy_cards(context.other_card, nil, true)
                else
                    return {stay_flipped = true}
                end
            end
        end
    end,
    disable = function(self)
        for i=1, #G.hand.cards do
            if G.hand.cards[i].facing == 'back' then
                G.hand.cards[i]:flip()
            end
        end
        for _, v in ipairs(G.playing_cards) do
            v.ability.wheel_flipped = nil
        end
    end
}

SMODS.Blind{
    key = 'thehand',
    atlas = 'Blinds',
    pos = {y = 5},
    boss = G.P_BLINDS.bl_arm.boss,
    boss_colour = G.P_BLINDS.bl_arm.boss_colour,
    loc_txt = {
        name = 'The Hand',
        text = {
            'Decrease the level of all contained',
            'poker hands in the played hand 3 times'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                blind.triggered = false
                local _, _, poker_hands = G.FUNCS.get_poker_hand_info(context.full_hand)
                local effects = {}
                for k, v in pairs(poker_hands) do
                    if next(v) and to_big(G.GAME.hands[k].level) > to_big(1) then
                        blind.triggered = true
                        table.insert(effects, {level_up = (-G.GAME.hands[k].level)+math.max(1, G.GAME.hands[k].level-3), level_up_hand = k})
                    end
                end
                if not context.check and effects[1] then
                    return SMODS.merge_effects(effects)
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thehammer',
    atlas = 'Blinds',
    pos = {y = 6},
    boss = G.P_BLINDS.bl_club.boss,
    boss_colour = G.P_BLINDS.bl_club.boss_colour,
    loc_txt = {
        name = 'The Hammer',
        text = {
            'Hand must be played with no Clubs',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if v:is_suit('Clubs') then
                        passed = false
                        break
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v:is_suit('Clubs') then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'theshark',
    atlas = 'Blinds',
    pos = {y = 7},
    boss = G.P_BLINDS.bl_fish.boss,
    boss_colour = G.P_BLINDS.bl_fish.boss_colour,
    loc_txt = {
        name = 'The Shark',
        text = {
            'All cards drawn are permanently debuffed',
            'after 2 hands or discards are used'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.stay_flipped and context.to_area == G.hand and (G.GAME.current_round.discards_used >= 2 or G.GAME.current_round.hands_played >= 2) then
                context.other_card.ability.tjp_debuffed_by_theshark = true
                context.other_card:set_debuff(true)
            end
        end
    end,
    disable = function(self)
        for _, v in ipairs(G.playing_cards) do
            v.ability.tjp_debuffed_by_theshark = nil
        end
    end
}

SMODS.Blind{
    key = 'theseer',
    atlas = 'Blinds',
    pos = {y = 8},
    boss = G.P_BLINDS.bl_psychic.boss,
    boss_colour = G.P_BLINDS.bl_psychic.boss_colour,
    loc_txt = {
        name = 'The Seer',
        text = {
            'Two poker hands that contain 5 scoring cards',
            'must be held in hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local cards = {}
                for _, v in ipairs(G.hand.cards) do
                    if not v.highlighted then
                        table.insert(cards, v)
                    end
                end
                local _, _, poker_hands = G.FUNCS.get_poker_hand_info(cards)
                local valid_hands = {}
                for k, v in pairs(poker_hands) do
                    if v[1] and #v[1] >= 5 then
                        table.insert(valid_hands, k)
                    end
                end
                if #valid_hands < 2 then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thetyrant',
    atlas = 'Blinds',
    pos = {y = 9},
    boss = G.P_BLINDS.bl_goad.boss,
    boss_colour = G.P_BLINDS.bl_goad.boss_colour,
    loc_txt = {
        name = 'The Tyrant',
        text = {
            'Hand must be played with no Spades',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if v:is_suit('Spades') then
                        passed = false
                        break
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v:is_suit('Spades') then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thefire',
    atlas = 'Blinds',
    pos = {y = 10},
    config = {firstdrawncard = {}},
    boss = G.P_BLINDS.bl_water.boss,
    boss_colour = G.P_BLINDS.bl_water.boss_colour,
    loc_txt = {
        name = 'The Fire',
        text = {
            'Played hand must contain',
            'a scoring #1#'
        }
    },
    loc_vars = function (self)
        local blind = G.GAME.blind
        if blind.config.blind.key ~= self.key or not (blind.effect.firstdrawncard and next(blind.effect.firstdrawncard)) then
            return {vars = {'(rank and suit of the first drawn card)'}}
        else
            return {vars = {localize(blind.effect.firstdrawncard.rank, 'ranks')..' of '..localize(blind.effect.firstdrawncard.suit, 'suits_plural')}}
        end
    end,
    collection_loc_vars = function (self)
        return {vars = {'(rank and suit of the first drawn card)'}}
    end,
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.first_hand_drawn then
                blind.effect.firstdrawncard.id = context.hand_drawn[1].base.id
                blind.effect.firstdrawncard.rank = context.hand_drawn[1].base.value
                blind.effect.firstdrawncard.suit = context.hand_drawn[1].base.suit
                blind:set_text()
            end
            if context.debuff_hand then
                local passed = false
                for _, v in ipairs(context.scoring_hand) do
                    if v:get_id() == blind.effect.firstdrawncard.id and v:is_suit(blind.effect.firstdrawncard.suit) then
                        passed = true
                        break
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'therift',
    atlas = 'Blinds',
    pos = {y = 11},
    boss = G.P_BLINDS.bl_window.boss,
    boss_colour = G.P_BLINDS.bl_window.boss_colour,
    loc_txt = {
        name = 'The Rift',
        text = {
            'Hand must be played with no Diamonds',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if v:is_suit('Diamonds') then
                        passed = false
                        break
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v:is_suit('Diamonds') then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'theshackle',
    atlas = 'Blinds',
    pos = {y = 12},
    boss = G.P_BLINDS.bl_manacle.boss,
    boss_colour = G.P_BLINDS.bl_manacle.boss_colour,
    loc_txt = {
        name = 'The Shackle',
        text = {
            'Up to 3 random Negative Jokers',
            'are destroyed'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.setting_blind then
                local valid_jokers = {}
                for _, v in ipairs(G.jokers.cards) do
                    if v.edition and v.edition.negative and not SMODS.is_eternal(v, blind) then
                        table.insert(valid_jokers, v)
                    end
                end
                if valid_jokers[1] then
                    blind:wiggle()
                    if #valid_jokers <= 3 then
                        SMODS.destroy_cards(valid_jokers)
                    else
                        local jokers_to_destroy = {}
                        for i=1, 3 do
                            local joker, index = pseudorandom_element(valid_jokers, self.key)
                            table.remove(valid_jokers, index)
                            table.insert(jokers_to_destroy, joker)
                        end
                        SMODS.destroy_cards(jokers_to_destroy)
                    end
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thepupil',
    atlas = 'Blinds',
    pos = {y = 13},
    boss = G.P_BLINDS.bl_eye.boss,
    boss_colour = G.P_BLINDS.bl_eye.boss_colour,
    loc_txt = {
        name = 'The Pupil',
        text = {
            'Only #1# can be played',
        }
    },
    loc_vars = function (self)
        local played, hand = math.huge, nil
        for k, v in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(k) and v.played < played then
                played = v.played
                hand = k
            end
        end
        return {vars = {hand}}
    end,
    collection_loc_vars = function (self)
        return {vars = {'(least played hand)'}}
    end,
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local played, hand = math.huge, nil
                for k, v in pairs(G.GAME.hands) do
                    if SMODS.is_poker_hand_visible(k) and v.played < played then
                        played = v.played
                        hand = k
                    end
                end
                if context.scoring_name ~= hand then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thethroat',
    atlas = 'Blinds',
    pos = {y = 14},
    boss = G.P_BLINDS.bl_mouth.boss,
    boss_colour = G.P_BLINDS.bl_mouth.boss_colour,
    loc_txt = {
        name = 'The Throat',
        text = {
            'Only #1# can be played',
        }
    },
    loc_vars = function (self)
        local blind = G.GAME.blind
        if blind.config.blind.key ~= self.key or not blind.effect.poker_hand then
            return {vars = {'(random poker hand)'}}
        else
            return {vars = {localize(blind.effect.poker_hand, 'poker_hands')}}
        end
    end,
    collection_loc_vars = function (self)
        return {vars = {'(random poker hand)'}}
    end,
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.setting_blind then
                local valid_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if SMODS.is_poker_hand_visible(k) then
                        table.insert(valid_hands, k)
                    end
                end
                blind.effect.poker_hand = pseudorandom_element(valid_hands, self.key)
                blind:set_text()
            end
            if context.debuff_hand then
                if context.scoring_name ~= blind.effect.poker_hand then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thevine',
    atlas = 'Blinds',
    pos = {y = 15},
    boss = G.P_BLINDS.bl_plant.boss,
    boss_colour = G.P_BLINDS.bl_plant.boss_colour,
    loc_txt = {
        name = 'The Vine',
        text = {
            'Hand must be played with no face cards',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if v:is_face(true) then
                        passed = false
                        break
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v:is_face(true) then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thehydra',
    atlas = 'Blinds',
    pos = {y = 16},
    boss = G.P_BLINDS.bl_serpent.boss,
    boss_colour = G.P_BLINDS.bl_serpent.boss_colour,
    loc_txt = {
        name = 'The Hydra',
        text = {
            'Cards are not drawn after playing a hand',
            'one card is drawn after discarding'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.pre_discard and not context.hook then
                blind.effect.discarding = true
            end
            if context.press_play then
                blind.effect.playing = true
            end
            if context.drawing_cards and (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) then
                if blind.effect.playing then
                    blind.effect.playing = nil
                    return {cards_to_draw = 0}
                elseif blind.effect.discarding then
                    blind.effect.discarding = nil
                    return {cards_to_draw = 1}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thespire',
    atlas = 'Blinds',
    pos = {y = 17},
    boss = G.P_BLINDS.bl_pillar.boss,
    boss_colour = G.P_BLINDS.bl_pillar.boss_colour,
    loc_txt = {
        name = 'The Spire',
        text = {
            'Hand must be played with no cards previously played this ante',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if context.check then
                        if v.ability.played_this_ante then
                            v.ability.tjp_real_played_this_ante = true
                            passed = false
                            break
                        end
                    else
                        if v.ability.tjp_real_played_this_ante then
                            v.ability.tjp_real_played_this_ante = nil
                            passed = false
                            break
                        end
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v.ability.played_this_ante then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end,
    disable = function(self)
        for _, v in ipairs(G.playing_cards) do
            v.ability.tjp_real_played_this_ante = nil
        end
    end,
    defeat = function(self)
        for _, v in ipairs(G.playing_cards) do
            v.ability.tjp_real_played_this_ante = nil
        end
    end
}

SMODS.Blind{
    key = 'thepin',
    atlas = 'Blinds',
    pos = {y = 18},
    debuff = {h_size_le = 1},
    boss = G.P_BLINDS.bl_needle.boss,
    boss_colour = G.P_BLINDS.bl_needle.boss_colour,
    loc_txt = {
        name = 'The Pin',
        text = {
            'Must play only 1 card'
        }
    }
}

SMODS.Blind{
    key = 'theneck',
    atlas = 'Blinds',
    pos = {y = 19},
    boss = G.P_BLINDS.bl_window.boss,
    boss_colour = G.P_BLINDS.bl_window.boss_colour,
    loc_txt = {
        name = 'The Neck',
        text = {
            'Hand must be played with no Hearts',
            'held in hand or in played hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                local passed = true
                for _, v in ipairs(context.full_hand) do
                    if v:is_suit('Hearts') then
                        passed = false
                        break
                    end
                end
                if passed then
                    for _, v in ipairs(G.hand.cards) do
                        if v:is_suit('Hearts') then
                            passed = false
                            break
                        end
                    end
                end
                if not passed then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end
}

SMODS.Blind{
    key = 'thejaw',
    atlas = 'Blinds',
    pos = {y = 20},
    boss = G.P_BLINDS.bl_tooth.boss,
    boss_colour = G.P_BLINDS.bl_tooth.boss_colour,
    loc_txt = {
        name = 'The Jaw',
        text = {
            'Lose $3 when a joker is triggered',
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.post_trigger then
                return {dollars = -3, message_card = blind.children.animatedSprite}
            end
        end
    end
}

SMODS.Blind{
    key = 'theknife',
    atlas = 'Blinds',
    pos = {y = 21},
    boss = G.P_BLINDS.bl_flint.boss,
    boss_colour = G.P_BLINDS.bl_flint.boss_colour,
    loc_txt = {
        name = 'The Knife',
        text = {
            'Base Chips and Mult are set to 1',
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.modify_hand then
                blind.triggered = true
                mult = mod_mult(1)
                hand_chips = mod_chips(1)
                update_hand_text({sound = 'chips2', modded = true}, {chips = hand_chips, mult = mult})
            end
        end
    end
}

SMODS.Blind{
    key = 'thescar',
    atlas = 'Blinds',
    pos = {y = 22},
    boss = G.P_BLINDS.bl_mark.boss,
    boss_colour = G.P_BLINDS.bl_mark.boss_colour,
    loc_txt = {
        name = 'The Scar',
        text = {
            'All cards debuffed if more than',
            '3 face cards are remaining in deck'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.hand_drawn then
                for _, v in ipairs(G.playing_cards) do
                    blind:debuff_card(v, true)
                end
            end
            if context.debuff_card and context.debuff_card.area ~= G.jokers then
                local count = 0
                for _, v in ipairs(G.deck.cards) do
                    if v:is_face(true) then
                        count = count + 1
                    end
                end
                if count > 3 then
                    return {debuff = true}
                end
            end
        end
    end
}

local oldcalcjoker = Card.calculate_joker
function Card:calculate_joker(context)
    if G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == 'bl_tjp_chestnutclub' and self.tjp_chestnutclub_joker then
        local ret, post = oldcalcjoker(self.tjp_chestnutclub_joker, context)
        if ret then
            ret.card = self
        end
        return ret, post
    end
    return oldcalcjoker(self, context)
end

local oldcardareaload = CardArea.load
function CardArea:load(cardAreaTable)
    local g = oldcardareaload(self, cardAreaTable)
    if self == G.jokers then
        for _, v in ipairs(self.cards) do
            if v.ability.tjp_chestnutclub_joker then
                for  _, v2 in ipairs(self.cards) do
                    if v.ability.tjp_chestnutclub_joker == v2.sort_id then
                        v.tjp_chestnutclub_joker = v2
                        break
                    end
                end
            end
        end
    end
    return g
end

SMODS.Blind{
    key = 'chestnutclub',
    atlas = 'Blinds',
    pos = {y = 23},
    boss = G.P_BLINDS.bl_final_acorn.boss,
    boss_colour = G.P_BLINDS.bl_final_acorn.boss_colour,
    loc_txt = {
        name = 'Chestnut Club',
        text = {
            'Flips and shuffles all Joker cards',
            'Jokers act as a random different owned joker each hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.setting_blind then
                if G.jokers.cards[1] then
                    G.jokers:unhighlight_all()
                    for _, joker in ipairs(G.jokers.cards) do
                        joker:flip()
                    end
                    if #G.jokers.cards > 1 then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        G.jokers:shuffle('aajk')
                                        play_sound('cardSlide1', 0.85)
                                        return true
                                    end,
                                }))
                                delay(0.15)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        G.jokers:shuffle('aajk')
                                        play_sound('cardSlide1', 1.15)
                                        return true
                                    end
                                }))
                                delay(0.15)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        G.jokers:shuffle('aajk')
                                        play_sound('cardSlide1', 1)
                                        return true
                                    end
                                }))
                                delay(0.5)
                                return true
                            end
                        }))
                    end
                    local jokers_to_copy = SMODS.shallow_copy(G.jokers.cards)
                    pseudoshuffle(jokers_to_copy, self.key)
                    for i, v in ipairs(G.jokers.cards) do
                        v.tjp_chestnutclub_joker = jokers_to_copy[i]
                        v.ability.tjp_chestnutclub_joker = jokers_to_copy[i].sort_id
                    end
                end
            end
            if context.after then
                local jokers_to_copy = SMODS.shallow_copy(G.jokers.cards)
                pseudoshuffle(jokers_to_copy, self.key)
                for i, v in ipairs(G.jokers.cards) do
                    v.tjp_chestnutclub_joker = jokers_to_copy[i]
                    v.ability.tjp_chestnutclub_joker = jokers_to_copy[i].sort_id
                    SMODS.calculate_effect({message = localize('k_reset')}, v)
                end
            end
        end
    end,
    disable = function (self)
        for _, v in ipairs(G.jokers.cards) do
            v.tjp_chestnutclub_joker = nil
            v.ability.tjp_chestnutclub_joker = nil
        end
    end,
    defeat = function (self)
        for _, v in ipairs(G.jokers.cards) do
            v.tjp_chestnutclub_joker = nil
            v.ability.tjp_chestnutclub_joker = nil
        end
    end
}

SMODS.Blind{
    key = 'sprucesword',
    atlas = 'Blinds',
    pos = {y = 24},
    boss = G.P_BLINDS.bl_final_leaf.boss,
    boss_colour = G.P_BLINDS.bl_final_leaf.boss_colour,
    loc_txt = {
        name = 'Spruce Sword',
        text = {
            'Hands will not score until',
            '4 Joker slots are empty'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.debuff_hand then
                if G.jokers.config.card_limit - #G.jokers.cards < 4 then
                    blind.triggered = true
                    return {debuff = true}
                end
            end
        end
    end,
}

SMODS.Blind{
    key = 'sapphireshield',
    atlas = 'Blinds',
    pos = {y = 25},
    mult = 30,
    boss = G.P_BLINDS.bl_final_vessel.boss,
    boss_colour = G.P_BLINDS.bl_final_vessel.boss_colour,
    loc_txt = {
        name = 'Sapphire Shield',
        text = {
            'Horrifyingly large blind'
        }
    },
    disable = function (self)
        G.GAME.blind.chips = G.GAME.blind.chips / 15
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end
}

SMODS.Blind{
    key = 'rubyrose',
    atlas = 'Blinds',
    pos = {y = 26},
    boss = G.P_BLINDS.bl_final_heart.boss,
    boss_colour = G.P_BLINDS.bl_final_heart.boss_colour,
    loc_txt = {
        name = 'Ruby Rose',
        text = {
            'One random Joker destroyed each hand',
            'half of remaining Jokers are disabled each hand'
        }
    },
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.after and G.jokers.cards[1] then
                local valid_jokers = {}
                for _, v in ipairs(G.jokers.cards) do
                    if not SMODS.is_eternal(v, blind) then
                        table.insert(valid_jokers, v)
                    end
                end
                if valid_jokers[1] then
                    local joker = pseudorandom_element(valid_jokers, self.key)
                    SMODS.destroy_cards(joker)
                end
            end
            if context.hand_drawn and G.jokers.cards[1] then
                local jokers = SMODS.shallow_copy(G.jokers.cards)
                for i=1, math.floor(#G.jokers.cards/2) do
                    local joker, index = pseudorandom_element(jokers, self.key)
                    table.remove(jokers, index)
                    joker:set_debuff(true)
                end
            end
        end
    end,
}

SMODS.Blind{
    key = 'cobaltcoin',
    atlas = 'Blinds',
    pos = {y = 27},
    boss = G.P_BLINDS.bl_final_bell.boss,
    boss_colour = G.P_BLINDS.bl_final_bell.boss_colour,
    loc_txt = {
        name = 'Cobalt Coin',
        text = {
            'All cards have a #1# in #2# chance to be',
            'permanently debuffed when discarded or played'
        }
    },
    loc_vars = function (self)
        local numerator, denominator = SMODS.get_probability_vars(self, 1, 4, self.key)
        return {vars = {numerator, denominator}}
    end,
    collection_loc_vars = function (self)
        return {vars = {'1', '4'}}
    end,
    calculate = function(self, blind, context)
        if not blind.disabled then
            if context.discard then
                if SMODS.pseudorandom_probability(blind, self.key, 1, 4) then
                    context.other_card.tjp_debuffed_by_cobaltcoin = true
                    context.other_card:set_debuff(true)
                end
            end
            if context.before then
                for _, v in ipairs(context.full_hand) do
                    if SMODS.pseudorandom_probability(blind, self.key, 1, 4) then
                        v.tjp_debuffed_by_cobaltcoin = true
                        v:set_debuff(true)
                    end
                end
            end
        end
    end,
}

function JESTERPROJECT.set_debuff(card)
    if card.ability.tjp_debuffed_by_theshark or card.ability.tjp_debuffed_by_cobaltcoin then
        return true
    end
end

function JESTERPROJECT.reset_game_globals(run_start)
    reset_tjp_improv_ranks()
    reset_tjp_prehistoricjester_suit()
    reset_tjp_citadel_suit()
    reset_tjp_thetotem_card()
end