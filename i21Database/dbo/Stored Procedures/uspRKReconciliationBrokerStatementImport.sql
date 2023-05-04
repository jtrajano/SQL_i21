CREATE PROCEDURE uspRKReconciliationBrokerStatementImport
	@dtmFilledDate DATETIME
	, @intFutureMarketId INT
	, @intCommodityId INT
	, @intBrokerId INT
	, @intBorkerageAccountId INT = NULL
	, @intReconciliationBrokerStatementHeaderIdIn INT = 0
	, @intReconciliationBrokerStatementHeaderIdOut INT OUT
	, @strStatus NVARCHAR(50) OUT
	, @intUserId INT

AS

BEGIN TRY
	DECLARE @strDATETIMEFormat NVARCHAR(50)
		, @ConvertYear INT
		, @ErrMsg NVARCHAR(MAX)
		, @strFutMarketName NVARCHAR(50)
		, @strCommodityCode NVARCHAR(50)
		, @strName NVARCHAR(50)
		, @strAccountNumber NVARCHAR(50)
		, @intDerivativeEntryId INT
	
	SELECT @strFutMarketName = strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = @intFutureMarketId
	SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
	SELECT @strName = strName FROM tblEMEntity WHERE intEntityId = @intBrokerId
	SELECT @strAccountNumber = strAccountNumber FROM tblRKBrokerageAccount WHERE intBrokerageAccountId = @intBorkerageAccountId
	SELECT @strDATETIMEFormat = strDateTimeFormat FROM tblRKCompanyPreference
	
	IF (@strDATETIMEFormat = 'MM DD YYYY HH:MI' OR @strDATETIMEFormat = 'YYYY MM DD HH:MI')
		SET @ConvertYear = 101
	ELSE IF (@strDATETIMEFormat = 'DD MM YYYY HH:MI' OR @strDATETIMEFormat = 'YYYY DD MM HH:MI')
		SET @ConvertYear = 103
	
	DECLARE @ImportedRec TABLE (ImportId INT IDENTITY
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutMarketName NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
		, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strBuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblNoOfContract NUMERIC(24, 10)
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		, dblPrice NUMERIC(24, 10)
		, dtmFilledDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL)

	DECLARE @ImportedRec2 TABLE (ImportId INT IDENTITY
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutMarketName NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
		, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strBuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblNoOfContract NUMERIC(24, 10)
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		, dblPrice NUMERIC(24, 10)
		, dtmFilledDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL)
	
	DECLARE @tblTransRec TABLE (Id INT IDENTITY
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutMarketName NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
		, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strBuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblNoOfContract NUMERIC(24, 20)
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		, dblPrice NUMERIC(24, 20)
		, dtmFilledDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL)

	DECLARE @tblTransRec2 TABLE (Id INT IDENTITY
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutMarketName NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
		, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strBuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblNoOfContract NUMERIC(24, 20)
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		, dblPrice NUMERIC(24, 20)
		, dtmFilledDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL)
	
	DECLARE @tblFinalRec TABLE (ImportId INT
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strAccountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutMarketName NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
		, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strBuySell NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblNoOfContract NUMERIC(24, 20)
		, strFutureMonth NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
		, dblPrice NUMERIC(24, 20)
		, dtmFilledDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL)

	--Invalid Filled Date
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract = SUM(dblNoOfContract)
		, strFutureMonth = REPLACE(strFutureMonth, '-', ' ')
		, dblPrice
		, dtmFilledDate = REPLACE(strFilledDate, '-', '/')
		, NULL
		, 'No derivative entries for this filled date '+ CONVERT(VARCHAR(24), CONVERT(DATE,@dtmFilledDate), 113) + ' matched in the file.'
	FROM tblRKReconciliationBrokerStatementImport
	WHERE strFutMarketName = @strFutMarketName
		AND strCommodityCode = @strCommodityCode
		AND strName = @strName
		AND strAccountNumber = CASE WHEN ISNULL(@strAccountNumber, '') = '' THEN strAccountNumber ELSE @strAccountNumber END
		AND CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(strFilledDate, '-' , '/'), @ConvertYear)), @ConvertYear) <> CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(@dtmFilledDate, '-', '/'), @ConvertYear)), @ConvertYear)
	GROUP BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, strFilledDate
	ORDER BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
	
	INSERT INTO @ImportedRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate)
	SELECT strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract = SUM(dblNoOfContract)
		, strFutureMonth = REPLACE(strFutureMonth, '-', ' ')
		, dblPrice
		, dtmFilledDate = REPLACE(strFilledDate, '-', '/')
	FROM tblRKReconciliationBrokerStatementImport
	WHERE strFutMarketName = @strFutMarketName
		AND strCommodityCode = @strCommodityCode
		AND strName = @strName
		AND strAccountNumber = CASE WHEN ISNULL(@strAccountNumber, '') = '' THEN strAccountNumber ELSE @strAccountNumber END
		AND CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(strFilledDate, '-' , '/'), @ConvertYear)), @ConvertYear) = CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(@dtmFilledDate, '-', '/'), @ConvertYear)), @ConvertYear)
	GROUP BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, strFilledDate
	ORDER BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate

	INSERT INTO @ImportedRec2 (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate)
	SELECT strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract = SUM(dblNoOfContract)
		, strFutureMonth = REPLACE(strFutureMonth, '-', ' ')
		, dblPrice
		, dtmFilledDate = REPLACE(strFilledDate, '-', '/')
	FROM tblRKReconciliationBrokerStatementImport
	WHERE CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(strFilledDate, '-' , '/'), @ConvertYear)), @ConvertYear) = CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(@dtmFilledDate, '-', '/'), @ConvertYear)), @ConvertYear)
	GROUP BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, strFilledDate
	ORDER BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
	
	INSERT INTO @tblTransRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate)
	SELECT strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract = SUM(dblNoOfContract)
		, strFutureMonth
		, dblPrice
		, dtmFilledDate = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
	FROM (
		SELECT e.strName
			, strAccountNumber
			, fm.strFutMarketName
			, strInstrumentType = CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures'
										WHEN f.intInstrumentTypeId = 2 THEN 'Options' END
			, strCommodityCode
			, l.strLocationName
			, en.strName strSalesPersionId
			, strCurrency
			, strBrokerTradeNo
			, strBuySell
			, dblNoOfContract
			, fmon.strFutureMonth
			, dblPrice
			, strReference
			, strStatus
			, dtmFilledDate
		FROM tblRKFutOptTransaction f
		JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		JOIN tblRKBrokerageAccount ba ON ba.intBrokerageAccountId = f.intBrokerageAccountId
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = f.intFutureMarketId
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = f.intLocationId
		JOIN tblSMCurrency cur ON cur.intCurrencyID = f.intCurrencyId
		JOIN tblEMEntity en ON en.intEntityId = intTraderId
		JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = f.intFutureMonthId
		WHERE f.intFutureMarketId = @intFutureMarketId
			AND f.intCommodityId = @intCommodityId
			AND f.intEntityId = @intBrokerId
			AND CONVERT(NVARCHAR, f.dtmFilledDate, @ConvertYear) = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
			AND f.intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId, 0) = 0 THEN f.intBrokerageAccountId ELSE @intBorkerageAccountId END
			AND ISNULL(f.ysnFreezed, 0) = 0
	) t
	GROUP BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
	ORDER BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate

	INSERT INTO @tblTransRec2 (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate)
	SELECT strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract = SUM(dblNoOfContract)
		, strFutureMonth
		, dblPrice
		, dtmFilledDate = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
	FROM (
		SELECT e.strName
			, strAccountNumber
			, fm.strFutMarketName
			, strInstrumentType = CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures'
										WHEN f.intInstrumentTypeId = 2 THEN 'Options' END
			, strCommodityCode
			, l.strLocationName
			, en.strName strSalesPersionId
			, strCurrency
			, strBrokerTradeNo
			, strBuySell
			, dblNoOfContract
			, fmon.strFutureMonth
			, dblPrice
			, strReference
			, strStatus
			, dtmFilledDate
		FROM tblRKFutOptTransaction f
		JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		JOIN tblRKBrokerageAccount ba ON ba.intBrokerageAccountId = f.intBrokerageAccountId
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = f.intFutureMarketId
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = f.intLocationId
		JOIN tblSMCurrency cur ON cur.intCurrencyID = f.intCurrencyId
		JOIN tblEMEntity en ON en.intEntityId = intTraderId
		JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = f.intFutureMonthId
		WHERE CONVERT(NVARCHAR, f.dtmFilledDate, @ConvertYear) = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
			AND ISNULL(f.ysnFreezed, 0) = 0
	) t
	GROUP BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
	ORDER BY strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, strFutureMonth
		, dblPrice
		, dtmFilledDate

	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, t.dblNoOfContract
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Success'
	FROM @ImportedRec t
	JOIN @tblTransRec t1 ON t.strName = t1.strName
		AND t.strAccountNumber = t1.strAccountNumber 
		AND t.strFutMarketName = t1.strFutMarketName 
		AND t.strCommodityCode = t1.strCommodityCode 
		AND t.strBuySell = t1.strBuySell 
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
		AND t.dblPrice = t1.dblPrice 
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
							AND t.strAccountNumber = t1.strAccountNumber 
							AND t.strFutMarketName = t1.strFutMarketName 
							AND t.strCommodityCode = t1.strCommodityCode 
							AND t.strBuySell = t1.strBuySell 
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
							AND t.dblPrice = t1.dblPrice 
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
					AND t.strAccountNumber = t1.strAccountNumber 
					AND t.strFutMarketName = t1.strFutMarketName 
					AND t.strCommodityCode = t1.strCommodityCode 
					AND t.strBuySell = t1.strBuySell 
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	WHERE CONVERT(DATETIME, '1 ' + t.strFutureMonth) NOT IN (SELECT CONVERT(DATETIME, '1 ' + t1.strFutureMonth) FROM @tblTransRec t1)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	WHERE CONVERT(DATETIME, '1 ' + t.strFutureMonth) NOT IN (SELECT CONVERT(DATETIME, '1 ' + t1.strFutureMonth) FROM @ImportedRec t1)
	
	DELETE FROM @ImportedRec WHERE CONVERT(DATETIME, '1 ' + strFutureMonth) NOT IN (SELECT CONVERT(DATETIME, '1 ' + t1.strFutureMonth) FROM @tblTransRec t1)
	DELETE FROM @tblTransRec WHERE CONVERT(DATETIME, '1 ' + strFutureMonth) NOT IN (SELECT CONVERT(DATETIME, '1 ' + t1.strFutureMonth) FROM @ImportedRec t1)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0) - ISNULL(t1.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t1.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, (ABS(ISNULL(t.dblNoOfContract, 0) - ISNULL(t1.dblNoOfContract, 0)))) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0) - ISNULL(t1.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has: ' + CONVERT(NVARCHAR, ISNULL(t1.dblNoOfContract, 0)) + ' and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, (ABS(ISNULL(t1.dblNoOfContract, 0) - ISNULL(t.dblNoOfContract, 0)))) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
							AND t.dblPrice = t1.dblPrice
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
							AND t.dblPrice = t1.dblPrice
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.ImportId FROM @tblTransRec t
				LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND t.dblPrice = t1.dblPrice
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.ImportId FROM @tblTransRec t
				LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblPrice = t1.dblPrice
		AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND t.dblPrice = t1.dblPrice
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
		AND t.dblPrice = t1.dblPrice
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
							AND t.dblPrice = t1.dblPrice)
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND t.dblPrice = t1.dblPrice)

	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth))
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND t.dblPrice = t1.dblPrice
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
		AND t.dblPrice = t1.dblPrice
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND t.dblPrice = t1.dblPrice)
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND t.dblPrice = t1.dblPrice)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.strBuySell = t1.strBuySell
		AND t.dblNoOfContract = t1.dblNoOfContract
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.strBuySell = t1.strBuySell
							AND t.dblNoOfContract = t1.dblNoOfContract)
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.strBuySell = t1.strBuySell
					AND t.dblNoOfContract = t1.dblNoOfContract)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblPrice = t1.dblPrice
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblPrice = t1.dblPrice
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.dblPrice = t1.dblPrice)
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.dblPrice = t1.dblPrice)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.Id FROM @ImportedRec t
						LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth))
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.ImportId FROM @tblTransRec t
				LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)) 
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ISNULL(t.dblNoOfContract, 0)
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + ' and i21 has: 0 . Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	LEFT JOIN @tblTransRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t
	LEFT JOIN @ImportedRec t1 ON t.strName = t1.strName
	WHERE t.strAccountNumber = t1.strAccountNumber
		AND t.strFutMarketName = t1.strFutMarketName
		AND t.strCommodityCode = t1.strCommodityCode
		AND t.dblNoOfContract = t1.dblNoOfContract
	
	DELETE FROM @ImportedRec
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON t.strName = t1.strName
						WHERE t.strAccountNumber = t1.strAccountNumber
							AND t.strFutMarketName = t1.strFutMarketName
							AND t.strCommodityCode = t1.strCommodityCode
							AND t.dblNoOfContract = t1.dblNoOfContract)
	
	DELETE FROM @tblTransRec
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON t.strName = t1.strName
				WHERE t.strAccountNumber = t1.strAccountNumber
					AND t.strFutMarketName = t1.strFutMarketName
					AND t.strCommodityCode = t1.strCommodityCode
					AND t.dblNoOfContract = t1.dblNoOfContract)
	
	INSERT INTO @tblFinalRec (strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, ImportId
		, strStatus)
	SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.ImportId
		, 'Contract mismatch. i21 has : 0 AND Broker statement has : ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @ImportedRec t
	
	UNION ALL SELECT t.strName
		, t.strAccountNumber
		, t.strFutMarketName
		, t.strCommodityCode
		, t.strBuySell
		, dblNoOfContract = ABS(ISNULL(t.dblNoOfContract, 0))
		, t.strFutureMonth
		, t.dblPrice
		, t.dtmFilledDate
		, t.Id
		, 'Contract mismatch. Broker statement has : 0 and i21 has: ' + CONVERT(NVARCHAR, ISNULL(t.dblNoOfContract, 0)) + '. Difference : ' + CONVERT(NVARCHAR, t.dblNoOfContract) + ' '
	FROM @tblTransRec t

	DELETE FROM @ImportedRec
	DELETE FROM @tblTransRec
	
	-- Invalid Future Market, Commodity, Broker or Broker Account	
	IF NOT EXISTS(SELECT 1 FROM @tblFinalRec WHERE strStatus = 'Success')
	BEGIN
		INSERT INTO @tblFinalRec (strName
			, strAccountNumber
			, strFutMarketName
			, strCommodityCode
			, strBuySell
			, dblNoOfContract
			, strFutureMonth
			, dblPrice
			, dtmFilledDate
			, ImportId
			, strStatus)
		SELECT t1.strName
			, t1.strAccountNumber
			, t1.strFutMarketName
			, t1.strCommodityCode
			, t.strBuySell
			, t.dblNoOfContract
			, t.strFutureMonth
			, t.dblPrice
			, t.dtmFilledDate
			, t.ImportId
			, 'Invalid Future Market, Commodity, Broker or Broker Account'
		FROM @ImportedRec2 t
		JOIN @tblTransRec2 t1 ON t.strBuySell = t1.strBuySell 
			AND t.dblNoOfContract = t1.dblNoOfContract
			AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
			AND t.dblPrice = t1.dblPrice 
			AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
		WHERE (t1.strName != @strName
			OR t1.strAccountNumber != @strAccountNumber
			OR t1.strFutMarketName != @strFutMarketName
			OR t1.strCommodityCode != @strCommodityCode)
	END

	DELETE FROM @ImportedRec2
	WHERE ImportId IN (SELECT t1.ImportId FROM @ImportedRec t1
						JOIN @tblFinalRec t ON (t.strName != @strName
							OR t.strAccountNumber != @strAccountNumber
							OR t.strFutMarketName != @strFutMarketName
							OR t.strCommodityCode != @strCommodityCode) 
							AND t.strBuySell = t1.strBuySell 
							AND t.dblNoOfContract = t1.dblNoOfContract
							AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth) 
							AND t.dblPrice = t1.dblPrice 
							AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))
	
	DELETE FROM @tblTransRec2
	WHERE Id IN (SELECT t1.Id FROM @tblTransRec t1
				JOIN @tblFinalRec t ON (t.strName != @strName
					OR t.strAccountNumber != @strAccountNumber
					OR t.strFutMarketName != @strFutMarketName
					OR t.strCommodityCode != @strCommodityCode) 
					AND t.strBuySell = t1.strBuySell 
					AND t.dblNoOfContract = t1.dblNoOfContract
					AND CONVERT(DATETIME, '1 ' + t.strFutureMonth) = CONVERT(DATETIME, '1 ' + t1.strFutureMonth)
					AND t.dblPrice = t1.dblPrice
					AND CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

	--If there's no import detail and import filled date is equal to Filled Date header
	IF NOT EXISTS(SELECT 1 FROM @tblFinalRec)
	BEGIN
		INSERT INTO @tblFinalRec (strName
			, strAccountNumber
			, strFutMarketName
			, strCommodityCode
			, strBuySell
			, dblNoOfContract
			, strFutureMonth
			, dblPrice
			, dtmFilledDate
			, ImportId
			, strStatus)
		SELECT t.strName
			, t.strAccountNumber
			, t.strFutMarketName
			, t.strCommodityCode
			, t.strBuySell
			, t.dblNoOfContract
			, t.strFutureMonth
			, t.dblPrice
			, t.dtmFilledDate
			, t.ImportId
			, 'Import failed.'
		FROM @ImportedRec2 t
		JOIN @tblTransRec2 t1 ON CONVERT(DATETIME, t.dtmFilledDate, @ConvertYear) = CONVERT(DATETIME, CONVERT(NVARCHAR, t1.dtmFilledDate, @ConvertYear), @ConvertYear)
		WHERE (t1.strName != @strName
			OR t1.strAccountNumber != @strAccountNumber
			OR t1.strFutMarketName != @strFutMarketName
			OR t1.strCommodityCode != @strCommodityCode)
	END
	
	DELETE FROM @ImportedRec2
	DELETE FROM @tblTransRec2

	BEGIN TRANSACTION
	
	DECLARE @intReconciliationBrokerStatementHeaderId INT
	
	IF EXISTS(SELECT TOP 1 1 FROM @tblFinalRec WHERE strStatus <> 'Success')
		OR
	   NOT EXISTS(SELECT TOP 1 1 FROM @tblFinalRec)
	BEGIN
		IF ISNULL(@intReconciliationBrokerStatementHeaderIdIn, 0) = 0
		BEGIN
			INSERT INTO tblRKReconciliationBrokerStatementHeader (intConcurrencyId
				, dtmReconciliationDate
				, dtmFilledDate
				, intEntityId
				, intBrokerageAccountId
				, intFutureMarketId
				, intCommodityId
				, strImportStatus
				, ysnFreezed)
			SELECT intConcurrencyId = 1
				, dtmReconciliationDate = GETDATE()
				, dtmFilledDate = @dtmFilledDate
				, intEntityId = @intBrokerId
				, intBorkerageAccountId = @intBorkerageAccountId
				, intFutureMarketId = @intFutureMarketId
				, intCommodityId = @intCommodityId
				, strImportStatus = 'Failed'
				, ysnFreezed = 0
		
			SET @intReconciliationBrokerStatementHeaderId = SCOPE_IDENTITY()
		
			EXEC uspSMAuditLog @keyValue = @intReconciliationBrokerStatementHeaderId
					, @screenName = 'RiskManagement.view.ReconciliationBrokerStatement'
					, @entityId = @intUserId
					, @actionType = 'Created'
					, @changeDescription = ''
					, @fromValue = '' 
					, @toValue = ''
			WAITFOR DELAY '00:00:01'
		END 
		ELSE
		BEGIN
			UPDATE tblRKReconciliationBrokerStatementHeader
			SET dtmReconciliationDate = GETDATE()
				, dtmFilledDate = @dtmFilledDate
				, intEntityId = @intBrokerId
				, intBrokerageAccountId = @intBorkerageAccountId
				, intFutureMarketId = @intFutureMarketId
				, intCommodityId = @intCommodityId
				, strImportStatus = 'Failed'
				, ysnFreezed = 0
			WHERE intReconciliationBrokerStatementHeaderId = @intReconciliationBrokerStatementHeaderIdIn

			SET @intReconciliationBrokerStatementHeaderId = @intReconciliationBrokerStatementHeaderIdIn
		END

		SET @strStatus = 'Failed'

		EXEC uspSMAuditLog @keyValue = @intReconciliationBrokerStatementHeaderId
				, @screenName = 'RiskManagement.view.ReconciliationBrokerStatement'
				, @entityId = @intUserId
				, @actionType = 'Reconciliation Failed'
				, @changeDescription = ''
				, @fromValue = '' 
				, @toValue = ''
	END 
	ELSE
	BEGIN
		IF ISNULL(@intReconciliationBrokerStatementHeaderIdIn, 0) = 0
		BEGIN
			INSERT INTO tblRKReconciliationBrokerStatementHeader (intConcurrencyId
				, dtmReconciliationDate
				, dtmFilledDate
				, intEntityId
				, intBrokerageAccountId
				, intFutureMarketId
				, intCommodityId
				, strImportStatus
				, strComments
				, ysnFreezed)
			SELECT intConcurrencyId = 1
				, dtmReconciliationDate = GETDATE()
				, dtmFilledDate = @dtmFilledDate
				, intEntityId = @intBrokerId
				, intBorkerageAccountId = @intBorkerageAccountId
				, intFutureMarketId = @intFutureMarketId
				, intCommodityId = @intCommodityId
				, strImportStatus = 'Success'
				, strComments = ''
				, ysnFreezed = 1
		
			SET @intReconciliationBrokerStatementHeaderId = SCOPE_IDENTITY()
		
			EXEC uspSMAuditLog @keyValue = @intReconciliationBrokerStatementHeaderId
					, @screenName = 'RiskManagement.view.ReconciliationBrokerStatement'
					, @entityId = @intUserId
					, @actionType = 'Created'
					, @changeDescription = ''
					, @fromValue = '' 
					, @toValue = ''
			WAITFOR DELAY '00:00:01'

		END
		ELSE 
		BEGIN
			UPDATE tblRKReconciliationBrokerStatementHeader
			SET dtmReconciliationDate = GETDATE()
				, dtmFilledDate = @dtmFilledDate
				, intEntityId = @intBrokerId
				, intBrokerageAccountId = @intBorkerageAccountId
				, intFutureMarketId = @intFutureMarketId
				, intCommodityId = @intCommodityId
				, strImportStatus = 'Success'
				, ysnFreezed = 1
			WHERE intReconciliationBrokerStatementHeaderId = @intReconciliationBrokerStatementHeaderIdIn

			SET @intReconciliationBrokerStatementHeaderId = @intReconciliationBrokerStatementHeaderIdIn
		END

		SET @strStatus = 'Success'

		UPDATE tblRKFutOptTransaction SET ysnFreezed = 1
		WHERE intFutureMarketId = @intFutureMarketId
			AND intCommodityId = @intCommodityId
			AND intEntityId = @intBrokerId
			AND CONVERT(NVARCHAR, dtmFilledDate, @ConvertYear) = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
			AND intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId, 0) = 0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END
			AND intInstrumentTypeId = 1
			AND intSelectedInstrumentTypeId = 1 AND ISNULL(ysnFreezed, 0) = 0

		--SELECT *
		--INTO #tmpDerivatives
		--FROM tblRKFutOptTransaction
		--WHERE intFutureMarketId = @intFutureMarketId
		--	AND intCommodityId = @intCommodityId
		--	AND intEntityId = @intBrokerId
		--	AND CONVERT(NVARCHAR, dtmFilledDate, @ConvertYear) = CONVERT(NVARCHAR, @dtmFilledDate, @ConvertYear)
		--	AND intBrokerageAccountId = CASE WHEN ISNULL(@intBorkerageAccountId, 0) = 0 THEN intBrokerageAccountId ELSE @intBorkerageAccountId END
		--	AND intInstrumentTypeId = 1
		--	AND intSelectedInstrumentTypeId = 1 AND ISNULL(ysnFreezed, 0) = 0


		--WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDerivatives)
		--BEGIN
		--	SELECT TOP 1 @intDerivativeEntryId = intFutOptTransactionId FROM #tmpDerivatives

		--	EXEC uspSMAuditLog @keyValue = @intDerivativeEntryId
		--		,@screenName = 'RiskManagement.view.DerivativeEntry'
		--		,@entityId = @intUserId
		--		,@actionType = 'Reconciled'
		--		,@changeDescription = 'Freeze'
		--		,@fromValue = 'False' 
		--		,@toValue = 'True'

		--	DELETE FROM #tmpDerivatives WHERE intFutOptTransactionId = @intDerivativeEntryId
		--END

		--DROP TABLE #tmpDerivatives
		
		EXEC uspSMAuditLog @keyValue = @intReconciliationBrokerStatementHeaderId
				, @screenName = 'RiskManagement.view.ReconciliationBrokerStatement'
				, @entityId = @intUserId
				, @actionType = 'Reconciliation Successful'
				, @changeDescription = ''
				, @fromValue = '' 
				, @toValue = ''
	END
	
	INSERT INTO tblRKReconciliationBrokerStatement (intReconciliationBrokerStatementHeaderId
		, intConcurrencyId
		, strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, dtmFilledDate
		, strErrMessage)
	SELECT DISTINCT @intReconciliationBrokerStatementHeaderId
		, intConcurrencyId = 1
		, strName
		, strAccountNumber
		, strFutMarketName
		, strCommodityCode
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, dblPrice
		, CONVERT(DATETIME, (CONVERT(NVARCHAR, REPLACE(dtmFilledDate, '-', '/'), @ConvertYear)), @ConvertYear)
		, strStatus
	FROM @tblFinalRec
	
	SELECT @intReconciliationBrokerStatementHeaderIdOut = @intReconciliationBrokerStatementHeaderId
		, @strStatus = @strStatus

	DELETE FROM tblRKReconciliationBrokerStatementImport
	
	COMMIT TRAN
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @ErrMsg != ''
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH