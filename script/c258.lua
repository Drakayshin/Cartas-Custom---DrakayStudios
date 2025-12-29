--Anotherverse Zenith
--DrakayStudios - Asesoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--  *Invocación de Fusión
	--  "Anotherverse Dragon" + 1 Monstruo de Fusión o Sincronía + 1 Monstruo Xyz o de Enlace
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,47484352,s.matfilter1,s.matfilter2)
	--  *Restricción: "Debe ser primero Invocado por Fusión"
	c:AddMustFirstBeFusionSummoned()
	--  *Solo puedes controlar 1 "Anotherverse Zenith"
	c:SetUniqueOnField(1,0,id)
	--  *No puede ser usado como material de Fusión, Sincronía, Xyz o Enlace
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e0b)
	local e0c=e0:Clone()
	e0c:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e0c)
	--  1° Inmune a efectos activos del adversario (si fue Invocado por Fusión)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e1)
	--  2° Efecto de Ilusión: ninguno puede ser destruido en batalla
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c==e:GetHandler() or c==e:GetHandler():GetBattleTarget() end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--  3° Bloqueo de activación según materiales usados
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.aclimit)
	c:RegisterEffect(e3)
	--  4° Al final del Damage Step: desterrar e infligir daño
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	--  5° Flotante: Invocar a Anotherverse Dragon si deja el campo
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={47484352}
    --  *Filtros de Materiales
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION|TYPE_SYNCHRO,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsType(TYPE_XYZ|TYPE_LINK,fc,sumtype,tp)
end
    --  *EFECTO 3° Lógica de Bloqueo de Activación
function s.aclimit(e,re,tp)
	local c=e:GetHandler()
	if not re:IsMonsterEffect() or not c:GetMaterial() then return false end
	local mt=c:GetMaterial()
	local typ=0
	local tc=mt:GetFirst()
	while tc do
		typ=typ|tc:GetType()
		tc=mt:GetNext()
	end
	return re:GetHandler():IsType(typ&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK))
end
    --  *EFECT0 4° Desterrar y causar Daño
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() and Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)>0 then
        local val=0
        -- Determinamos el valor basado en el tipo de monstruo
        if bc:IsType(TYPE_LINK) then
            val=bc:GetLink()*1000
        elseif bc:IsType(TYPE_XYZ) then
            val=bc:GetRank()*500
        else
            val=bc:GetLevel()*500
        end
        if val>0 then
            Duel.Damage(1-tp,val,REASON_EFFECT)
        end
    end
end
    --  *EFECTO 5° Lógica de Invocación Especial al dejar el campo
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp
end
function s.spfilter(c,e,tp)
	return (c:IsCode(47484352) or (c:IsRace(RACE_ILLUSION) and not c:IsCode(id))) 
	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOACTION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end