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

	DECLARE @transCount INT;
	DECLARE @voucherBillDetailIds AS Id;
	DECLARE @vendorOrderNumber NVARCHAR(100);
	SET @transCount = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO @voucherBillDetailIds
	SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intBillId

	SELECT @vendorOrderNumber = strVendorOrderNumber FROM tblAPBill WHERE intBillId = @intBillId

	DECLARE @UserEntityID INT
	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 
	
	--CHECK IF POSTED
	IF(EXISTS(SELECT NULL FROM dbo.tblAPBill WHERE intBillId = @intBillId AND ISNULL(ysnPosted,0) = 1))
		RAISERROR('The transaction is already posted.',16,1)			

	--WILL REVERT ONCE SCALE WITH CONTRACT FIXATION IS RELATED
	UPDATE tblCTPriceFixationDetail SET intBillDetailId = NULL , intBillId = NULL WHERE intBillId = @intBillId

	--WILL REVERT FIRST THE APPLIED BILL 
	UPDATE tblAPAppliedPrepaidAndDebit SET intBillDetailApplied = NULL  WHERE intBillId = @intBillId
	
	--clear original transaction if this is a reversal
	UPDATE A
		SET A.intTransactionReversed = NULL
	FROM tblAPBill A
	INNER JOIN tblAPBill B
		ON A.intTransactionReversed = B.intBillId
	WHERE A.intBillId = @intBillId

	--EXECUTE uspAPUpdateVoucherPayable for deleted.
	EXEC [dbo].[uspAPUpdateVoucherPayable]
		@voucherDetailIds = @voucherBillDetailIds,
		@decrease = 1
	
	EXEC [dbo].[uspAPUpdateIntegrationPayableAvailableQty]
		@billDetailIds = @voucherBillDetailIds,
		@decrease = 0

	EXEC uspAPUpdateInvoiceNumInGLDetail @invoiceNumber = @vendorOrderNumber, @intBillId = @intBillId

	EXEC uspGRDeleteStorageHistory 'Voucher', @intBillId

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

	IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END

