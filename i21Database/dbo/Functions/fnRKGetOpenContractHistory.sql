CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME)

RETURNS @Result TABLE (intFutOptTransactionId INT
	, strInstrumentType NVARCHAR(20)
	, strBuySell NVARCHAR(20)
	, dblMatchContract NUMERIC(18, 6))

AS

BEGIN
	SET @dtmFromDate = CAST(FLOOR(CAST(@dtmFromDate AS FLOAT)) AS DATETIME)
	SET @dtmToDate = CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)
	
	INSERT INTO @Result(intFutOptTransactionId
		, strInstrumentType
		, strBuySell
		, dblMatchContract)
	SELECT DISTINCT mf.intLFutOptTransactionId
		, 'Options'
		, 'Buy'
		, SUM(mf.dblMatchQty)
	FROM tblRKOptionsMatchPnS mf
	WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
		AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
	GROUP BY mf.intLFutOptTransactionId

	UNION ALL SELECT DISTINCT mf.intSFutOptTransactionId
		, 'Options'
		, 'Sell'
		, - SUM(mf.dblMatchQty)
	FROM tblRKOptionsMatchPnS mf
	WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
		AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
	GROUP BY mf.intSFutOptTransactionId

	UNION ALL 
	SELECT intLFutOptTransactionId
			, strInstrumentType
			, strBuySell
			, dblMatchContract
	 FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY mf.intLFutOptTransactionId ORDER BY mf.dtmTransactionDate DESC)  
			, mf.intLFutOptTransactionId
			, 'Futures' as strInstrumentType
			, 'Buy' as strBuySell
			, SUM(mf.dblMatchQty) as dblMatchContract
		FROM tblRKMatchDerivativesHistory mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
			AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		GROUP BY mf.intLFutOptTransactionId, dtmTransactionDate
	) t WHERE intRowNum = 1

	UNION ALL 
	SELECT intSFutOptTransactionId
			, strInstrumentType
			, strBuySell
			, dblMatchContract
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY mf.intSFutOptTransactionId ORDER BY mf.dtmTransactionDate DESC)    
			, mf.intSFutOptTransactionId
			, 'Futures' as strInstrumentType
			, 'Sell' as strBuySell
			, - SUM(mf.dblMatchQty) as dblMatchContract
		FROM tblRKMatchDerivativesHistory mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
			AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		GROUP BY mf.intSFutOptTransactionId, dtmTransactionDate
	) t WHERE intRowNum = 1

	RETURN
END