CREATE PROCEDURE [dbo].[uspAPDeletePayment]
	 @intBillId	INT   
	,@UserId	INT
	,@batchIdUsed AS NVARCHAR(40) = NULL OUTPUT
	,@prepayCreatedIds AS NVARCHAR(40) = NULL OUTPUT 
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


BEGIN TRY
	DECLARE @successPostPayment BIT;
	DECLARE @totalUnpostedPayment INT = 0;
	DECLARE @totalPostedPayment INT = 0;
	DECLARE @UserEntityID INT;
	DECLARE @intPaymentId INT;
	DECLARE @ysnPosted INT;
	DECLARE @ysnClear INT;
	DECLARE @createdPaymentIds AS NVARCHAR(MAX);

	IF OBJECT_ID('tempdb..#tmpCreatedPayment') IS NOT NULL DROP TABLE #tmpCreatedPayment
	CREATE TABLE #tmpCreatedPayment(intCreatePaymentId INT, intBillId INT, ysnClr INT, ysnPosted INT );


	INSERT INTO #tmpCreatedPayment (intCreatePaymentId, intBillId, ysnClr, ysnPosted)
	SELECT	 intPaymentId 
			,intBillId
			,ysnCleared
			,ysnPaymentPosted
	FROM vyuAPBillPayment where intBillId = @intBillId

	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 
	
	SELECT	@intPaymentId = intCreatePaymentId 
			,@ysnPosted = ysnPosted
			,@ysnClear = ysnClr
	FROM #tmpCreatedPayment where intBillId = @intBillId

	SELECT @createdPaymentIds = COALESCE(@createdPaymentIds + ',', '') +  CONVERT(VARCHAR(12),intCreatePaymentId)
	FROM #tmpCreatedPayment
	ORDER BY intCreatePaymentId

	--PAYMENT LOGIC FOR NOT POSTED / NOT CLEARED
	IF (@ysnPosted = 0)
	BEGIN 
		DELETE FROM tblAPPaymentDetail where intPaymentId = @intPaymentId

		DELETE FROM tblAPPayment where intPaymentId = @intPaymentId
	END
	--PAYMENT LOGIC FOR POSTED PAYMENT CLEARED
	ELSE 
	BEGIN
		IF (@ysnClear = 1)
		BEGIN 
			EXEC uspAPRemovePaymentAndCreatePrepay @intBillId, @UserEntityID, @createdPaymentIds, @prepayCreatedIds OUT
		END
		ELSE
		BEGIN	
				EXEC uspAPPostPayment @userId = @UserEntityID,
				@recap = 0,
				@post = 0,
				@param = @createdPaymentIds,
				@success = @successPostPayment OUT,
				@batchIdUsed = @batchIdUsed OUT,
				@successfulCount = @totalPostedPayment OUT,
				@invalidCount = @totalUnpostedPayment OUT

		DELETE FROM tblAPPaymentDetail where intPaymentId = @intPaymentId

		DELETE FROM tblAPPayment where intPaymentId = @intPaymentId
		END
	END

	BEGIN 
		DELETE FROM dbo.tblSMTransaction
		WHERE intRecordId = @intPaymentId 
		AND intScreenId = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PayVouchersDetail')
	
		--Audit Log          
		EXEC dbo.uspSMAuditLog 
			 @keyValue			= @intPaymentId						-- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsPayable.view.PayVouchersDetail'	-- Screen Namespace
			,@entityId			= @UserEntityID						-- Entity Id.
			,@actionType		= 'Deleted'							-- Action Type
			,@changeDescription	= ''								-- Description
			,@fromValue			= ''								-- Previous Value
			,@toValue			= ''								-- New Value
	END

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END