CREATE VIEW vyuRKFutOptOtcApproval

AS  

SELECT  intFutOptTransactionId 
	, derh.intFutOptTransactionHeaderId
	, strInternalTradeNo
	, strInstrumentType = CASE WHEN intInstrumentTypeId = 3 THEN 'Spot'
						WHEN intInstrumentTypeId = 4 THEN 'Forward'
						WHEN intInstrumentTypeId = 5 THEN 'Swap' END COLLATE Latin1_General_CI_AS
	, strCommodityCode
	, strLocationName
	, strBankName = bank.strBankName
	, strBankAccountNo = bankacct.strBankAccountNo
	, strBuyBankName = buybank.strBankName
	, strBuyBankAccountNo = buybankacct.strBankAccountNo
	, strBuySell
	, dtmMaturityDate
	, strCurrencyPair = CurEx.strCurrencyExchangeRateType
	, strBaseCurrency = strFromCurrency COLLATE Latin1_General_CI_AS
	, strMatchCurrency = strToCurrency COLLATE Latin1_General_CI_AS
	, dblExchangeRate
	, strApprovalStatus = approval.strApprovalStatus
	, intSubmittedById = smapprove.intSubmittedById
	, dblApprovalAmount = smapprove.dblAmount
	, dtmDueDate = smapprove.dtmDueDate
	, intApprovalEntityId = approval.intEntityId
FROM  tblSMTransaction approval
INNER JOIN tblRKFutOptTransaction der
	ON der.intFutOptTransactionId = approval.intRecordId
CROSS APPLY (
	SELECT TOP 1 * FROM tblSMApproval appr
	WHERE appr.intTransactionId = approval.intTransactionId
	AND strStatus = 'Waiting for Approval'
) smapprove

LEFT JOIN tblSMScreen screen
ON approval.intScreenId = screen.intScreenId
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

WHERE screen.strModule = 'Risk Management' 
AND screen.strScreenName = 'Derivative Entry'
AND approval.strApprovalStatus = 'Waiting for Approval'
AND derh.strSelectedInstrumentType = 'OTC'
AND der.intInstrumentTypeId = 4 -- Forward Only