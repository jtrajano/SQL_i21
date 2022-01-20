CREATE PROCEDURE [dbo].[uspCTLoadForwardCurrency]
	@intContractDetailId	INT
AS
	SELECT	 FC.*
	FROM tblCTContractDetail CD
	INNER JOIN (
		SELECT	  intFutOptTransactionHeaderId
				, intFutOptTransactionId
				, strInternalTradeNo
				, strFromCurrency = strBuyCurrency
				, strToCurrency = strSellCurrency
				, dtmMaturityDate
				, dtmTransactionDate = dtmTradeDate
				, dblBuyAmount
				, dblSellAmount
				, strApprovalStatus
				, intContractDetailId
				, dblContractRate
				,intConcurrencyId = 1
		FROM vyuRKGetOtcForwards
		WHERE intContractDetailId = @intContractDetailId
	) FC on FC.intContractDetailId = CD.intContractDetailId
