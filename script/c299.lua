--Yamoth, Asolador de la Fábula
--DrkayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  *Invocación por Sicronía opcional
	local synchro_proc0=Synchro.AddProcedure(c,nil,2,99,aux.FilterSummonCode(290),1,1)
	local synchro_proc1=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),1,1,aux.FilterSummonCode(290),1,1)
	synchro_proc0:SetDescription(aux.Stringid(id,0))
	synchro_proc1:SetDescription(aux.Stringid(id,1))
	--  Efecto 0: El nombre de esta carta se convierte en "Yacard, Héroe de la Fábula" en Campo o Cementerio
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e0:SetValue(291)
    c:RegisterEffect(e0)
    --  Efecto 1: Secuencia al ser Invocado por Sincronía
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RECOVER)
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
function s.eqfilter(c,tc,tp)
    return c:IsEquipSpell() and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
        and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.atkfilter(c)
	return c:HasNonZeroAttack()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c,tp)
	local b2=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return b1 or b2 end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,b2,#b2,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    --  *Evaluamos ambas condiciones nuevamente al momento de resolver
    local c=e:GetHandler()
    local b1=c:IsRelateToEffect(e) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c,tp)
	local b2=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
	local bp=e:GetLabel()==1
	local op=nil
	if not bp then
		op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})
	end
	local breakeffect=false
	if (op and op==1) or (bp and b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,5)))) then
		--	*Equipa 1 Carta Mágica de Equipo a esta carta
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g1=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,c,tp)
        local tc=g1:GetFirst()
        if tc then
            breakeffect = Duel.Equip(tp,tc,c)
        end
    end
    
	if (op and op==2) or (bp and b2 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,6)))) then
		--Cambiar el ATK/DEF a 0 y gana LP igual a el ATK de esos monstruos
		if #b2>0 then
            for tc in b2:Iter() do
                local atk=tc:GetAttack()
                --  *Cambiar el ATK/DEF a 0
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetValue(0)
                e1:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
                tc:RegisterEffect(e2)
                Duel.Recover(tp,atk,REASON_EFFECT)
                breakeffect=true
            end
		end
	end
end