CREATE VIEW vyuRKGetOtcForwards

AS  

SELECT  
	 derh.intFutOptTransactionHeaderId
	, intFutOptTransactionId 
	, strInternalTradeNo -- Transaction Id
	, strInstrumentType = 'Forward' COLLATE Latin1_General_CI_AS
	, strCommodityCode
	, strLocationName
	, strSellBankName = bank.strBankName
	, strSellBankAccountNo = bankacct.strBankAccountNo
	, strBuyBankName = buybank.strBankName
	, strBuyBankAccountNo = buybankacct.strBankAccountNo
	, strBuyCurrency = strFromCurrency
	, strSellCurrency = strToCurrency
	, strBuySell
	, dtmMaturityDate
	, dtmTradeDate = der.dtmTransactionDate
	, dblBuyAmount = dblContractAmount
	, dblSellAmount = dblMatchAmount
	, strCurrencyPair = CurEx.strCurrencyExchangeRateType
	, strBaseCurrency = strFromCurrency COLLATE Latin1_General_CI_AS
	, strMatchCurrency = strToCurrency COLLATE Latin1_General_CI_AS
	, dblExchangeRate
	, strApprovalStatus = ISNULL(approval.strApprovalStatus, 'No Need for Approval')
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