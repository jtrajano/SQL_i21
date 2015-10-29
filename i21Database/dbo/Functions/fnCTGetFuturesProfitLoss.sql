CREATE FUNCTION [dbo].[fnCTGetFuturesProfitLoss]
(
	@intContractDetailId	INT

)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE @dblProfitLoss NUMERIC(18,6)
	
	SELECT	@dblProfitLoss	=
			SUM	(
					CASE	WHEN	TN.strBuySell = 'Sell' 
							THEN	(ISNULL(CS.intHedgedLots,0) + ISNULL(CS.dblAssignedLots,0))*TN.dblPrice*MA.dblContractSize 
							ELSE	(ISNULL(CS.intHedgedLots,0) + ISNULL(CS.dblAssignedLots,0))*TN.dblPrice*MA.dblContractSize*-1
					END
				)
	FROM	tblRKAssignFuturesToContractSummary CS
	JOIN	tblRKFutOptTransaction TN ON TN.intFutOptTransactionId = CS.intFutOptTransactionId
	JOIN	tblRKFutureMarket MA ON MA.intFutureMarketId = TN.intFutureMarketId
	WHERE	CS.intContractDetailId = @intContractDetailId
	
	RETURN @dblProfitLoss
END