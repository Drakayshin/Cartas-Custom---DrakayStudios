--Dragón de Rosa Gazania
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Invocar esta carta de Modo Especial
    local e0=Effect.CreateEffect(c)
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e0:SetType(EFFECT_TYPE_IGNITION)
    e0:SetRange(LOCATION_HAND)
    e0:SetCountLimit(1,{id,0})
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  1° Buscar 1 carta que mencione a "Dragón de la Rosa Negra"  
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY) 
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.thsp_tg)
    e1:SetOperation(s.thsp_op)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    local e1b=e1:Clone()
	e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
s.listed_names={73580471,CARD_BLACK_ROSE_DRAGON}
    --	*EFECTO 0°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardDeck(tp,2,REASON_EFFECT)~=0 then
		local oc=Duel.GetOperatedGroup():GetFirst()
		local c=e:GetHandler()
		if oc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
             -- Restricción del Extra Deck (solo Dragón o Planta)
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetTargetRange(1,0)
            e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_DRAGON|RACE_PLANT) end)
            e1:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e1,tp)
            --"Clock Lizard" check
            aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsRace(RACE_DRAGON|RACE_PLANT) end)
            --  *Reducción de Nivel Opcional
            if c:IsFaceup() then
                local max_lvl = math.min(c:GetLevel()-1,3)
                if max_lvl > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then -- "aux.Stringid(id, 0)" sería el prompt para reducir el nivel
                    local lv=Duel.AnnounceLevel(tp,1,3)
                    local e2=Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_CHANGE_LEVEL)
                    e2:SetValue(c:GetLevel()-lv)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                    c:RegisterEffect(e2)
                end
            end
		end
	end
end
    --  *EFECTO 1°
function s.thfilter(c,e,tp,rose_chk)
	return c:IsMonster() and c:ListsCode(CARD_BLACK_ROSE_DRAGON) and (c:IsAbleToHand() or (rose_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sphfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_BLACK_ROSE_DRAGON) or c:IsCode(CARD_BLACK_ROSE_DRAGON) and not c:IsCode(id)
end
function s.thsp_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rose_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sphfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,rose_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thsp_op(e,tp,eg,ep,ev,re,r,rp)
	local rose_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sphfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,rose_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return rose_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end