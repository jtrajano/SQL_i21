CREATE PROCEDURE uspRKDeleteAutoHedge
	@intFutOptTransactionId INT
	, @intUserId INT

AS
	
BEGIN TRY
	DECLARE @TransId INT = 0
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	IF EXISTS (SELECT TOP 1 1 FROM tblRKMatchFuturesPSDetail d
				JOIN tblRKMatchFuturesPSHeader mh ON d.intMatchFuturesPSHeaderId = mh.intMatchFuturesPSHeaderId
				WHERE intLFutOptTransactionId = @intFutOptTransactionId AND ISNULL(ysnPosted, 0) = 1)
	BEGIN
		SET @TransId = 1
	END
	
	IF EXISTS (SELECT TOP 1 1 FROM tblRKMatchFuturesPSDetail d
				JOIN tblRKMatchFuturesPSHeader mh ON d.intMatchFuturesPSHeaderId = mh.intMatchFuturesPSHeaderId
				WHERE intSFutOptTransactionId = @intFutOptTransactionId AND ISNULL(ysnPosted, 0) = 1)
	BEGIN
		  SET @TransId = 1
	END

	IF (@TransId = 1)
	BEGIN
		RAISERROR('The selected transaction is used for match PnS and posted. Cannot delete this transaction.', 16, 1)
	END
	
	IF EXISTS (SELECT TOP 1 1 FROM tblRKFutOptTransaction t
				WHERE intFutOptTransactionId = @intFutOptTransactionId AND ISNULL(ysnFreezed, 0) = 1)
	BEGIN
		RAISERROR('The selected transaction is already reconciled. Cannot delete this transaction.', 16, 1)
	END
	
	DELETE FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId = @intFutOptTransactionId OR intSFutOptTransactionId = @intFutOptTransactionId
	DELETE FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId = @intFutOptTransactionId

	DECLARE @intFutOptTransactionHeaderId INT
	SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId FROM tblRKFutOptTransaction WHERE intFutOptTransactionId = @intFutOptTransactionId

	EXEC uspRKFutOptTransactionHistory @intFutOptTransactionId, @intFutOptTransactionHeaderId, 'Price Contracts', @intUserId, 'HEADER DELETE'
	DELETE FROM tblRKFutOptTransactionHeader WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
	EXEC uspRKSaveDerivativeEntry @intFutOptTransactionId, @intFutOptTransactionHeaderId, @intUserId, 'HEADER DELETE'
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @ErrMsg != ''
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH