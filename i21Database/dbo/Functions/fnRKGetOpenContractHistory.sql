CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmDateAsOf DATETIME
	, @intFutOptTransactionId INT)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblMatchContract NUMERIC(18, 6)
		, @strBuySell NVARCHAR(10)
		, @strInstrumentType NVARCHAR(50)
	SET @dtmDateAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDateAsOf, 110), 110)
	
	SELECT TOP 1 @strBuySell = strNewBuySell
		, @strInstrumentType = strInstrumentType
	FROM vyuRKGetFutOptTransactionHistory
	WHERE intFutOptTransactionId = @intFutOptTransactionId
		AND dtmTransactionDate <= DATEADD(MILLISECOND, -2, DATEADD(DAY, 1, CAST(FLOOR(CAST(@dtmDateAsOf AS FLOAT)) AS DATETIME)))
		ORDER BY dtmTransactionDate DESC

	IF (@strInstrumentType = 'Options')
	BEGIN
		IF (@strBuySell = 'Buy')
		BEGIN
			SELECT @dblMatchContract = SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			WHERE mf.intLFutOptTransactionId = @intFutOptTransactionId
				AND mf.dtmMatchDate <= @dtmDateAsOf
		END
		ELSE
		BEGIN
			SELECT @dblMatchContract = - SUM(mf.dblMatchQty)
			FROM tblRKOptionsMatchPnS mf
			WHERE mf.intSFutOptTransactionId = @intFutOptTransactionId
				AND mf.dtmMatchDate <= @dtmDateAsOf
		END
	END
	ELSE
	BEGIN
		IF (@strBuySell = 'Buy')
		BEGIN
			SELECT @dblMatchContract = SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE mf.intLFutOptTransactionId = @intFutOptTransactionId
				AND mf.dtmMatchDate <= @dtmDateAsOf
		END
		ELSE
		BEGIN
			SELECT @dblMatchContract = - SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE mf.intSFutOptTransactionId = @intFutOptTransactionId
				AND mf.dtmMatchDate <= @dtmDateAsOf
		END
	END

	RETURN @dblMatchContract
END