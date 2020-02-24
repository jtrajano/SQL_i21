CREATE FUNCTION [dbo].[fnRKGetMatchedQtyAsOf]
(
	@intFutOptTransactionId INT
	, @dtmAsOfDate DATETIME
)

RETURNS NUMERIC(24, 20)

AS

BEGIN
	SET @dtmAsOfDate = CAST(FLOOR(CAST(@dtmAsOfDate AS FLOAT)) AS DATETIME)
	DECLARE @dblMatchedQty NUMERIC(24, 20)
	
	SELECT @dblMatchedQty = ISNULL(SUM(dblMatchQty), 0.00) FROM (
		SELECT dblMatchQty = SUM(mf.dblMatchQty)
		FROM tblRKOptionsMatchPnS mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmAsOfDate
			AND mf.intLFutOptTransactionId = @intFutOptTransactionId

		UNION ALL SELECT dblMatchQty = - SUM(mf.dblMatchQty)
		FROM tblRKOptionsMatchPnS mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmAsOfDate
			AND mf.intSFutOptTransactionId = @intFutOptTransactionId

		UNION ALL SELECT dblMatchQty = SUM(mf.dblMatchQty)
		FROM tblRKMatchDerivativesHistory mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmAsOfDate
			AND mf.intLFutOptTransactionId= @intFutOptTransactionId
		
		UNION ALL SELECT dblMatchQty = - SUM(mf.dblMatchQty)
		FROM tblRKMatchDerivativesHistory mf
		WHERE CAST(FLOOR(CAST(mf.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmAsOfDate
			AND mf.intSFutOptTransactionId = @intFutOptTransactionId
	) tbl
		
	RETURN @dblMatchedQty
END
