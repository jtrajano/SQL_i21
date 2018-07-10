CREATE FUNCTION [dbo].[fnMBGetWeightedCostAverage]()
RETURNS @returntable TABLE
(
	intMeterReadingId INT,
	intMeterReadingDetailId INT,
	intItemId INT,
	dblCost NUMERIC(18, 6)
)
AS
BEGIN

	INSERT INTO @returntable(intMeterReadingId
		, intMeterReadingDetailId
		, intItemId
		, dblCost)
	SELECT intMeterReadingId
		, intMeterReadingDetailId
		, intItemId
		, dblCost = case when (SUM(ISNULL(dblQuantity, 0))) = 0 then 0.00 else (SUM(ISNULL(dblTotalCost, 0))) / (SUM(ISNULL(dblQuantity, 0))) end
		--, dblCost = (SUM(ISNULL(dblTotalCost, 0))) / (SUM(ISNULL(dblQuantity, 0)))
	FROM (
		SELECT MRDetail.intMeterReadingId
			, MRDetail.intMeterReadingDetailId
			, MRDetail.intItemId
			, dblUnitCost = ISNULL(ICTrans.dblCost, 0)
			, dblQuantity = ABS(ISNULL(ICTrans.dblQty, 0))
			, dblTotalCost = ISNULL(ICTrans.dblCost, 0) * ABS(ISNULL(ICTrans.dblQty, 0))
		FROM vyuMBGetMeterReadingDetail MRDetail
		LEFT JOIN tblICInventoryTransaction ICTrans ON ICTrans.intTransactionId = MRDetail.intInvoiceId
			AND ICTrans.strTransactionForm = 'Invoice'
			AND ICTrans.intItemId = MRDetail.intItemId
			AND ISNULL(ICTrans.ysnIsUnposted, 0) = 0
	) tblTransactions
	GROUP BY intMeterReadingId
		, intMeterReadingDetailId
		, intItemId

	RETURN

END
