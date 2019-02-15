CREATE PROC uspRKUpdateMismatchedMonth @intFutOptTransactionId INT
AS
DECLARE @intFutureMarketId INT,
	@intFutureMonthId INT

SELECT @intFutureMarketId = intFutureMarketId,
	@intFutureMonthId = intFutureMonthId
FROM tblRKFutOptTransaction
WHERE intFutOptTransactionId = @intFutOptTransactionId

IF NOT EXISTS (
		SELECT *
		FROM tblRKFuturesMonth
		WHERE intFutureMarketId = @intFutureMarketId AND intFutureMonthId = @intFutureMonthId
		)
BEGIN
	DECLARE @strOldMonthName NVARCHAR(100)
	DECLARE @intNewMonthId INT

	SELECT @strOldMonthName = strFutureMonth
	FROM tblRKFuturesMonth
	WHERE intFutureMonthId = @intFutureMonthId

	SELECT @intNewMonthId = intFutureMonthId
	FROM tblRKFuturesMonth
	WHERE strFutureMonth = @strOldMonthName AND intFutureMarketId = @intFutureMarketId
	IF (ISNULL(@intNewMonthId,0))<>0
	BEGIN
		UPDATE tblRKFutOptTransaction
		SET intFutureMonthId = @intNewMonthId
		WHERE intFutOptTransactionId = @intFutOptTransactionId
	END
END
