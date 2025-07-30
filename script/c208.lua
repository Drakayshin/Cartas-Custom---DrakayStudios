--Renacimiento de Ojos Rojos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Invocar por Ritual
	Ritual.AddProcEqual{handler=c,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop,extratg=s.extratg,stage2=s.stage2,extratg1}
end
s.listed_series={SET_RED_EYES}
s.listed_names={19025379,207}
function s.ritualfil(c)
	return (c:IsCode(207) or c:IsCode(19025379)) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_RED_EYES) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	else
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil):Filter(aux.nvfilter,nil)
	end
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE|LOCATION_REMOVED):Filter(Card.IsSetCard,nil,SET_RED_EYES)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
    --  1° El Monstruo Riitual Invocado de Modo Especial por este efecto gana lo siguientes efectos
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--  *Efecto 1 (0° Negar los efectos de monstruos que batallen contra esta carta)
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_BATTLE_START)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(s.atkop)
    tc:RegisterEffect(e0,true)
    --  *Efecto 2 (1° Destruir todos los monstruos del adversario y causar 800 puntos de daño por cada uno)
    if not tc:IsOriginalCodeRule(207,19025379) then return end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local ct=Duel.Destroy(g,REASON_EFFECT)
        if ct~=0 then
            Duel.BreakEffect()
            Duel.Damage(1-tp,ct*700,REASON_EFFECT)
        end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e2)
	end
end
function s.extratg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*700)
end