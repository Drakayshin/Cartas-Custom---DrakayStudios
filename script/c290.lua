--Paladio de la Esperanza
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Puede ser tratado como 2 materiales para una Invocación Xyz
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e0:SetValue(1)
	e0:SetCountLimit(1,{id,0})
	e0:SetOperation(function(e,c) return c.minxyzct and c.minxyzct>=3 and c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR) end)
	c:RegisterEffect(e0)
	--  Efecto 1: Invocar de Modo Especial desde tu mano
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(Cost.Reveal(function(c) return c:IsSpell() end))
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
    c:RegisterEffect(e1)
    --  Efecto 2: Efecto añadido al Monstruo Xyz que tenga esta carta como material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
    e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL}
s.listed_series={SET_BLACK_LUSTER_SOLDIER}
    --  *Efecto 1°
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.thspfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN|CARD_DARK_MAGICIAN_GIRL) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp):GetFirst()
        if not sc then return end
        aux.ToHandOrElse(sc,tp,
        function(sc)
            return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end,
        function(sc)
             return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end,
        aux.Stringid(id,3))
    end
end
    --  *Efecto 2°
function s.attachfilter(c,tp)
	return c:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_PENDULUM) and c:IsAbleToChangeControler()
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.attachfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) then
		Duel.Overlay(c,tc)
	end
end
