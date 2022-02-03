CREATE VIEW vyuRKGetOtcForwards

AS  

SELECT  
	 derh.intFutOptTransactionHeaderId
	, intFutOptTransactionId 
	, strInternalTradeNo -- Transaction Id
	, strInstrumentType = 'Forward' COLLATE Latin1_General_CI_AS
	, strCommodityCode
	, strLocationName
	, strSellBankName = bank.strBankName COLLATE Latin1_General_CI_AS
	, strSellBankAccountNo = bankacct.strBankAccountNo COLLATE Latin1_General_CI_AS
	, strBuyBankName = buybank.strBankName COLLATE Latin1_General_CI_AS
	, strBuyBankAccountNo = buybankacct.strBankAccountNo COLLATE Latin1_General_CI_AS
	, strBuyCurrency = strFromCurrency COLLATE Latin1_General_CI_AS
	, strSellCurrency = strToCurrency COLLATE Latin1_General_CI_AS
	, strBuySell
	, dtmMaturityDate
	, dtmTradeDate = der.dtmTransactionDate
	, dblBuyAmount = dblContractAmount
	, dblSellAmount = dblMatchAmount
	, dblContractRate = CASE WHEN ISNULL(approval.strApprovalStatus, 'Approved') = 'Approved' -- No Need for Approval and Approved uses Finance Forward Rate
								THEN der.dblFinanceForwardRate -- Approved Forward Rate
								ELSE der.dblContractRate END -- Requested Forward Rate
	, strCurrencyPair = CurEx.strCurrencyExchangeRateType
	, strBaseCurrency = strFromCurrency COLLATE Latin1_General_CI_AS
	, strMatchCurrency = strToCurrency COLLATE Latin1_General_CI_AS
	, dblExchangeRate
	, strApprovalStatus = CASE WHEN ISNULL(der.intBankTransferId, 0) <> 0 THEN 'Posted' 
							ELSE CASE WHEN approval.strApprovalStatus = 'Approved' 
								THEN  'Approved and Not Posted'
								ELSE  ISNULL(approval.strApprovalStatus, 'No Need for Approval') END 
							END
								COLLATE Latin1_General_CI_AS 
	, intSubmittedById = smapprove.intSubmittedById
	, dblApprovalAmount = smapprove.dblAmount
	, dtmDueDate = smapprove.dtmDueDate
	, der.intContractHeaderId
	, der.intContractDetailId
FROM  tblRKFutOptTransaction der 
OUTER APPLY (
SELECT TOP 1 * FROM tblSMTransaction approval
	WHERE approval.intRecordId = der.intFutOptTransactionId
	ORDER BY intTransactionId DESC
) approval
OUTER APPLY (
	SELECT TOP 1 * FROM tblSMApproval appr
	WHERE appr.intTransactionId = approval.intTransactionId
	ORDER BY intApprovalId DESC
) smapprove

LEFT JOIN tblSMScreen screen
	ON approval.intScreenId = screen.intScreenId
	AND screen.strModule = 'Risk Management' 
	AND screen.strScreenName = 'Derivative Entry'
LEFT JOIN tblRKFutOptTransactionHeader derh
	ON derh.intFutOptTransactionHeaderId = der.intFutOptTransactionHeaderId
LEFT JOIN tblICCommodity com
	ON der.intCommodityId = com.intCommodityId
LEFT JOIN tblSMCompanyLocation loc 
	ON der.intLocationId = loc.intCompanyLocationId
LEFT JOIN tblCMBank bank 
	ON der.intBankId = bank.intBankId
LEFT JOIN vyuCMBankAccount AS bankacct 
	ON der.intBankAccountId = bankacct.intBankAccountId
LEFT JOIN tblCMBank buybank 
	ON der.intBuyBankId = buybank.intBankId
LEFT JOIN vyuCMBankAccount AS buybankacct 
	ON der.intBuyBankAccountId = buybankacct.intBankAccountId
LEFT JOIN tblSMCurrencyExchangeRateType AS CurEx ON der.intCurrencyExchangeRateTypeId = CurEx.intCurrencyExchangeRateTypeId

WHERE derh.strSelectedInstrumentType = 'OTC'
AND der.intInstrumentTypeId = 4 -- Forward Only