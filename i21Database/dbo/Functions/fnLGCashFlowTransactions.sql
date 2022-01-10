CREATE FUNCTION [dbo].[fnLGCashFlowTransactions](
	@dtmDateFrom DATETIME = NULL,
	@dtmDateTo DATETIME = NULL
)
RETURNS TABLE
AS
RETURN SELECT
	intTransactionId = L.intLoadId
	,strTransactionId = L.strLoadNumber
	,strTransactionType = CASE WHEN (L.intPurchaseSale = 2) 
							THEN 'Outbound Shipment' 
							ELSE 'Inbound Shipments' 
						END COLLATE Latin1_General_CI_AS
	,intCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)
	,dtmDate = ISNULL(L.dtmCashFlowDate, L.dtmScheduledDate)
	,dblAmount = LD.dblAmount
	,intBankAccountId = BA.intBankAccountId
	,intGLAccountId = BA.intGLAccountId
	,intCompanyLocationId = CASE WHEN (L.intPurchaseSale = 2) 
								THEN LD.intSCompanyLocationId 
								ELSE LD.intPCompanyLocationId 
							END
	,ysnPosted = ISNULL(L.ysnPosted, 0)
FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN (L.intPurchaseSale = 2) THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
	LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblCMBankAccount BA ON BA.intBankAccountId = CD.intBankAccountId
WHERE L.intShipmentType = 1
	AND L.intSourceType IN (2, 4, 5, 6)
	AND ISNULL(L.ysnCancelled, 0) = 0
	AND (@dtmDateFrom IS NULL OR ISNULL(L.dtmCashFlowDate, L.dtmScheduledDate) >= @dtmDateFrom)
	AND (@dtmDateTo IS NULL OR ISNULL(L.dtmCashFlowDate, L.dtmScheduledDate) <= @dtmDateTo)

GO