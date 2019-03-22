﻿CREATE PROCEDURE [dbo].[uspAPDeleteVoucher]
	 @intBillId	INT   
	,@UserId	INT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @UserEntityID INT
	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 
	
	--CHECK IF POSTED
	IF(EXISTS(SELECT NULL FROM dbo.tblAPBill WHERE intBillId = @intBillId AND ISNULL(ysnPosted,0) = 1))
		RAISERROR('The transaction is already posted.',16,1)			

	--WILL REVERT ONCE SCALE WITH CONTRACT FIXATION IS RELATED
	UPDATE tblCTPriceFixationDetail SET intBillDetailId = NULL , intBillId = NULL WHERE intBillId = @intBillId

	--WILL REVERT FIRST THE APPLIED BILL 
	UPDATE tblAPAppliedPrepaidAndDebit SET intBillDetailApplied = NULL  WHERE intBillId = @intBillId

	DELETE FROM dbo.tblAPBillDetailTax
	WHERE intBillDetailId IN (SELECT intBillDetailId FROM dbo.tblAPBillDetail WHERE intBillId = @intBillId)

	DELETE FROM dbo.tblAPBillDetail 
	WHERE intBillId = @intBillId

	DELETE FROM dbo.tblAPAppliedPrepaidAndDebit
	WHERE intBillId = @intBillId

	DELETE FROM dbo.tblAPBill 
	WHERE intBillId = @intBillId

	DELETE FROM dbo.tblSMTransaction
	WHERE intRecordId = @intBillId 
	AND intScreenId = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher')
	
	--Audit Log          
	EXEC dbo.uspSMAuditLog 
		 @keyValue			= @intBillId						-- Primary Key Value of the Invoice. 
		,@screenName		= 'AccountsPayable.view.Voucher'	-- Screen Namespace
		,@entityId			= @UserEntityID						-- Entity Id.
		,@actionType		= 'Deleted'							-- Action Type
		,@changeDescription	= ''								-- Description
		,@fromValue			= ''								-- Previous Value
		,@toValue			= ''								-- New Value

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END

