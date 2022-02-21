CREATE PROCEDURE [dbo].[uspRKProcessDerivativeEntry]
	@intFutOptTransactionId INT
	, @strAction NVARCHAR(50)
	, @intUserId INT

AS

BEGIN
	-- VALIDATE IF HAS POSTED BANK TRANSFER PREVENT DELETE
	IF (@strAction = 'Header Delete' OR @strAction = 'Delete')
	BEGIN 
		DECLARE @ysnHasPosted BIT = 0;

		IF @strAction = 'Header Delete'
		BEGIN
			SELECT TOP 1 @ysnHasPosted = CAST(1 AS BIT)
			FROM tblRKFutOptTransactionHeader derh
			JOIN tblRKFutOptTransaction der
				ON der.intFutOptTransactionHeaderId = derh.intFutOptTransactionHeaderId
			WHERE derh.intFutOptTransactionHeaderId = @intFutOptTransactionId
			AND ISNULL(der.intBankTransferId, 0) <> 0
		END
		ELSE
		BEGIN 
			SELECT TOP 1 @ysnHasPosted = CAST(1 AS BIT)
			FROM tblRKFutOptTransaction der
			WHERE der.intFutOptTransactionId = @intFutOptTransactionId
			AND ISNULL(der.intBankTransferId, 0) <> 0
		END

		IF (@ysnHasPosted = 1)
		BEGIN 
			RAISERROR ('Cannot delete record with Bank Transfer Posted.', 16, 1, 'WITH NOWAIT')
			RETURN
		END
	END
	
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