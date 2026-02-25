--- Thanks to thewintercomet on discord for the base of this code!
local oldcardsetedition = Card.set_edition
function Card:set_edition(edition, immediate, silent, delay)
    if not SMODS.find_card("j_tjp_delusion")[1] or not self.playing_card then
        return oldcardsetedition(self, edition, immediate, silent, delay)
    end

    SMODS.enh_cache:write(self, nil)
	-- Check to see if negative is being removed and reduce card_limit accordingly
	if (self.added_to_deck or self.joker_added_to_deck_but_debuffed or (self.area == G.hand and not self.debuff)) and self.edition and self.edition.card_limit then
		if self.ability.consumeable and self.area == G.consumeables then
			G.consumeables.config.card_limit = G.consumeables.config.card_limit - self.edition.card_limit
		elseif self.ability.set == 'Joker' and self.area == G.jokers then
			G.jokers.config.card_limit = G.jokers.config.card_limit - self.edition.card_limit
		elseif self.area == G.hand then
			if G.hand.config.real_card_limit then
				G.hand.config.real_card_limit = G.hand.config.real_card_limit - self.edition.card_limit
			end
			G.hand.config.card_limit = G.hand.config.card_limit - self.edition.card_limit
		end
	end

	local old_edition = self.edition and self.edition.key
	if old_edition then
		self.ignore_base_shader[old_edition] = nil
		self.ignore_shadow[old_edition] = nil

		local on_old_edition_removed = G.P_CENTERS[old_edition] and G.P_CENTERS[old_edition].on_remove
		if type(on_old_edition_removed) == "function" then
			on_old_edition_removed(self)
		end
	end

	local edition_type = nil
	if type(edition) == 'string' then
        if string.sub(edition, 1, 2) ~= 'e_' then
            edition = 'e_' .. edition
        end
		assert(G.P_CENTERS[edition], ("Edition \"%s\" is invalid."):format(edition))
		edition_type = string.sub(edition, 3)
	elseif type(edition) == 'table' then
		if edition.type then
			edition_type = edition.type
		else
			for k, v in pairs(edition) do
				if v then
					assert(not edition_type, "Tried to apply more than one edition.")
					edition_type = k
				end
			end
		end
	end

	if not edition_type or edition_type == 'base' then
		if self.edition == nil then -- early exit
			return
		end
		self.edition = nil -- remove edition from card
		self:set_cost()
		if not silent then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = not immediate and 0.2 or 0,
				blockable = not immediate,
				func = function()
					self:juice_up(1, 0.5)
					play_sound('whoosh2', 1.2, 0.6)
					return true
				end
			}))
		end
		return
	end

    local all_types = copy_table(JESTERPROJECT.get_quantum_editions(self))
    local edition_table = {}
    
    if next(JESTERPROJECT.get_quantum_editions(self)) then
        for _, ed_key in pairs(all_types) do
            local get_edition = G.P_CENTERS["e_"..ed_key]
            for k, v in pairs(get_edition.config) do
                if type(v) == 'table' then
                    edition_table[k] = copy_table(v)
                else
                    edition_table[k] = v
                end
                if k == 'card_limit' and (self.added_to_deck or self.joker_added_to_deck_but_debuffed or (self.area == G.hand and not self.debuff)) and G.jokers and G.consumeables then
                    if self.ability.consumeable and self.area == G.consumeables then
                        G.consumeables.config.card_limit = G.consumeables.config.card_limit - v
                    elseif self.ability.set == 'Joker' and self.area == G.jokers then
                        G.jokers.config.card_limit = G.jokers.config.card_limit - v
                    elseif self.area == G.hand then
                        if G.hand.config.real_card_limit then
                            G.hand.config.real_card_limit = G.hand.config.real_card_limit - v
                        end
                        G.hand.config.card_limit = G.hand.config.card_limit - v
                    end
                end
            end
            local on_edition_removed = get_edition.on_remove
            if type(on_edition_removed) == "function" then
                on_edition_removed(self)
            end
        end
    end
    local other_get_edition = G.P_CENTERS["e_"..edition_type]
    self.edition = {}
    self.edition[edition_type] = true
    self.edition.type = edition_type
    local other_key = 'e_' .. edition_type
    self.edition.key = other_key
    if other_get_edition.override_base_shader or other_get_edition.disable_base_shader then
        self.ignore_base_shader[other_key] = true
    end
    if other_get_edition.no_shadow or other_get_edition.disable_shadow then
        self.ignore_shadow[other_key] = true
    end
    for k, v in pairs(edition_table) do
        self.edition[k] = v
    end
    local all_types = {edition_type}
    for k, v in ipairs(JESTERPROJECT.get_quantum_editions(self)) do
        table.insert(all_types, v)
    end

    for _, ed_key in pairs(all_types) do
        local get_edition = G.P_CENTERS["e_"..ed_key]
        for k, v in pairs(get_edition.config) do
            if k == 'card_limit' and (self.added_to_deck or self.joker_added_to_deck_but_debuffed or (self.area == G.hand and not self.debuff)) and G.jokers and G.consumeables then
                if self.ability.consumeable then
                    G.consumeables.config.card_limit = G.consumeables.config.card_limit + v
                elseif self.ability.set == 'Joker' then
                    G.jokers.config.card_limit = G.jokers.config.card_limit + v
                elseif self.area == G.hand then
                    local is_in_pack = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or (G.STATE == G.STATES.SMODS_BOOSTER_OPENED and SMODS.OPENED_BOOSTER.config.center.draw_hand))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            if G.hand.config.real_card_limit then
                                G.hand.config.real_card_limit = G.hand.config.real_card_limit + v
                            end
                            G.hand.config.card_limit = G.hand.config.card_limit + v
                            if not is_in_pack and G.GAME.blind.in_blind then
                                G.FUNCS.draw_from_deck_to_hand(v)
                            end
                            return true
                        end
                    }))
                end
            end
        end
        local on_edition_applied = get_edition.on_apply
        if type(on_edition_applied) == "function" then
            on_edition_applied(self)
        end
    end

	if self.area and self.area == G.jokers then
		if self.edition then
			if not G.P_CENTERS['e_' .. (self.edition.type)].discovered then
				discover_card(G.P_CENTERS['e_' .. (self.edition.type)])
			end
		else
			if not G.P_CENTERS['e_base'].discovered then
				discover_card(G.P_CENTERS['e_base'])
			end
		end
	end

	if self.edition and not silent then
		local ed = G.P_CENTERS['e_' .. (self.edition.type)]
		G.CONTROLLER.locks.edition = true
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = not immediate and 0.2 or 0,
			blockable = not immediate,
			func = function()
				if self.edition then
					self:juice_up(1, 0.5)
					play_sound(ed.sound.sound, ed.sound.per, ed.sound.vol)
				end
				return true
			end
		}))
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.1,
			func = function()
				G.CONTROLLER.locks.edition = false
				return true
			end
		}))
	end

	if delay then
		self.delay_edition = true
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				self.delay_edition = nil
				return true
			end
		}))
	end

	if G.jokers and self.area == G.jokers then
		check_for_unlock({ type = 'modify_jokers' })
	end

	self:set_cost()
