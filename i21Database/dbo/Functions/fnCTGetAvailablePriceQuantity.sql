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
