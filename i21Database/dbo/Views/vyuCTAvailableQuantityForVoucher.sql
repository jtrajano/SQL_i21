create view vyuCTAvailableQuantityForVoucher as

with summ as (
	select
		pf.intContractHeaderId
		,pf.intContractDetailId
		,pf.intPriceContractId
		,pf.intPriceFixationId
		,pfd.intPriceFixationDetailId
		,pfd.dblBasis
		,pfd.dblFutures
		,pfd.dblCashPrice
		,pfd.dblQuantity
	from
		tblCTPriceFixation pf
		,tblCTPriceFixationDetail pfd
	where
		pfd.intPriceFixationId = pf.intPriceFixationId
),
bill as (
	select
		intContractDetailId
		,dblQtyReceived = sum(dblQtyReceived)
	from
		tblAPBillDetail
	group by
		intContractDetailId
),
availble as
(
select
	pf.intContractHeaderId
	,pf.intContractDetailId
	,pf.intPriceContractId
	,pf.intPriceFixationId
	,pfd.intPriceFixationDetailId
	,pfd.dblBasis
	,pfd.dblFutures
	,pfd.dblCashPrice
	,pfd.dblQuantity
	,dblAccumulativeQuantity = sum(summ.dblQuantity)
	,dblVoucherQtyReceived = isnull((select dblQtyReceived from bill where intContractDetailId = pf.intContractDetailId),0.00)
from
	tblCTPriceFixation pf
	join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
	left join summ on summ.intPriceFixationDetailId <= pfd.intPriceFixationDetailId and summ.intContractDetailId = pf.intContractDetailId
group by
	pf.intContractHeaderId
	,pf.intContractDetailId
	,pf.intPriceContractId
	,pf.intPriceFixationId
	,pfd.intPriceFixationDetailId
	,pfd.dblBasis
	,pfd.dblFutures
	,pfd.dblCashPrice
	,pfd.dblQuantity
),
availablesummary as
(
select
	intContractDetailId, intPriceFixationId, intPriceFixationDetailId, dblCashPrice, dblQuantity, dblAccumulativeQuantity, dblVoucherQtyReceived, dblAvailableQuantity = dblAccumulativeQuantity - dblVoucherQtyReceived
from
	availble
)
select * from availablesummary where dblAvailableQuantity > 0
