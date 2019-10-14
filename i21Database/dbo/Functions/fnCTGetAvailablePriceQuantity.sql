CREATE FUNCTION [dbo].[fnCTGetAvailablePriceQuantity]
(
	@intContractDetailId INT
	,@intSettleStorageId INT = 0
)
RETURNS NUMERIC(18,6)
AS
BEGIN

	DECLARE @dblAvailablePriceQty NUMERIC(18,6) = 0;
	DECLARE @dtmCreated datetime;

	if (@intSettleStorageId > 0)
	begin
		set @dtmCreated = (select dtmCreated from tblGRSettleStorage where intSettleStorageId = @intSettleStorageId);

		select
			@dblAvailablePriceQty = (case when intPricingTypeId = 1 then dblSequenceQuantity else dblPricedQuantity end) - isnull(dblSettledQuantity,0.00)
		from
		(
		select
			cd.intContractDetailId
			,cd.intPricingTypeId
			,dblSequenceQuantity = cd.dblQuantity
			,dblPricedQuantity = sum(pfd.dblQuantity)
			,dblSettledQuantity = sum(sc.dblUnits)
		from
			tblCTContractDetail cd
			left join tblCTPriceFixation pf on pf.intContractDetailId = cd.intContractDetailId
			left join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
			left join tblGRSettleContract sc on sc.intContractDetailId = cd.intContractDetailId and sc.intSettleStorageId in (
				select intSettleStorageId from tblGRSettleStorage where dtmCreated < @dtmCreated
			)
		where
			cd.intContractDetailId = @intContractDetailId
		group by
			cd.intContractDetailId
			,cd.intPricingTypeId
			,cd.dblQuantity
		) as pricedQuantity
	end
	else
	begin
		SELECT @dblAvailablePriceQty = SUM(ISNULL(b.dblQuantity,0))-- - SUM(ISNULL(b.dblQuantityAppliedAndPriced,0))
		FROM tblCTPriceFixation a
		INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationId = b.intPriceFixationId
		WHERE a.intContractDetailId = @intContractDetailId
		GROUP BY a.intContractDetailId
	end



	RETURN @dblAvailablePriceQty

END

/*
CREATE FUNCTION [dbo].[fnCTGetAvailablePriceQuantity]
(
	@intContractDetailId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN

	DECLARE @dblAvailablePriceQty NUMERIC(18,6) = 0

	SELECT @dblAvailablePriceQty = SUM(ISNULL(b.dblQuantity,0)) - SUM(ISNULL(b.dblQuantityAppliedAndPriced,0))
	FROM tblCTPriceFixation a
	INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationId = b.intPriceFixationId
	WHERE a.intContractDetailId = @intContractDetailId
	GROUP BY a.intContractDetailId

	RETURN @dblAvailablePriceQty

END
*/