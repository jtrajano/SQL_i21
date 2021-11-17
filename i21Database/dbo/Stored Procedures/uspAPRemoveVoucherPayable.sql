CREATE PROCEDURE [dbo].[uspAPRemoveVoucherPayable]
	@voucherPayable AS VoucherPayable READONLY,
	@throwError BIT = 1,
	@error NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON turn off automatically rollback if error occurs, we handle the rollback manually
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @vouchers AS TABLE(
	strBillId NVARCHAR(50)
	,intEntityVendorId INT NULL
	,intPurchaseDetailId INT NULL
	,intContractDetailId INT NULL
	,intScaleTicketId INT NULL
	,intInventoryReceiptChargeId INT NULL
	,intInventoryReceiptItemId INT NULL
	,intInventoryShipmentChargeId INT NULL
	,intLoadShipmentDetailId INT NULL
	,intLoadShipmentCostId INT NULL
	,intCustomerStorageId INT NULL
	,intSettleStorageId INT NULL
	,intItemId INT NULL
	,intTransactionType INT NOT NULL
	);
DECLARE @payablesDeleted AS TABLE(
	intVoucherPayableId INT NOT NULL
	,intEntityVendorId INT NULL
	,intPurchaseDetailId INT NULL
	,intContractDetailId INT NULL
	,intScaleTicketId INT NULL
	,intInventoryReceiptChargeId INT NULL
	,intInventoryReceiptItemId INT NULL
	,intInventoryShipmentChargeId INT NULL
	,intLoadShipmentDetailId INT NULL
	,intLoadShipmentCostId INT NULL
	,intCustomerStorageId INT NULL
	,intSettleStorageId INT NULL
	,intItemId INT NULL
	,intTransactionType INT NOT NULL
	);
