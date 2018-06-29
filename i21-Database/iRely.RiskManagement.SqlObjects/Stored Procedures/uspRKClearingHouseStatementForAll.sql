CREATE PROC [dbo].[uspRKClearingHouseStatementForAll] 
		@xmlParam NVARCHAR(MAX) = NULL		
AS
DECLARE @idoc INT,
		@strName nvarchar(100) = null,
		@strAccountNumber nvarchar(100) = null,
		@dtmTransactionFromDate  datetime = null,
		@dtmTransactionToDate datetime = null

IF LTRIM(RTRIM(@xmlParam)) = ''
  SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
		fieldname NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			 fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

SELECT @strName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strName'	
SELECT @strAccountNumber = [from] FROM @temp_xml_table	WHERE [fieldname] = 'strAccountNumber'
SELECT @dtmTransactionFromDate = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmTransactionFromDate'
SELECT @dtmTransactionToDate = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmTransactionToDate'

SELECT *,'Trades between ''' +Left(replace(convert(varchar(9), @dtmTransactionFromDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionFromDate, 8),9) + ''' and ''' + Left(replace(convert(varchar(9), @dtmTransactionToDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionToDate, 8),9)+'''' as strDateHeading,
@strAccountNumber strAccountNumber,@strName strBroker,isnull(@dtmTransactionFromDate,min(dtmTransactionDate) over(partition by strFutMarketName)) dtmTransactionFromDate ,isnull(@dtmTransactionToDate,max(dtmTransactionDate) over(partition by strFutMarketName)) as dtmTransactionToDate FROM 
(
SELECT strInternalTradeNo,strFutMarketName,dtmTransactionDate,Left(replace(convert(varchar(9), dtmTransactionDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmTransactionDate, 8),9) LdtmTransactionDate,
	   intNoOfContract LintNoOfContract,strFutureMonth LstrFutureMonth,dblPrice LdblPrice,
		null SdtmTransactionDate,null SintNoOfContract,null SstrFutureMonth,null SdblPrice,CASE WHEN bc.intFuturesRateType= 1 then 0 else  -isnull(bc.dblFutCommission,0) end*intNoOfContract as dblFutCommission
		
FROM tblRKFutOptTransaction t
JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell='Buy'
JOIN tblEMEntity e on e.intEntityId=t.intEntityId
JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId= t.intFutureMarketId AND t.intBrokerageAccountId=bc.intBrokerageAccountId  
WHERE  strName=ISNULL(@strName ,strName)
AND strAccountNumber = ISNULL(@strAccountNumber ,strAccountNumber)
AND convert(datetime,CONVERT(VARCHAR(10),dtmTransactionDate,110),110) between convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionFromDate,dtmTransactionDate),110),110) and  convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionToDate,dtmTransactionDate),110),110)


UNION 

SELECT strInternalTradeNo,strFutMarketName,dtmTransactionDate,null LdtmTransactionDate,null LintNoOfContract,null LstrFutureMonth,null LdblPrice,
LEFT(REPLACE(CONVERT(VARCHAR(9), dtmTransactionDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmTransactionDate, 8),9) SdtmTransactionDate,
		intNoOfContract SintNoOfContract,strFutureMonth SstrFutureMonth,dblPrice SdblPrice,CASE WHEN bc.intFuturesRateType= 1 then 0 else  -isnull(bc.dblFutCommission,0) end*intNoOfContract as dblFutCommission  
FROM tblRKFutOptTransaction t
JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell='Sell'
JOIN tblEMEntity e on e.intEntityId=t.intEntityId
JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId= t.intFutureMarketId AND t.intBrokerageAccountId=bc.intBrokerageAccountId 
WHERE  strName=ISNULL(@strName ,strName)
AND strAccountNumber = ISNULL(@strAccountNumber ,strAccountNumber)
AND convert(datetime,CONVERT(VARCHAR(10),dtmTransactionDate,110),110) between convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionFromDate,dtmTransactionDate),110),110) and  convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionToDate,dtmTransactionDate),110),110) 
)t 
GROUP BY
strInternalTradeNo
,strFutMarketName
,dtmTransactionDate
,LdtmTransactionDate
,LintNoOfContract
,LstrFutureMonth
,LdblPrice
,SdtmTransactionDate
,SintNoOfContract
,SstrFutureMonth
,SdblPrice
,dblFutCommission
ORDER BY dtmTransactionDate