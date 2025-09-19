--Solarvid Treant
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Enlace
	c:EnableReviveLimit()
    Link.AddProcedure(c,nil,1,2,s.lcheck)
    --  0° Destruir esta carta si un Monstruo de Enlace "Solaravalon" deja el Campo por efecto de una carta
    local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
    --  1° Invocar de Modo Especial 1 Monstruo de Enlace Planta en el Cementerio
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  2° Negar efectos de monstruos que batallen contra monstruos "Solarvid" o "Solaravalon"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(function(e) return e:GetHandler():IsLinked() end)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	--  2° Aplicar negación de efectos
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_BE_BATTLE_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetOperation(function(e) Duel.AdjustInstantly(e:GetHandler()) end)
	c:RegisterEffect(e2a)
end
s.listed_series={SET_SUNAVALON,SET_SUNVINE,0x4157}
    --  *Filtro de Materiales
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_PLANT,lc,sumtype,tp)
end
    --  *EFECTO 0°
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(SET_SUNAVALON) and c:IsType(TYPE_LINK) 
		and c:GetPreviousControler()==tp and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
    --  *EFECTO 1°
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(SET_SUNVINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if c:IsRelateToEffect(e) and c:IsFaceup() and zone>0 and ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp,zone)
		if #g>0 then
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
			if ct>0 then
				c:UpdateAttack(ct*1200)
			end
		end
	end
end
    --  *EFECTO 2°
function s.distg(e,c)
	local fid=e:GetHandler():GetFieldID()
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if fid==label then return true end
	end
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and bc and bc:IsControler(e:GetHandlerPlayer())
		and bc:IsFaceup() and bc:IsSetCard({SET_SUNAVALON,SET_SUNVINE}) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,fid)
		return true
	end
	return false
end