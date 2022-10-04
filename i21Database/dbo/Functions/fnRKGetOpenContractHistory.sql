CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmFromDate DATE
	, @dtmToDate DATE)

RETURNS @Result TABLE (intFutOptTransactionId INT
	, strInstrumentType NVARCHAR(20)
	, strBuySell NVARCHAR(20)
	, dblMatchContract NUMERIC(18, 6))

AS

BEGIN
	DECLARE @strReportByDate NVARCHAR(50) = NULL
	--SET @dtmFromDate = CAST(FLOOR(CAST(@dtmFromDate AS FLOAT)) AS DATETIME)
	--SET @dtmToDate = CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)

	SELECT TOP 1 @strReportByDate = strReportByDate FROM tblRKCompanyPreference
	
	INSERT INTO @Result(intFutOptTransactionId
		, strInstrumentType
		, strBuySell
		, dblMatchContract)
	SELECT DISTINCT mf.intLFutOptTransactionId
		, 'Options'
		, 'Buy'
		, SUM(mf.dblMatchQty)
	FROM tblRKOptionsMatchPnS mf
	WHERE CAST(mf.dtmMatchDate AS DATE) >= @dtmFromDate
	AND CAST(mf.dtmMatchDate AS DATE) <= @dtmToDate
	GROUP BY mf.intLFutOptTransactionId

	UNION ALL SELECT DISTINCT mf.intSFutOptTransactionId
		, 'Options'
		, 'Sell'
		, - SUM(mf.dblMatchQty)
	FROM tblRKOptionsMatchPnS mf
	WHERE CAST(mf.dtmMatchDate AS DATE) >= @dtmFromDate
	AND CAST(mf.dtmMatchDate AS DATE) <= @dtmToDate
	GROUP BY mf.intSFutOptTransactionId

	UNION ALL 

	SELECT mf.intLFutOptTransactionId
		, 'Futures' as strInstrumentType
		, 'Buy' as strBuySell
		, SUM(mf.dblMatchQty) as dblMatchContract
	FROM tblRKMatchDerivativesHistory mf
	WHERE (  @strReportByDate <> 'Create Date'
			 AND CAST(mf.dtmMatchDate AS DATE) >= @dtmFromDate
			 AND CAST(mf.dtmMatchDate AS DATE) <= @dtmToDate
		  )
			OR
		  (	 @strReportByDate = 'Create Date'
			 AND CAST(mf.dtmTransactionDate AS DATE) >= @dtmFromDate
			 AND CAST(mf.dtmTransactionDate AS DATE) <= @dtmToDate
		  )
	GROUP BY mf.intLFutOptTransactionId

	UNION ALL 

	SELECT mf.intSFutOptTransactionId
			, 'Futures' as strInstrumentType
			, 'Sell' as strBuySell
			, - SUM(mf.dblMatchQty) as dblMatchContract
		FROM tblRKMatchDerivativesHistory mf
		WHERE (  @strReportByDate <> 'Create Date'
			 AND CAST(mf.dtmMatchDate AS DATE) >= @dtmFromDate
			 AND CAST(mf.dtmMatchDate AS DATE) <= @dtmToDate
		  )
			OR
		  (	 @strReportByDate = 'Create Date'
			 AND CAST(mf.dtmTransactionDate AS DATE) >= @dtmFromDate
			 AND CAST(mf.dtmTransactionDate AS DATE) <= @dtmToDate
		  )
		GROUP BY mf.intSFutOptTransactionId

	RETURN
END