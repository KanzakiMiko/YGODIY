local s,id,o=GetID()
local SET_GHOST_POKEMON=0x1770
function s.initial_effect(c)
	--Special Summon itself from hand/GY by Tributing 2 "Ghost Pokemon" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--banish it if it leaves the field after being Summoned this way
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.rmcon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	--opponent cannot activate GY card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.aclimit)
	c:RegisterEffect(e3)
	--opponent cannot banish cards
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetTarget(s.rmlimit)
	c:RegisterEffect(e4)
	--temporarily banish 1 card, then optionally Special Summon a "Ghost Pokemon" monster from GY
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMING_MAIN_END)
	e5:SetCountLimit(1,id+100)
	e5:SetCondition(s.tmpcon)
	e5:SetTarget(s.tmptg)
	e5:SetOperation(s.tmpop)
	c:RegisterEffect(e5)
end
function s.ghfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsType(TYPE_MONSTER)
end
function s.relfilter(c)
	return c:IsFaceup() and s.ghfilter(c) and c:IsReleasable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.CheckReleaseGroup(tp,s.relfilter,2,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.relfilter,2,2,nil)
	Duel.Release(g,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.rmcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
function s.rmlimit(e,c,tp,r)
	return true
end
function s.tmpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.tmpfilter(c)
	return c:IsAbleToRemove()
end
function s.tmptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.tmpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tmpfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.tmpfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return s.ghfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tmpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffect(id)>0 then
		Duel.ReturnToField(tc)
	end
end
