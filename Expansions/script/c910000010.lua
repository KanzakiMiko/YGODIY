local s,id,o=GetID()
local SET_GHOST_POKEMON=0x1770
function s.initial_effect(c)
	--Tribute Summon with 1 "Ghost Pokemon" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.ntcon)
	e1:SetOperation(s.ntop)
	c:RegisterEffect(e1)
	--return up to 2 banished "Ghost Pokemon" cards to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--during opponent's Main Phase, change battle position, then destroy 1 Spell/Trap
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.poscon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
end
function s.ghfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsType(TYPE_MONSTER)
end
function s.relfilter(c)
	return c:IsFaceup() and s.ghfilter(c) and c:IsReleasable()
end
function s.ntcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if minc>1 then return false end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.relfilter,1,false,1,true,c,tp,nil,false,nil)
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.relfilter,1,1,false,true,true,c,tp,nil,false,nil)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
function s.rtfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsAbleToGrave()
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_REMOVED)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_REMOVED,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_REMOVED,0,1,2,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
function s.posfilter(c)
	return c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE)
	end
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
		if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	end
end