end

function JESTERPROJECT.calculate_quantum_editions(card, effects, context)
    if not card:can_calculate(context.ignore_debuff, context.remove_playing_cards) then return nil end

    context.extra_edition = true
    local extra_editions = JESTERPROJECT.get_quantum_editions(card)
    table.sort(extra_editions, function(a, b) return G.P_CENTERS["e_"..a].order < G.P_CENTERS["e_"..b].order end)
    local old_edition = card.edition and copy_table(card.edition) or nil
    for i, v in ipairs(extra_editions) do
        local ed_key = "e_"..v
        if G.P_CENTERS[ed_key] then
            local cardedition = {
                [v] = true,
                type = v,
                key = ed_key
            }
            for k, v in pairs(G.P_CENTERS[ed_key].config) do
                cardedition[k] = copy_table(v)
            end
            card.edition = cardedition
            card.ability.extra_edition = ed_key
            G.GAME.triggered_edition = {card.unique_val, ed_key}
            local eval = {edition = card:calculate_edition(context)}
            G.GAME.triggered_edition = nil
            table.insert(effects, eval)
        end
    end
    
    card.edition = old_edition
    context.extra_edition = nil
end

function JESTERPROJECT.get_quantum_editions(card)
    if SMODS.find_card('j_tjp_delusion')[1] then
        local quantumeditions = {'polychrome'}
        for i, v in ipairs(quantumeditions) do
            if v == (card.edition or {}).type then
                table.remove(quantumeditions, i)
                break
            end
        end
        return quantumeditions
    end
    return {}
end

function JESTERPROJECT.get_enhancements(card, extra_only)
    if not card then return {} end
    local enhancements = {}
    if SMODS.find_card('j_tjp_delusion')[1] and card.config.center_key ~= 'm_steel' then table.insert(enhancements, 'm_steel') end
    if SMODS.find_card('j_tjp_illegiblejester')[1] and card.config.center_key ~= 'm_wild' then table.insert(enhancements, 'm_wild') end
    if not extra_only and card.config.center_key ~= "c_base" then table.insert(enhancements, 1, card.config.center_key) end
    return enhancements
end

