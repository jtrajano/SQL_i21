CREATE PROCEDURE [dbo].[uspBBUnpostBuyback]
	@intBuyBackId INT
	,@intUserId INT
	,@strPostingError NVARCHAR(MAX) = '' OUTPUT
AS
	DECLARE @intInvoiceId INT
	DECLARE @batchIdUsed NVARCHAR(40)
	DECLARE @success BIT 

	--DECLARE @strPostingError NVARCHAR(MAX)
	--dECLARE @intBuyBackId INT
	--SET @intBuyBackId = 29

	SELECT TOP 1 @intInvoiceId = intInvoiceId
	FROM tblBBBuyback WHERE intBuybackId = @intBuyBackId

	EXEC [uspARPostInvoice] 
		@post = 0
		,@param = @intInvoiceId
		,@success = @success OUTPUT
		,@batchIdUsed = @batchIdUsed OUTPUT

	IF(@success = 0)
	BEGIN
		SELECT @strPostingError = strMessage 
		FROM tblARPostResult WHERE strBatchNumber = @batchIdUsed
	END
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				UPDATE tblBBBuyback 
				SET intInvoiceId = NULL
					,intConcurrencyId = intConcurrencyId + 1
					,ysnPosted = 0

				EXEC [uspARDeleteInvoice] @intInvoiceId, @intUserId
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK
			SET @strPostingError = ERROR_MESSAGE()
		END CATCH
	END
GO
