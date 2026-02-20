--Fragancia de Rosa Negra
--DrakayStudios - Asesoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x20)  -- Contador de Planta
	c:SetCounterLimit(0x20,5)    -- Limite de Contandores de Planta en esta carta
	--  0° Activación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--  0a° Añadir Contador de Planta
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0a:SetProperty(EFFECT_FLAG_DELAY)
	e0a:SetRange(LOCATION_SZONE)
	e0a:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(s.spcfilter,1,nil,tp) end)
	e0a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():AddCounter(0x20,1) end)
	c:RegisterEffect(e0a)
	--  0b° Evitar destrucción
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0b:SetRange(LOCATION_SZONE)
	e0b:SetTargetRange(LOCATION_SZONE,0)
	e0b:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
	e0b:SetValue(s.indvalue)
	c:RegisterEffect(e0b)
	--	1° Reducir ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetCounter(0x20)>=1 end)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--	2° Añadir 1 carta a la mano desde el Cemeterio o destierro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1}) -- HOPT distinto para el tercer efecto
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetCounter(0x20)>=2 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --	Effect 3: 3+ Counters (Burn)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetCounter(0x20)>=3 end)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
    c:RegisterEffect(e3)
	--	Effect 4: 4+ Counters (Piercing)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,3}) -- HOPT distinto para el segundo efecto
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetCounter(0x20)>=5 end)
	e4:SetTarget(s.piercetg)
	e4:SetOperation(s.pierceop)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x20}
s.listed_names={CARD_BLACK_ROSE_DRAGON}
    --  *EFECTO 0a°
function s.spcfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsRace(RACE_PLANT|RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
    --  *EFECTO 0b° (Evitar destrucción)
function s.indvalue(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c)
end
	--	*EFECTO 1°
function s.val(e,c)
	return e:GetHandler():GetCounter(0x20) * -200
end
	--	*EFECTO 2°	(Añadir 1 carta desde el Cementerio o destierro)
function s.thfilter(c)
	return c:IsAbleToHand() and not c:IsCode(id) and c:ListsCode(CARD_BLACK_ROSE_DRAGON) and c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
    --  *EFECTO 3° (Infliger daño)
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetHandler():GetCounter(0x20)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local ct=c:GetCounter(0x20)
		if ct>0 then
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
    --  *EFETO 4° (Daño por penetración)
function s.piercetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.pierceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--  *Aplicando la regla de clonado guardada (e1, e1a...) aunque aquí solo es un efecto.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3208) -- Descripción genérica "Piercing"
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end