function JESTERPROJECT.calculate_quantum_enhancements(card, effects, context)
    if not card:can_calculate(context.ignore_debuff, context.remove_playing_cards) then return nil end
    context.extra_enhancement = true
    local old_ability = copy_table(card.ability)
    local old_center = card.config.center
    local old_center_key = card.config.center_key
    local extra_enhancements_list = JESTERPROJECT.get_enhancements(card, true)
    table.sort(extra_enhancements_list, function(a, b) return G.P_CENTERS[a].order < G.P_CENTERS[b].order end)
    for _, k in ipairs(extra_enhancements_list) do
        JESTERPROJECT.safe_set_ability(card, G.P_CENTERS[k])
        card.ability.extra_enhancement = k
        G.GAME.triggered_enhancement = {card.unique_val, k}
        local eval = eval_card(card, context)
        G.GAME.triggered_enhancement = nil
        table.insert(effects, eval)
    end
    card.ability = old_ability
    card.config.center = old_center
    card.config.center_key = old_center_key
    context.extra_enhancement = nil
end

function JESTERPROJECT.get_seals(card, extra_only)
    if not card or not card.ability then return {} end
    local seals = {(SMODS.find_card('j_tjp_delusion')[1] and card.seal ~= 'Red' and 'Red') or nil}
    if not extra_only then table.insert(seals, 1, card.seal) end
    return seals
end

local oldsealdrawstepfunc = SMODS.DrawSteps.seal.func
SMODS.DrawSteps.seal.func = function(self, layer)
    local oldseal = self.seal
    if self.drawseal then self.seal = self.drawseal ~= 'none' and self.drawseal or nil end
    local g = oldsealdrawstepfunc(self, layer)
    self.seal = oldseal
    return g
    --[[
    if self.ability.quantum_seals then
        local cardseal = self.drawseal or self.seal
        local seal = G.P_SEALS[cardseal] or {}
        if type(seal.draw) == 'function' then
            seal:draw(self, layer)
        elseif cardseal then
            G.shared_seals[cardseal].role.draw_major = self
            G.shared_seals[cardseal]:draw_shader('dissolve', nil, nil, nil, self.children.center)
            if cardseal == 'Gold' then G.shared_seals[cardseal]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center) end
        end
    else
        oldsealdrawstepfunc(self, layer)
    end
    ]]
end

function JESTERPROJECT.calculate_quantum_seals(card, effects, context)
    if not card:can_calculate(context.ignore_debuff, context.remove_playing_cards) then return nil end
    context.extra_seal = true
    local old_seal = card.seal
    card.drawseal = old_seal or 'none'
    local old_ability_seal = copy_table(card.ability.seal)
    local extra_seals_list = JESTERPROJECT.get_seals(card, true)
    table.sort(extra_seals_list, function(a, b) return G.P_SEALS[a].order < G.P_SEALS[b].order end)
    for _, k in ipairs(extra_seals_list) do
        JESTERPROJECT.safe_set_seal(card, k)
        card.ability.extra_seal = k
        local eval
        if card.playing_card and (k == 'Gold' or k == 'Blue') then
            eval = {seals = JESTERPROJECT.calculate_hardcoded_seals(card, context)}
        else
            eval = {seals = card:calculate_seal(context)}
        end
        if G.P_SEALS[k].get_p_dollars then
            local p_dollars = G.P_SEALS[k]:get_p_dollars(card)
            if p_dollars ~= 0 then
                if not eval.playing_card then eval.playing_card = {} end
                eval.playing_card.p_dollars = p_dollars
            end
        end
        table.insert(effects, eval)
    end
    card.seal = old_seal
    card.drawseal = nil
    card.ability.seal = old_ability_seal
    context.extra_seal = nil
end

function JESTERPROJECT.calculate_hardcoded_seals(card, context)
    if card.seal == 'Blue' and ((context.end_of_round and context.cardarea == G.hand and context.playing_card_end_of_round and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) or context.forcetrigger) then
        return {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet, func = function()
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                    if G.GAME.last_hand_played then
                        local _planet
                        for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == G.GAME.last_hand_played then
                                _planet = v.key
                            end
                        end
                        SMODS.add_card({ key = _planet, key_append = 'blusl' })
                        G.GAME.consumeable_buffer = 0
                    end
                    return true
                end)
            }))
        end}
    end
    if card.seal == 'Gold' and ((context.main_scoring and context.cardarea == G.play) or context.forcetrigger) then
        return {dollars = 3, card = card}
    end
end

