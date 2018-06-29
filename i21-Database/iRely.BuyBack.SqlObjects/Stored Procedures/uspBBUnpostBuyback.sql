CREATE PROCEDURE [dbo].[uspBBUnpostBuyback]
	@intBuyBackId INT
	,@intUserId INT
	,@strPostingError NVARCHAR(MAX) = '' OUTPUT
AS
	DECLARE @intInvoiceId INT
	DECLARE @batchIdUsed NVARCHAR(40)
	DECLARE @success BIT 
	DECLARE @strReimbursementType NVARCHAR(10)
	DECLARE @intBillId INT

	--DECLARE @strPostingError NVARCHAR(MAX)
	--dECLARE @intBuyBackId INT
	--SET @intBuyBackId = 29


	SET @strReimbursementType = 'AR'
	SELECT TOP 1 
		@strReimbursementType = strReimbursementType
	FROM tblVRVendorSetup WHERE intEntityId = (
												SELECT TOP 1 intEntityId 
												FROM tblBBBuyback 
												WHERE intBuybackId = @intBuyBackId
											  )
	IF(@strReimbursementType = 'AR')
	BEGIN
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

					UPDATE tblARInvoiceDetail
					SET dblBuybackAmount = 0
						,dblBaseBuybackAmount = 0
						,strBuybackSubmitted = 'N'
					FROM (SELECT DISTINCT intInvoiceDetailId FROM tblBBBuybackDetail WHERE intBuybackId = @intBuyBackId) A
					WHERE tblARInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId

					EXEC [uspARDeleteInvoice] @intInvoiceId, @intUserId
				COMMIT
			END TRY
			BEGIN CATCH
				ROLLBACK
				SET @strPostingError = ERROR_MESSAGE()
			END CATCH
		END
	END
	ELSE
	BEGIN

		SELECT TOP 1 @intBillId = intBillId
		FROM tblBBBuyback WHERE intBuybackId = @intBuyBackId

		EXEC [dbo].[uspAPPostBill]
		@post = 0
		,@recap = 0
		,@isBatch = 0
		,@param = @intBillId
		,@userId = @intUserId
		,@success = @success OUTPUT
		,@batchIdUsed = @batchIdUsed OUTPUT

		IF(@success = 0)
		BEGIN
			SELECT @strPostingError = strMessage 
			FROM tblAPPostResult WHERE strBatchNumber = @batchIdUsed
		END
		ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
					UPDATE tblBBBuyback 
					SET intBillId = NULL
						,intConcurrencyId = intConcurrencyId + 1
						,ysnPosted = 0

					UPDATE tblARInvoiceDetail
					SET dblBuybackAmount = 0
						,dblBaseBuybackAmount = 0
						,strBuybackSubmitted = 'N'
					FROM (SELECT DISTINCT intInvoiceDetailId FROM tblBBBuybackDetail WHERE intBuybackId = @intBuyBackId) A
					WHERE tblARInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId

					EXEC [uspAPDeleteVoucher] @intBillId, @intUserId
				COMMIT
			END TRY
			BEGIN CATCH
				ROLLBACK
				SET @strPostingError = ERROR_MESSAGE()
			END CATCH
		END
	END
GO
