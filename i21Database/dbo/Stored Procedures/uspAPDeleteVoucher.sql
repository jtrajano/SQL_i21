﻿/**
	@callerModule
	0 = AP
	1 = Grain
	2 = Scale
	3 = Inventory
	4 = Contract
	5 = Patronage
	6 = Sales
	7 = LG
	8 = Payroll
	9 = Credit Card
	10 = BuyBack
*/
CREATE PROCEDURE [dbo].[uspAPDeleteVoucher]
	 @intBillId	INT   
	,@UserId	INT
	,@callerModule INT = 0
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

	-- Checked if module is AP Voucher and the voucher is generated from Ticket with type of Direct  
	IF @callerModule = 0 AND EXISTS (  
		SELECT 1  
		FROM tblAPBillDetail bill  
		INNER JOIN tblSCTicket tkt  
		ON intScaleTicketId = tkt.intTicketId  
		INNER JOIN tblSCListTicketTypes ltt  
		ON tkt.intTicketTypeId = ltt.intTicketTypeId  
		WHERE bill.intBillId = @intBillId  
		AND ltt.strTicketType = 'Direct In')

	BEGIN  
		RAISERROR('Unable to delete. Please use ticket screen to delete the voucher',16,1)  
	RETURN;    
	END  

	IF(NOT EXISTS(SELECT 1 FROM dbo.tblAPBill WHERE intBillId = @intBillId))
	BEGIN
		RAISERROR('Voucher already deleted.',16,1)
		RETURN;
	END

	SET @transCount = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	INSERT INTO @voucherBillDetailIds
	SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intBillId

	IF(NOT EXISTS(SELECT 1 FROM @voucherBillDetailIds) AND @callerModule != 0)
	BEGIN
		RAISERROR('Voucher details already deleted.',16,1)
		RETURN;
	END

	SELECT @vendorOrderNumber = strVendorOrderNumber FROM tblAPBill WHERE intBillId = @intBillId

	DECLARE @UserEntityID INT
	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 
	
	--CHECK IF POSTED
	IF(EXISTS(SELECT NULL FROM dbo.tblAPBill WHERE intBillId = @intBillId AND ISNULL(ysnPosted,0) = 1))
	BEGIN
		RAISERROR('The transaction is already posted.',16,1);
		RETURN;
	END	

	IF EXISTS(SELECT 1 FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @intBillId)
	BEGIN
		--Do not allow to delete if details have associated storage and contract
		--IF DELETED ON VOUCHER SCREEN AND HAVE SETTLE STORAGE
		IF @callerModule = 0 AND EXISTS(SELECT 1 FROM tblGRSettleStorage WHERE intBillId = @intBillId)
		BEGIN
			RAISERROR('Unable to delete. Please use pricing screen to delete the voucher.', 16, 1);
			RETURN;	
		END
		--WILL REVERT ONCE SCALE WITH CONTRACT FIXATION IS RELATED
		UPDATE tblCTPriceFixationDetail SET intBillDetailId = NULL , intBillId = NULL WHERE intBillId = @intBillId

		DELETE FROM tblCTPriceFixationTicket
		WHERE intPriceFixationTicketId IN 
		(
			SELECT pft.intPriceFixationTicketId 
			FROM tblCTPriceFixationTicket pft 
			INNER JOIN vyuCTPriceFixationTicket ft ON pft.intInventoryReceiptId = ft.intInventoryReceiptId 
				AND pft.intPricingId = ft.intPricingId
			INNER JOIN tblAPBillDetail bd ON ft.intDetailId = bd.intBillDetailId 
				AND ft.intInventoryShipmentId IS NULL 
			WHERE bd.intBillId = @intBillId
		)

		UPDATE tblCTPriceFixationDetailAPAR SET intBillDetailId = NULL , intBillId = NULL WHERE intBillId = @intBillId

		-- we need to set this to null so that it will not be deleted
		-- the only time we will not delete this is when a pricing is deleted,
		-- other scenario SHOULD delete the history
		-- Mon
		update tblGRStorageHistory set intBillId = null Where intBillId=@intBillId 
	END
	--WILL REVERT FIRST THE APPLIED BILL 
	UPDATE tblAPAppliedPrepaidAndDebit SET intBillDetailApplied = NULL  WHERE intBillId = @intBillId
	UPDATE tblGRSettleStorage SET intBillId = NULL WHERE intBillId = @intBillId
	UPDATE tblGRStorageHistory SET intBillId = NULL WHERE intBillId = @intBillId
	UPDATE tblHDTicketHoursWorked SET intBillId = NULL WHERE intBillId = @intBillId
	
	--clear original transaction if this is a reversal
	UPDATE A
		SET A.intTransactionReversed = NULL
	FROM tblAPBill A
	INNER JOIN tblAPBill B
		ON A.intTransactionReversed = B.intBillId
	WHERE A.intBillId = @intBillId

	IF(EXISTS(SELECT TOP 1 1 FROM @voucherBillDetailIds))
	BEGIN
		UPDATE BD
		SET BD.ysnStage = 1
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
		WHERE B.intBillId = @intBillId AND B.ysnFinalVoucher = 1

		--EXECUTE uspAPUpdateVoucherPayable for deleted.
		EXEC [dbo].[uspAPUpdateVoucherPayable]
			@voucherDetailIds = @voucherBillDetailIds,
			@decrease = 1
		
		EXEC [dbo].[uspAPUpdateIntegrationPayableAvailableQty]
			@billDetailIds = @voucherBillDetailIds,
			@decrease = 0 --decrease what we added before, we will call this again after deletion
	END

	EXEC uspAPUpdateInvoiceNumInGLDetail @invoiceNumber = @vendorOrderNumber, @intBillId = @intBillId

	EXEC uspGRDeleteStorageHistory 'Voucher', @intBillId

	EXEC uspAPArchiveVoucher @billId = @intBillId

	IF(EXISTS(SELECT TOP 1 1 FROM @voucherBillDetailIds))
	BEGIN
		EXEC uspAPLogVoucherDetailRisk @voucherDetailIds = @voucherBillDetailIds, @remove = 1
	END

	EXEC uspAPAddTransactionLinks 1, @intBillId, 3, @UserId
	
	--UPDATE PO STATUS
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPurchaseId')) DROP TABLE #tmpPurchaseId
	
	SELECT DISTINCT
		B.intPurchaseId
	INTO #tmpPurchaseId
	FROM tblAPBillDetail A 
	INNER JOIN tblPOPurchaseDetail B 
		ON A.[intPurchaseDetailId] = B.intPurchaseDetailId	
	WHERE A.intBillId = @intBillId

	DELETE FROM dbo.tblAPBillDetailTax
	WHERE intBillDetailId IN (SELECT intBillDetailId FROM dbo.tblAPBillDetail WHERE intBillId = @intBillId)

	DELETE FROM dbo.tblAPBillDetail 
	WHERE intBillId = @intBillId

	DELETE FROM dbo.tblAPAppliedPrepaidAndDebit
	WHERE intBillId = @intBillId

	DELETE FROM dbo.tblAPAppliedPrepaidAndDebit
	WHERE intTransactionId = @intBillId

	--Get intBillBatchId of the deleted Voucher
	DECLARE @billBatchId INT
	SET @billBatchId = (SELECT A.intBillBatchId FROM tblAPBill A WHERE A.intBillId = @intBillId)

	--Delete Voucher
	DELETE FROM dbo.tblAPBill 
	WHERE intBillId = @intBillId

	--Update the tblAPBillBatch
	EXEC uspAPUpdateBillBatch @billBatchId = @billBatchId
	
	DECLARE @purchaseId INT;
	WHILE EXISTS(SELECT 1 FROM #tmpPurchaseId)
	BEGIN
		SELECT TOP(1) 
			@purchaseId = intPurchaseId
		FROM #tmpPurchaseId
		EXEC uspPOUpdateStatus @purchaseId, DEFAULT
		DELETE FROM #tmpPurchaseId WHERE intPurchaseId = @purchaseId
	END

	--Removed - FRM-9293
	--DELETE FROM dbo.tblSMTransaction
	--WHERE intRecordId = @intBillId 
	--AND intScreenId = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher')
	
	IF @callerModule <> 0
	BEGIN
		EXEC dbo.uspSMAuditLog 
			 @keyValue			= @intBillId						-- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsPayable.view.Voucher'	-- Screen Namespace
			,@entityId			= @UserEntityID						-- Entity Id.
			,@actionType		= 'Deleted'							-- Action Type
			,@changeDescription	= ''								-- Description
			,@fromValue			= ''								-- Previous Value
			,@toValue			= ''								-- New Value
	END

	IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	ROLLBACK TRANSACTION;
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END

