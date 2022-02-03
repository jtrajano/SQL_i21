Create PROCEDURE [dbo].[uspCTLoadTradeFinanceHistory]
	@intContractDetailId	INT
AS
	SELECT *
	FROM [tblTRFTradeFinanceHistory]
	WHERE intTransactionDetailId = @intContractDetailId



