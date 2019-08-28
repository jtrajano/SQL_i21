CREATE PROCEDURE [dbo].[uspRKProcessDerivativeEntry]
	@intFutOptTransactionId INT
	, @strAction NVARCHAR(50)
	, @intUserId INT

AS

BEGIN
	IF (@strAction = 'Header Delete')
	BEGIN
		SELECT *
		INTO #Temp1
		FROM tblRKFutOptTransaction WHERE intFutOptTransactionHeaderId = @intFutOptTransactionId
		
		WHILE EXISTS (SELECT TOP 1 1 FROM #Temp1)
		BEGIN
			SELECT TOP 1 @intFutOptTransactionId = intFutOptTransactionId FROM #Temp1
			-- Call Contract SP here
			EXEC uspCTSyncPriceAndDerivative @intFutOptTransactionId
				, 'Delete'

			DELETE FROM #Temp1 WHERE intFutOptTransactionId = @intFutOptTransactionId
		END

		DROP TABLE #Temp1
	END
	ELSE
	BEGIN
		SELECT *
		INTO #Temp2
		FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId

		IF EXISTS (SELECT TOP 1 1 FROM #Temp2)
		BEGIN
			-- Call Contract SP here
			EXEC uspCTSyncPriceAndDerivative @intFutOptTransactionId
				, @strAction
		END

		DROP TABLE #Temp2
	END
	
END