DECLARE @voucherIds NVARCHAR(MAX);
DECLARE @recordCountToDelete INT = 0;
DECLARE @recordCountDeleted INT = 0;
DECLARE @SavePoint NVARCHAR(32) = 'uspAPRemoveVoucherPayable';
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF EXISTS(SELECT TOP 1 1 FROM @voucherPayable)
BEGIN

	SELECT @recordCountToDelete = COUNT(*) FROM @voucherPayable

	--Validate, there should be no voucher created, top 10 only to limit the display on the client
	INSERT INTO @vouchers
	SELECT TOP 10
		A.strBillId
		,A.intEntityVendorId
		,B.intPurchaseDetailId
		,B.intContractDetailId
		,B.intScaleTicketId
		,B.intInventoryReceiptChargeId
		,B.intInventoryReceiptItemId
		,B.intInventoryShipmentChargeId
		,B.intLoadDetailId
		,B.intLoadShipmentCostId
		,B.intCustomerStorageId
		,B.intSettleStorageId
		,B.intItemId
		,A.intTransactionType
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherPayable C
		ON 	C.intTransactionType = A.intTransactionType
		AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
		AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
		AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
		AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
		AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
		AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadDetailId,-1)
		AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
		AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
		AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
		AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
		AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(B.intCustomerStorageId,-1)
		AND ISNULL(C.intSettleStorageId,-1) = ISNULL(B.intSettleStorageId,-1)
		AND ISNULL(C.intItemId,-1) = ISNULL(B.intItemId,-1)
	
	IF EXISTS(SELECT 1 FROM @vouchers)
	BEGIN
		--IF THERE IS A VOUCHERS CREATED, DELETE ONLY IF QTY TO BILL IS 0
		DELETE A
		OUTPUT deleted.intVoucherPayableId
			,deleted.intEntityVendorId
			,deleted.intPurchaseDetailId
			,deleted.intContractDetailId
			,deleted.intScaleTicketId
			,deleted.intInventoryReceiptChargeId
			,deleted.intInventoryReceiptItemId
			,deleted.intInventoryShipmentChargeId
			,deleted.intLoadShipmentDetailId
			,deleted.intLoadShipmentCostId
			,deleted.intCustomerStorageId
			,deleted.intSettleStorageId
			,deleted.intItemId
			,deleted.intTransactionType
		INTO @payablesDeleted
		FROM tblAPVoucherPayable A
		INNER JOIN @vouchers B ON A.intTransactionType = B.intTransactionType
			AND	ISNULL(A.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			AND ISNULL(A.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			AND ISNULL(A.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			AND ISNULL(A.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			AND ISNULL(A.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			AND ISNULL(A.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			AND ISNULL(A.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			AND ISNULL(A.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			AND ISNULL(A.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
			AND ISNULL(A.intCustomerStorageId,-1) = ISNULL(B.intCustomerStorageId,-1)
			AND ISNULL(A.intSettleStorageId,-1) = ISNULL(B.intSettleStorageId,-1)
			AND ISNULL(A.intItemId,-1) = ISNULL(A.intItemId,-1)
		WHERE A.dblQuantityToBill = 0

		SET @recordCountDeleted = @recordCountDeleted + @@ROWCOUNT;

		--REMOVE TAXES STAGING
		DELETE A
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @payablesDeleted B
			ON A.intVoucherPayableId = B.intVoucherPayableId

		--REMOVE FROM @vouchers the deleted
		DELETE A
		FROM @vouchers A
		INNER JOIN @payablesDeleted B ON A.intTransactionType = B.intTransactionType
			AND	ISNULL(A.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			AND ISNULL(A.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			AND ISNULL(A.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			AND ISNULL(A.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			AND ISNULL(A.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			AND ISNULL(A.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			AND ISNULL(A.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			AND ISNULL(A.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			AND ISNULL(A.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
			AND ISNULL(A.intCustomerStorageId,-1) = ISNULL(B.intCustomerStorageId,-1)
			AND ISNULL(A.intSettleStorageId,-1) = ISNULL(B.intSettleStorageId,-1)
			AND ISNULL(A.intItemId,-1) = ISNULL(B.intItemId,-1)
	END

	--IF THERE IS STILL VOUCHERS TO DELETE, MEANS IT IS NOT VALID AS THERE ARE VOUCHERS CREATED AND THERE STILL REMAINING QTY TO BILL
	IF EXISTS(SELECT 1 FROM @vouchers)
	BEGIN
		SELECT @voucherIds = COALESCE(@voucherIds + ',', '') +  strBillId
		FROM @vouchers
		SET @voucherIds = 'Unable to delete payable. Voucher(s) ' + @voucherIds + ' have been created.';
		RAISERROR(@voucherIds, 16, 1);
		RETURN;
	END
	ELSE
	BEGIN
		--NO VOUCHER CREATED
		DELETE A
		OUTPUT deleted.intVoucherPayableId
			,deleted.intEntityVendorId
			,deleted.intPurchaseDetailId
			,deleted.intContractDetailId
			,deleted.intScaleTicketId
			,deleted.intInventoryReceiptChargeId
			,deleted.intInventoryReceiptItemId
			,deleted.intInventoryShipmentChargeId
			,deleted.intLoadShipmentDetailId
			,deleted.intLoadShipmentCostId
			,deleted.intCustomerStorageId
			,deleted.intSettleStorageId
			,deleted.intItemId
			,deleted.intTransactionType
		INTO @payablesDeleted
		FROM tblAPVoucherPayable A
		INNER JOIN @voucherPayable B ON A.intTransactionType = B.intTransactionType
			AND ISNULL(A.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)
			AND ISNULL(A.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)
			AND ISNULL(A.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)
			AND ISNULL(A.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)
			AND ISNULL(A.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)
			AND ISNULL(A.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)
			AND ISNULL(A.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)
			AND ISNULL(A.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)
			AND ISNULL(A.intLoadShipmentCostId,-1) = ISNULL(B.intLoadShipmentCostId,-1)
			AND ISNULL(A.intCustomerStorageId,-1) = ISNULL(B.intCustomerStorageId,-1)
			AND ISNULL(A.intSettleStorageId,-1) = ISNULL(B.intSettleStorageId,-1)
			AND ISNULL(A.intItemId,-1) = ISNULL(B.intItemId,-1)
		LEFT JOIN @vouchers C ON ISNULL(A.intEntityVendorId,-1) = ISNULL(C.intEntityVendorId,-1)
			AND ISNULL(A.intPurchaseDetailId,-1) = ISNULL(C.intPurchaseDetailId,-1)
			AND ISNULL(A.intContractDetailId,-1) = ISNULL(C.intContractDetailId,-1)
			AND ISNULL(A.intScaleTicketId,-1) = ISNULL(C.intScaleTicketId,-1)
			AND ISNULL(A.intInventoryReceiptChargeId,-1) = ISNULL(C.intInventoryReceiptChargeId,-1)
			AND ISNULL(A.intInventoryReceiptItemId,-1) = ISNULL(C.intInventoryReceiptItemId,-1)
			AND ISNULL(A.intInventoryShipmentChargeId,-1) = ISNULL(C.intInventoryShipmentChargeId,-1)
			AND ISNULL(A.intLoadShipmentDetailId,-1) = ISNULL(C.intLoadShipmentDetailId,-1)
			AND ISNULL(A.intLoadShipmentCostId,-1) = ISNULL(C.intLoadShipmentCostId,-1)
			AND ISNULL(A.intCustomerStorageId,-1) = ISNULL(C.intCustomerStorageId,-1)
			AND ISNULL(A.intSettleStorageId,-1) = ISNULL(C.intSettleStorageId,-1)
			AND ISNULL(A.intItemId,-1) = ISNULL(C.intItemId,-1)
		WHERE C.intEntityVendorId IS NULL --make sure to delete only if no voucher created

		SET @recordCountDeleted = @recordCountDeleted + @@ROWCOUNT;

		--REMOVE TAXES STAGING
		DELETE A
		FROM tblAPVoucherPayableTaxStaging A
		INNER JOIN @payablesDeleted B
			ON A.intVoucherPayableId = B.intVoucherPayableId
	END

	IF @recordCountDeleted = 0
	BEGIN
		RAISERROR('No payables record to delete.', 16, 1);
		RETURN;
	END

	IF @recordCountDeleted > 0 AND @recordCountToDelete != @recordCountDeleted
	BEGIN
		RAISERROR('Record count deleted mismatch.', 16, 1);
		RETURN;
	END
END

IF @transCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION
		END
		ELSE IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION
		END
	END		
ELSE
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION  @SavePoint
		END
	END	

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	-- ELSE
	-- 	BEGIN
	-- 		IF (XACT_STATE()) = -1
	-- 		BEGIN
	-- 			ROLLBACK TRANSACTION  @SavePoint
	-- 		END
	-- 	END	

	SET @error = @ErrorMessage;
	
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH
