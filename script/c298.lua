--Wincard, Forastero de la Fábula
--DrkayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  *Invocación por Sicronía opcional
	local synchro_proc0=Synchro.AddProcedure(c,nil,2,99,aux.FilterSummonCode(290),1,1)
	local synchro_proc1=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),1,1,aux.FilterSummonCode(290),1,1)
	synchro_proc0:SetDescription(aux.Stringid(id,0))
	synchro_proc1:SetDescription(aux.Stringid(id,1))
	--  Efecto 0: El nombre de esta carta se convierte en "Yacard, Héroe de la Fábula" en Campo o Cementerio
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e0:SetValue(290)
    c:RegisterEffect(e0)
    --  Efecto 1: Secuencia al ser Invocado por Sincronía
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.material={290}
s.listed_names={290}
s.synchro_nt_required=1
s.synchro_tuner_required=1
    --  *EFECTO 1°
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND|LOCATION_ONFIELD)
	local b1=true
	local b2=#g>0
	if chk==0 then return b1 or b2 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,1200)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND|LOCATION_ONFIELD)
	local b1=true
	local b2=#g>0
	local bp=e:GetLabel()==1
	local op=nil
	if not bp then
		op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})
	end
	local breakeffect=false
	if (op and op==1) or (bp and b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,5)))) then
		--	*Infliger daño
		Duel.Damage(1-tp,1200,REASON_EFFECT)
		breakeffect=true
	end
	if (op and op==2) or (bp and b2 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,6)))) then
		--	*Destruir cartas en el Campo
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,2,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
				breakeffect=true
			end
		end
	end
end