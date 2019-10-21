CREATE FUNCTION [dbo].[fnCTGetSequenceReceiptReturnTotal]
(
	@contractDetailId int
)
RETURNS INT
AS
BEGIN

	DECLARE @returnQty NUMERIC(18,6)

	SELECT TOP 1 @returnQty = ISNULL(dblBalance,0)
	FROM vyuCTSequenceUsageHistory
	WHERE strScreenName = 'Receipt Return'
	AND ysnDeleted = 0
	AND intContractDetailId = @contractDetailId
	ORDER BY intSequenceUsageHistoryId DESC

	RETURN @returnQty
END
