CREATE PROCEDURE [dbo].[uspCMDeleteBankForwardDerivate]
	@intBankTransferId INT
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION;
	
	DECLARE 
		@intFutOptTransactionId INT,
		@strErrorMessage nvarchar(max);

	SELECT TOP 1 @intFutOptTransactionId = intFutOptTransactionId
	FROM [dbo].[tblCMBankTransfer]
	WHERE intTransactionId = @intBankTransferId

	-- UPDATE DERIVATE ENTRY
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[tblRKFutOptTransaction] WHERE intBankTransferId = @intBankTransferId AND intFutOptTransactionId = @intFutOptTransactionId)
	BEGIN
		UPDATE [dbo].[tblRKFutOptTransaction]
		SET
			intBankTransferId = NULL
		WHERE intBankTransferId = @intBankTransferId AND intFutOptTransactionId = @intFutOptTransactionId

		DELETE [dbo].[tblCMBankTransfer] WHERE intTransactionId = @intBankTransferId
	END

	IF @@ERROR <> 0	GOTO Post_Rollback;
	ELSE GOTO Post_Commit;

	Post_Commit:
		COMMIT TRANSACTION
		GOTO Post_Exit

	Post_Rollback:
		ROLLBACK TRANSACTION	
		SET @strErrorMessage = ERROR_MESSAGE();  
		RAISERROR (@strErrorMessage, 16, 1,'WITH NOWAIT');
		GOTO Post_Exit

	Post_Exit: