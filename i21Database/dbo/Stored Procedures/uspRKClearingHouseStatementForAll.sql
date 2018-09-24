CREATE PROC [dbo].[uspRKClearingHouseStatementForAll] 
		 @xmlParam NVARCHAR(MAX) = NULL		
AS 

--declare @xmlParam NVARCHAR(MAX) = NULL	
--set @xmlParam=N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmTransactionFromDate</fieldname><condition>Between</condition><from>01/01/2018</from><to>09/17/2018</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter><filter><fieldname>strName</fieldname><condition>Equal To</condition><from>Marex</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>intSrCurrentUserId</fieldname><condition>Dummy</condition><from>1</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter><filter><fieldname>intSrLanguageId</fieldname><condition>Dummy</condition><from>0</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter></filters><sorts /></xmlparam>'
DECLARE @idoc INT,
		@strName nvarchar(100) = null,
		@strAccountNumber nvarchar(100) = null,
		@dtmTransactionFromDate  datetime = null,
		@dtmTransactionToDate  datetime = null
IF LTRIM(RTRIM(@xmlParam)) = ''
  SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
		id INT IDENTITY(1,1),
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

DECLARE @query NVARCHAR(MAX), 
	    @innerQuery NVARCHAR(MAX), 
		@filter NVARCHAR(MAX) = '';
DECLARE @dtmFromDate DATETIME = NULL;
DECLARE @dtmToDate DATETIME = NULL;
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50) 

SELECT @dtmFromDate = [from], @dtmToDate = [to], @condition = [condition] FROM @temp_xml_table WHERE [fieldname] = 'dtmTransactionFromDate';

IF @dtmTransactionFromDate IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
	
		SET @innerQuery = ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmTransactionDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmFromDate, 110) + ''''
		set @dtmTransactionFromDate=CONVERT(VARCHAR(10), @dtmFromDate, 110)
		set @dtmTransactionToDate=CONVERT(VARCHAR(10), @dtmFromDate, 110)
		
	END
    ELSE 
	BEGIN 
		SET @innerQuery = ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmTransactionDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmFromDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dtmToDate, 110) + ''''	
		set @dtmTransactionFromDate=CONVERT(VARCHAR(10), @dtmFromDate, 110)
		set @dtmTransactionToDate=CONVERT(VARCHAR(10), @dtmToDate, 110)
	END  
END
ELSE
BEGIN
	SET @dtmFromDate = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dtmToDate = CONVERT(VARCHAR(10), GETDATE(), 110)
	set @dtmTransactionFromDate=CONVERT(VARCHAR(10), '1/1/1900', 110)
	set @dtmTransactionToDate=CONVERT(VARCHAR(10), GETDATE(), 110)
END
--[uspRKClearingHouseStatementForAll]
SET @query = '
SELECT * 
FROM 
(
SELECT strInternalTradeNo,strFutMarketName,CONVERT(VARCHAR(10), dtmFilledDate, 110) dtmTransactionDate,Left(replace(convert(varchar(9), dtmFilledDate, 6), '' '', ''-'') + '' '' + convert(varchar(8), dtmFilledDate, 8),9) LdtmTransactionDate,
	   intNoOfContract LintNoOfContract,strFutureMonth LstrFutureMonth,dblPrice LdblPrice,
		null SdtmTransactionDate,null SintNoOfContract,null SstrFutureMonth,null SdblPrice,CASE WHEN bc.intFuturesRateType= 1 then 0 else  -isnull(bc.dblFutCommission,0) end*intNoOfContract as dblFutCommission		
FROM tblRKFutOptTransaction t
JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell=''Buy''
JOIN tblEMEntity e on e.intEntityId=t.intEntityId
JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId= t.intFutureMarketId AND t.intBrokerageAccountId=bc.intBrokerageAccountId  
WHERE  strName= case when '''+isnull(@strName,'')+''' ='''' then strName else '''+isnull(@strName,'')+''' end
AND strAccountNumber = case when '''+isnull(@strAccountNumber,'')+'''='''' then strAccountNumber else '''+isnull(@strAccountNumber,'')+''' end
AND CONVERT(VARCHAR(10), dtmFilledDate, 110) between '''+CONVERT(VARCHAR(10), @dtmTransactionFromDate, 110)+''' and '''+CONVERT(VARCHAR(10), @dtmTransactionToDate, 110)+'''

UNION 

SELECT strInternalTradeNo,strFutMarketName,CONVERT(VARCHAR(10), dtmFilledDate, 110) dtmTransactionDate,null LdtmTransactionDate,null LintNoOfContract,null LstrFutureMonth,null LdblPrice,
LEFT(REPLACE(CONVERT(VARCHAR(9), dtmFilledDate, 6), '' '', ''-'') + '' '' + convert(varchar(8), dtmFilledDate, 8),9) SdtmTransactionDate,
		intNoOfContract SintNoOfContract,strFutureMonth SstrFutureMonth,dblPrice SdblPrice,CASE WHEN bc.intFuturesRateType= 1 then 0 else  -isnull(bc.dblFutCommission,0) end*intNoOfContract as dblFutCommission  
FROM tblRKFutOptTransaction t
JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell=''Sell''
JOIN tblEMEntity e on e.intEntityId=t.intEntityId
JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId= t.intFutureMarketId AND t.intBrokerageAccountId=bc.intBrokerageAccountId 
WHERE   strName= case when '''+isnull(@strName,'')+''' ='''' then strName else '''+isnull(@strName,'')+''' end
AND strAccountNumber = case when '''+isnull(@strAccountNumber,'')+'''='''' then strAccountNumber else '''+isnull(@strAccountNumber,'')+''' end
AND CONVERT(VARCHAR(10), dtmFilledDate, 110) between '''+CONVERT(VARCHAR(10), @dtmTransactionFromDate, 110)+''' and '''+CONVERT(VARCHAR(10), @dtmTransactionToDate, 110)+'''

)t 
'

IF ISNULL(@innerQuery,'') != ''
BEGIN
	SET @query = @query +  @innerQuery
END

declare @tempTable TABLE (strItnernalTradeNo nvarchar(100),
strFutMarketName nvarchar(100),
dtmTransactionDate datetime,
LdtmTransactionDate datetime,
LintNoOfContract int,
LstrFutureMonth nvarchar(100),
LdblPrice numeric(24,10),
SdtmTransactionDate datetime,
SintNoOfContract int,
SstrFutureMonth nvarchar(100),
SdblPrice numeric(24,10),
dblFutCommission numeric(24,10))
INSERT INTO @tempTable (strItnernalTradeNo,strFutMarketName,dtmTransactionDate,LdtmTransactionDate,LintNoOfContract,LstrFutureMonth,
						LdblPrice,SdtmTransactionDate,SintNoOfContract,SstrFutureMonth,SdblPrice,dblFutCommission)
EXEC sp_executesql @query


IF Exists(select 1 from @tempTable)
BEGIN
SELECT @strAccountNumber strAccountNumber,@strName strBroker,@dtmTransactionFromDate dtmTransactionFromDate ,@dtmTransactionToDate as dtmTransactionToDate,* 
FROM @tempTable
ENd
ELSE
BEGIN
select 
@strAccountNumber strAccountNumber,@strName strBroker,@dtmTransactionFromDate dtmTransactionFromDate ,@dtmTransactionToDate as dtmTransactionToDate
END
