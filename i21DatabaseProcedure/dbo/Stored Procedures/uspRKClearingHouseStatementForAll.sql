CREATE PROC [dbo].[uspRKClearingHouseStatementForAll]
	@xmlParam NVARCHAR(MAX) = NULL

AS

DECLARE @idoc INT
	, @strName nvarchar(100) = null
	, @strAccountNumber nvarchar(100) = null
	, @dtmTransactionFromDate  datetime = null
	, @dtmTransactionToDate  datetime = null

IF LTRIM(RTRIM(@xmlParam)) = ''
BEGIN
	SET @xmlParam = NULL
END

DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	, fieldname NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, condition NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, [from] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [to] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [join] NVARCHAR(10) COLLATE Latin1_General_CI_AS
	, [begingroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [endgroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [datatype] NVARCHAR(50) COLLATE Latin1_General_CI_AS)
	
EXEC sp_xml_preparedocument @idoc OUTPUT
	, @xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
	fieldname NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, condition NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, [from] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [to] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [join] NVARCHAR(10) COLLATE Latin1_General_CI_AS
	, [begingroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [endgroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, [datatype] NVARCHAR(50) COLLATE Latin1_General_CI_AS)

SELECT @strName = [from] FROM @temp_xml_table WHERE [fieldname] = 'strName'
SELECT @strAccountNumber = [from] FROM @temp_xml_table	WHERE [fieldname] = 'strAccountNumber'
SELECT @dtmTransactionFromDate = [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmTransactionFromDate'

DECLARE @query NVARCHAR(MAX)
	, @innerQuery NVARCHAR(MAX)
	, @filter NVARCHAR(MAX) = '';
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

SELECT @dtmFromDate = [from]
	, @dtmToDate = [to]
	, @condition = [condition]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmTransactionFromDate';

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

SET @query = '
	SELECT *
	FROM (
		SELECT strInternalTradeNo
			,strFutMarketName
			,CONVERT(VARCHAR(10), dtmFilledDate, 110) dtmTransactionDate
			,(Left(replace(convert(varchar(9), dtmFilledDate, 6), '' '', ''-'') + '' '' + convert(varchar(8), dtmFilledDate, 8),9)) COLLATE Latin1_General_CI_AS LdtmTransactionDate
			,dblNoOfContract LdblNoOfContract
			,strFutureMonth LstrFutureMonth
			,dblPrice LdblPrice
			,null SdtmTransactionDate
			,null SdblNoOfContract
			,null SstrFutureMonth
			,null SdblPrice
			,dblFutCommission =(ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 2 THEN 0
															ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END) as dblFutCommission
										FROM tblRKBrokerageCommission bc
										LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
										WHERE bc.intFutureMarketId = m.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId
											and getdate() between bc.dtmEffectiveDate and ISNULL(bc.dtmEndDate,getdate())),0) * -1) * dblNoOfContract
		FROM tblRKFutOptTransaction t
		JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell=''Buy''
		JOIN tblEMEntity e on e.intEntityId=t.intEntityId
		JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
		WHERE  strName= case when '''+isnull(@strName,'')+''' ='''' then strName else '''+isnull(@strName,'')+''' end
			AND strAccountNumber = case when '''+isnull(@strAccountNumber,'')+'''='''' then strAccountNumber else '''+isnull(@strAccountNumber,'')+''' end
			AND CONVERT(VARCHAR(10), dtmFilledDate, 110) between '''+CONVERT(VARCHAR(10), @dtmTransactionFromDate, 110)+''' and '''+CONVERT(VARCHAR(10), @dtmTransactionToDate, 110)+'''

		UNION ALL SELECT strInternalTradeNo
			,strFutMarketName
			,CONVERT(VARCHAR(10), dtmFilledDate, 110) dtmTransactionDate
			,null LdtmTransactionDate
			,null LdblNoOfContract
			,null LstrFutureMonth
			,null LdblPrice
			,(LEFT(REPLACE(CONVERT(VARCHAR(9), dtmFilledDate, 6), '' '', ''-'') + '' '' + convert(varchar(8), dtmFilledDate, 8),9)) COLLATE Latin1_General_CI_AS SdtmTransactionDate
			,dblNoOfContract SdblNoOfContract
			,strFutureMonth SstrFutureMonth
			,dblPrice SdblPrice
			,dblFutCommission =(ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 2 THEN 0
															ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END) as dblFutCommission
										FROM tblRKBrokerageCommission bc
										LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
										WHERE bc.intFutureMarketId = m.intFutureMarketId and bc.intBrokerageAccountId = ba.intBrokerageAccountId
											and getdate() between bc.dtmEffectiveDate and ISNULL(bc.dtmEndDate,getdate())),0) * -1) * dblNoOfContract
		FROM tblRKFutOptTransaction t
		JOIN tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId=t.intFutureMonthId AND intSelectedInstrumentTypeId=1 AND intInstrumentTypeId=1 AND strBuySell=''Sell''
		JOIN tblEMEntity e on e.intEntityId=t.intEntityId
		JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=t.intBrokerageAccountId
		WHERE   strName= case when '''+isnull(@strName,'')+''' ='''' then strName else '''+isnull(@strName,'')+''' end
		AND strAccountNumber = case when '''+isnull(@strAccountNumber,'')+'''='''' then strAccountNumber else '''+isnull(@strAccountNumber,'')+''' end
		AND CONVERT(VARCHAR(10), dtmFilledDate, 110) between '''+CONVERT(VARCHAR(10), @dtmTransactionFromDate, 110)+''' and '''+CONVERT(VARCHAR(10), @dtmTransactionToDate, 110)+'''
)t 
'

IF ISNULL(@innerQuery,'') != ''
BEGIN
	SET @query = @query +  @innerQuery
END

DECLARE @tempTable TABLE (strItnernalTradeNo nvarchar(100) COLLATE Latin1_General_CI_AS
	, strFutMarketName nvarchar(100) COLLATE Latin1_General_CI_AS
	, dtmTransactionDate datetime
	, LdtmTransactionDate datetime
	, LdblNoOfContract numeric(24,10)
	, LstrFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS
	, LdblPrice numeric(24,10)
	, SdtmTransactionDate datetime
	, SdblNoOfContract numeric(24,10)
	, SstrFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS
	, SdblPrice numeric(24,10)
	, dblFutCommission numeric(24,10))

INSERT INTO @tempTable (strItnernalTradeNo
	, strFutMarketName
	, dtmTransactionDate
	, LdtmTransactionDate
	, LdblNoOfContract
	, LstrFutureMonth
	, LdblPrice
	, SdtmTransactionDate
	, SdblNoOfContract
	, SstrFutureMonth
	, SdblPrice
	, dblFutCommission)
EXEC sp_executesql @query


IF EXISTS(SELECT 1 FROM @tempTable)
BEGIN
	SELECT @strAccountNumber strAccountNumber
		, @strName strBroker
		, @dtmTransactionFromDate dtmTransactionFromDate
		, @dtmTransactionToDate as dtmTransactionToDate
		, *
	FROM @tempTable
END
ELSE
BEGIN
	SELECT @strAccountNumber strAccountNumber
		, @strName strBroker
		, @dtmTransactionFromDate dtmTransactionFromDate
		, @dtmTransactionToDate as dtmTransactionToDate
END
