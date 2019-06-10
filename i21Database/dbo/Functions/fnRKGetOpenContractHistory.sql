CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intFutOptTransactionId INT)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblMatchContract NUMERIC(18, 6)
		, @strBuySell NVARCHAR(10)
		, @strInstrumentType NVARCHAR(50)
	SET @dtmFromDate = CAST(FLOOR(CAST(@dtmFromDate AS FLOAT)) AS DATETIME)
	SET @dtmToDate = CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)
	
	SELECT TOP 1 @strBuySell = strNewBuySell
		, @strInstrumentType = strInstrumentType
	FROM vyuRKGetFutOptTransactionHistory
	WHERE intFutOptTransactionId = @intFutOptTransactionId
		AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
		AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate
	ORDER BY dtmTransactionDate DESC

	IF (@strInstrumentType = 'Options')
	BEGIN
		IF (@strBuySell = 'Buy')
		BEGIN
			SELECT @dblMatchContract = SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			WHERE mf.intLFutOptTransactionId = @intFutOptTransactionId
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		END
		ELSE
		BEGIN
			SELECT @dblMatchContract = - SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			WHERE mf.intSFutOptTransactionId = @intFutOptTransactionId
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		END
	END
	ELSE
	BEGIN
		IF (@strBuySell = 'Buy')
		BEGIN
			SELECT @dblMatchContract = SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE mf.intLFutOptTransactionId = @intFutOptTransactionId
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		END
		ELSE
		BEGIN
			SELECT @dblMatchContract = - SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE mf.intSFutOptTransactionId = @intFutOptTransactionId
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
				AND CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
		END
	END

	RETURN @dblMatchContract
END