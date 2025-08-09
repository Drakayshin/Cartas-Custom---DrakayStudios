--Dragoneidos Empíreo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    c:EnableReviveLimit()
    c:AddMustBeFusionSummoned()
    --  Materiales de Fusión: 1 monstruo "EMpíreo" + 1 Synchro, Xyz, or Link Monster
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3eb),aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK))
    --  0° Invocación auxiliar una vez por turno
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--  1° Invocar de Modo Especial Sacrificando 1 LIGHT "Empíreo"mientras tengas un "Umbral Empíreo" en tu Campo o Cementerio
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	e1:SetValue(1)
    c:RegisterEffect(e1)
    --  2° Causar daño igual al Nivel x100
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
    --  3° Invocar por Sincronía 1 monstruo "Empíreo"
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    --  4° Invocar por Sincronía
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3eb}
    --  *Efecto 0°
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- Limiter la Invocación alternativa por turno
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
    --  *Efectp 1°
function s.selfspcostfilter(c,tp,sc)
	return c:IsSetCard(0x3eb) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(6) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.selfspcon(e,c)
	if not c then return true end
	if c:IsFaceup() then return false end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,200),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.CheckReleaseGroup(tp,s.selfspcostfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.selfspcostfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if not g then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
    --  *Efecto 2°
function s.damcon(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SYNCHRO) and tc:IsSetCard(0x3eb)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	local lv=tc:GetLevel()
	e:SetLabel(lv)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(lv*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,lv*100)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
    --  *Efecto 3°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFusionSummoned()
end
    --  *Efecto 4°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned()
end
function s.matfilter(c,e,tp)
	return c:IsSetCard(0x3eb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c,mg,tp,chk)
	return c:IsType(TYPE_SYNCHRO) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0) and (not mg or Card.IsSynchroSummonable(c,nil,mg,#mg,#mg))
end
function s.rescon(exg)
	return function(sg,e,tp,mg)
		local _1,_2=aux.dncheck(sg,e,tp,mg)
		return sg:GetClassCount(Card.GetLocation)==#sg and exg:IsExists(Card.IsSynchroSummonable,1,nil,nil,sg,#sg,#sg),_2
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local exg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,nil,tp)
	local cancelcon=s.rescon(exg)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if chk==0 then return ft>1 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(mg,e,tp,1,2,cancelcon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--synchro part
	local exg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,nil,tp)
	local cancelcon=s.rescon(exg)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,2,cancelcon,1,tp,HINTMSG_SPSUMMON,cancelcon)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local syng=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,g,tp,true)
	if #syng>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local c=syng:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,c,nil,g,#g,#g)
	end
end