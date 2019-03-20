CREATE FUNCTION [dbo].[fnRKGetOpenContractHistory] (
	@dtmDateAsOf DATETIME
	, @intFutOptTransactionId INT)

RETURNS NUMERIC(18, 6)

AS

BEGIN
	DECLARE @dblMatchContract NUMERIC(18, 6)
	SET @dtmDateAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDateAsOf, 110), 110)

	SELECT @dblMatchContract = SUM(mf.dblMatchQty)
	FROM tblRKMatchDerivativesHistory mf
	WHERE mf.intLFutOptTransactionId = @intFutOptTransactionId
		AND mf.dtmMatchDate <= @dtmDateAsOf

	RETURN @dblMatchContract
END