function JESTERPROJECT.safe_set_ability(self, center, dontsave)
    if not self or not center then return nil end
    local oldcenter = self.config.center
    local config
    if not dontsave then
        G.GAME.tjp_savedjokervalues = G.GAME.tjp_savedjokervalues or {}
        G.GAME.tjp_savedjokervalues[self.unique_val] = G.GAME.tjp_savedjokervalues[self.unique_val] or {}
        G.GAME.tjp_savedjokervalues[self.unique_val][oldcenter.key] = copy_table(self.ability)
        config = G.GAME.tjp_savedjokervalues[self.unique_val][center.key] or center.config
    else
        config = center.config
    end
    self.config.center = center
    for k, v in pairs(G.P_CENTERS) do
        if center == v then self.config.center_key = k end
    end
    if self.ability and oldcenter and oldcenter.config.bonus then
        self.ability.bonus = self.ability.bonus - oldcenter.config.bonus
    end
    local new_ability = {
        name = center.name,
        effect = center.effect,
        set = center.set,
        mult = config.mult or 0,
        h_mult = config.h_mult or 0,
        h_x_mult = config.h_x_mult or 0,
        h_dollars = config.h_dollars or 0,
        p_dollars = config.p_dollars or 0,
        t_mult = config.t_mult or 0,
        t_chips = config.t_chips or 0,
        x_mult = config.Xmult or config.x_mult or 1,
        h_chips = config.h_chips or 0,
        x_chips = config.x_chips or 1,
        h_x_chips = config.h_x_chips or 1,
    }
    self.ability = self.ability or {}
    for k, v in ipairs({new_ability, config}) do
        for kk, vv in pairs(v) do
            self.ability[kk] = copy_table(vv)
        end
    end
    if center.consumeable then 
        self.ability.consumeable = center.config
    else
    	self.ability.consumeable = nil
    end
    if self.ability.name == "Invisible Joker" then 
        self.ability.invis_rounds = 0
    end
    if self.ability.name == 'To Do List' then
        local _poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(k) then _poker_hands[#_poker_hands+1] = k end
        end
        local old_hand = self.ability.to_do_poker_hand
        self.ability.to_do_poker_hand = nil

        while not self.ability.to_do_poker_hand do
            self.ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.type == 'title') and 'false_to_do' or 'to_do'))
            if self.ability.to_do_poker_hand == old_hand then self.ability.to_do_poker_hand = nil end
        end
    end
    if self.ability.name == 'Caino' then 
        self.ability.caino_xmult = 1
    end
    if self.ability.name == 'Yorick' then 
        self.ability.yorick_discards = self.ability.extra.discards
    end
    if self.ability.name == 'Loyalty Card' then 
        self.ability.burnt_hand = 0
        self.ability.loyalty_remaining = self.ability.extra.every
    end
end

function JESTERPROJECT.safe_set_seal(self, _seal)
    self.seal = nil
    if _seal then
        self.seal = _seal
        self.ability.seal = {}
        for k, v in pairs(G.P_SEALS[_seal].config or {}) do
            self.ability.seal[k] = copy_table(v)
        end
    end
end

local oldeventmanageraddevent = EventManager.add_event
function EventManager:add_event(event, queue, front)
    if event:is(Event) and G.GAME then
        if G.GAME.triggered_enhancement or G.GAME.triggered_joker then
            local card, key, g
            local triggered = G.GAME.triggered_enhancement or G.GAME.triggered_joker
            for k, v in ipairs(G.I.CARD) do
                if v.unique_val == triggered[1] then
                    card, key = v, triggered[2]
                end
            end
            local oldeventfunc = event.func
            event.func = function()
                local old_ability = copy_table(card.ability)
                local old_center = card.config.center
                local old_center_key = card.config.center_key
                JESTERPROJECT.safe_set_ability(card, G.P_CENTERS[key])
                g = oldeventfunc()
                card.ability = old_ability
                card.config.center = old_center
                card.config.center_key = old_center_key
                return g
            end
        elseif G.GAME.triggered_edition then
            local card, key, g
            for k, v in ipairs(G.I.CARD) do
                if v.unique_val == G.GAME.triggered_edition[1] then
                    card, key = v, G.GAME.triggered_edition[2]
                end
            end
            local oldeventfunc = event.func
            event.func = function()
                local ed_key = key:sub(3)
                local old_edition = card.edition and copy_table(card.edition) or nil
                local cardedition = {
                    [ed_key] = true,
                    type = ed_key,
                    key = key
                }
                for k, v in pairs(G.P_CENTERS[key].config) do
                    cardedition[k] = copy_table(v)
                end
                card.edition = cardedition
                g = oldeventfunc()
                card.edition = old_edition
                return g
            end
        end
    end
    return oldeventmanageraddevent(self, event, queue, front)
end

local oldsmodsgetenhancements = SMODS.get_enhancements
function SMODS.get_enhancements(card, extra_only)
    local g = oldsmodsgetenhancements(card, extra_only)
    for _, v in ipairs(JESTERPROJECT.get_enhancements(card, true)) do
        g[v] = true
    end
    return g
end