--Doble Fuerza Subterror
--DrakayStudios
--Codigo a petición de Hugo Castro
local s,id=GetID()
function s.initial_effect(c)
	-- Activar + añadir/colocar
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.thsettg)
	e0:SetOperation(s.thsetop)
	c:RegisterEffect(e0)
	-- Material Xyz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(id)
	e2:SetValue(4)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
    --Limite de Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(s.synlimit)
	c:RegisterEffect(e3)
end
s.listed_names={5697558}
s.listed_series={0xed}
    -- Añadir/Colocar
function s.thsetfilter(c)
	return c:IsCode(5697558) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thsettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thsetfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thsetop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.thsetfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc) return sc:IsSSetable() end,
		function(sc) Duel.SSet(tp,sc) end,
		aux.Stringid(id,2)
	)
end
    -- Limite de material
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xed)
end