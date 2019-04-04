CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmDateAsOf DATETIME
	, @intFutOptTransactionId INT)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblMatchContract NUMERIC(18, 6)
		, @strBuySell NVARCHAR(10)
	SET @dtmDateAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDateAsOf, 110), 110)
	
	SELECT TOP 1 @strBuySell = strNewBuySell
	FROM vyuRKGetFutOptTransactionHistory
	WHERE intFutOptTransactionId = @intFutOptTransactionId
		AND dtmTransactionDate <= DATEADD(MILLISECOND, -2, DATEADD(DAY, 1, CAST(FLOOR(CAST(@dtmDateAsOf AS FLOAT)) AS DATETIME)))
		ORDER BY dtmTransactionDate DESC

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

	RETURN @dblMatchContract
END