﻿-- TO DO: Temp view only, to be deleted
CREATE VIEW [dbo].[vyuCMRKDerivativesForCommissionPosting]
   
AS  

SELECT 
	intTransactionId = intFutOptTransactionId
	,strMatchNo  = NULL
	,strInternalTradeNo
	,strInstrumentType
	,fm.strFutMarketName
	,c.strCurrency
	,strLocationName
	,strBrokerTradeNo
	,strBrokerageAccount
	,ot.intBrokerageAccountId
	,strSalespersonId
	,strBuySell
	,dblContracts = ABS(ot.dblGetNoOfContract)
	,strOptionMonth = ot.strOptionMonthYear
	,strFutureMonth
	,dtmFilledDate
	,strStatus
	,strRateType = ot.strCommissionRateType
	,dblCommissionRate = ot.dblBrokerageRate
	,dblCommission 
	,ysnCommissionExempt
	,ysnCommissionOverride
	,ysnPosted
	--,intLFutOptTransactionId = CASE WHEN strBuySell = 'Buy' THEN intFutOptTransactionId ELSE NULL END
	--,intSFutOptTransactionId = CASE WHEN strBuySell = 'Sell' THEN intFutOptTransactionId ELSE NULL END
FROM vyuRKFutOptTransaction ot
	JOIN tblRKFutureMarket fm ON fm.intFutureMarketId=ot.intFutureMarketId AND ot.intInstrumentTypeId=1 AND ot.strStatus='Filled'
	JOIN tblSMCurrency c ON c.intCurrencyID=fm.intCurrencyId
	LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
	LEFT JOIN tblRKBrokerageAccount ba ON ot.intBrokerageAccountId = ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId
WHERE intSelectedInstrumentTypeId IN(1,3) AND  ot.intInstrumentTypeId = 1
AND ysnPosted = 0
AND strCommissionRateType = 'Half-turn'



UNION all

SELECT 
	A.intMatchFuturesPSHeaderId
	,strMatchNo = A.intMatchNo
	,strInternalTradeNo = ''
	,strInstrumentType  = ''
	,FM.strFutMarketName
	,C.strCurrency
	,L.strLocationName
	,strBrokerTradeNo = ''
	,strBrokerageAccount = BA.strAccountNumber
	,BA.intBrokerageAccountId
	,strName
	,strBuySell  = NULL
	,dblMatchQty = sum(dblMatchQty)
	,strOptionMonth = NULL
	,strFutureMonth
	,dtmFilledDate = NULL
	,strStatus = NULL
	, strRateType = Lng.strCommissionRateType
	, dblCommissionRate = NULL
	, dblCommission = sum(Lng.dblLongCommission + Shrt.dblShortCommission)
	, ysnCommissionExempt = NULL
	, ysnCommissionOverride = NULL
	, Lng.ysnPosted
	--, AD.intLFutOptTransactionId
	--, AD.intSFutOptTransactionId
FROM tblRKMatchFuturesPSDetail AD
INNER JOIN tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId
INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = A.intFutureMarketId
INNER JOIN tblRKFuturesMonth F ON F.intFutureMonthId = A.intFutureMonthId
INNER JOIN tblSMCurrency C ON C.intCurrencyID = FM.intCurrencyId
INNER JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = A.intCompanyLocationId
INNER JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = A.intBrokerageAccountId
INNER JOIN tblRKTradersbyBrokersAccountMapping T ON T.intBrokerageAccountId = BA.intBrokerageAccountId
INNER JOIN tblEMEntity E ON E.intEntityId = T.intEntitySalespersonId
CROSS APPLY (
	select
	
		case when der.ysnCommissionExempt = 1 then 0
			when der.ysnCommissionOverride = 1 then (der.dblCommission / der.dblNoOfContract) * AD.dblMatchQty
			else (AD.dblMatchQty * der.dblBrokerageRate) * -1
		end as dblLongCommission
		,der.strCommissionRateType
		,der.dblBrokerageRate
		,der.ysnPosted
	from
	tblRKFutOptTransaction der
	where der.intFutOptTransactionId = AD.intLFutOptTransactionId
	
) Lng
CROSS APPLY (
	select
	
		case when der.ysnCommissionExempt = 1 then 0
			when der.ysnCommissionOverride = 1 then (der.dblCommission / der.dblNoOfContract) * AD.dblMatchQty
			else (AD.dblMatchQty * der.dblBrokerageRate) * -1
		end as dblShortCommission
		,der.strCommissionRateType
		,der.dblBrokerageRate
		,der.ysnPosted
	from
	tblRKFutOptTransaction der
	where der.intFutOptTransactionId = AD.intSFutOptTransactionId
	
) Shrt
WHERE A.strType = 'Realize'
AND Lng.strCommissionRateType = 'Round-turn'
AND Lng.ysnPosted = 0
GROUP BY
	A.intMatchFuturesPSHeaderId
	,A.intMatchNo
	,FM.strFutMarketName
	,C.strCurrency
	,L.strLocationName
	,BA.strAccountNumber
	,BA.intBrokerageAccountId
	,strName
	,strFutureMonth
	,Lng.strCommissionRateType
	,Lng.ysnPosted
