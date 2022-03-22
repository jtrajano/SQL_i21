CREATE PROCEDURE [dbo].[uspCTLoadForwardCurrency]
	@intContractDetailId	INT
AS
	SELECT	 FC.*
	FROM tblCTContractDetail CD
	INNER JOIN (
		SELECT	  FD.intFutOptTransactionHeaderId
				, FD.intFutOptTransactionId
				, FD.strInternalTradeNo
				, strFromCurrency = FD.strBuyCurrency
				, strToCurrency = FD.strSellCurrency
				, FD.dtmMaturityDate
				, dtmTransactionDate = FD.dtmTradeDate
				, FD.dblBuyAmount
				, FD.dblSellAmount
				, FD.strApprovalStatus
				, FD.intContractDetailId
				, FD.dblContractRate
				, O.strOrderType
				, der.dblLimitRate
				, der.dtmMarketDate
				, der.ysnGTC
				, intConcurrencyId = 1
		FROM vyuRKGetOtcForwards FD
		INNER JOIN tblRKFutOptTransaction der on der.intFutOptTransactionId = FD.intFutOptTransactionId
		LEFT JOIN tblCTOrderTypeFX O on O.intOrderTypeId = der.intOrderTypeId
		WHERE FD.intContractDetailId = @intContractDetailId
	) FC on FC.intContractDetailId = CD.intContractDetailId
