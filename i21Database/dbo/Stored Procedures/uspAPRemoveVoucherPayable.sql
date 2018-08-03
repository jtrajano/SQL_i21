CREATE PROCEDURE [dbo].[uspAPRemoveVoucherPayable]
	@voucherPayable AS VoucherPayable READONLY,
	@throwError BIT = 0,
	@error NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
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
	,intInventoryShipmentItemId INT NULL
	,intInventoryShipmentChargeId INT NULL
	,intLoadShipmentDetailId INT NULL
	);
DECLARE @payablesDeleted AS TABLE(
	intEntityVendorId INT NULL
	,intPurchaseDetailId INT NULL
	,intContractDetailId INT NULL
	,intScaleTicketId INT NULL
	,intInventoryReceiptChargeId INT NULL
	,intInventoryReceiptItemId INT NULL
	,intInventoryShipmentItemId INT NULL
	,intInventoryShipmentChargeId INT NULL
	,intLoadShipmentDetailId INT NULL
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

	--Validate, there should be no voucher created
	INSERT INTO @vouchers
	SELECT TOP 10
		A.strBillId
		,A.intEntityVendorId
		,B.intPurchaseDetailId
		,B.intContractDetailId
		,B.intScaleTicketId
		,B.intInventoryReceiptChargeId
		,B.intInventoryReceiptItemId
		,B.intLoadDetailId
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherPayable C
		ON C.intPurchaseDetailId = B.intPurchaseDetailId
		AND C.intContractDetailId = B.intContractDetailId
		AND C.intScaleTicketId = B.intScaleTicketId
		AND C.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
		AND C.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		AND C.intLoadShipmentDetailId = B.intLoadDetailId
		AND C.intInventoryShipmentItemId = B.intInventoryShipmentItemId
		AND C.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
		AND C.intEntityVendorId = A.intEntityVendorId
	
	IF EXISTS(SELECT 1 FROM @vouchers)
	BEGIN
		--IF THERE IS A VOUCHERS CREATED, DELETE ONLY IF QTY TO BILL IS 0
		DELETE A
		OUTPUT deleted.intEntityVendorId
			,deleted.intPurchaseDetailId
			,deleted.intContractDetailId
			,deleted.intScaleTicketId
			,deleted.intInventoryReceiptChargeId
			,deleted.intInventoryReceiptItemId
			,deleted.intLoadShipmentDetailId
		INTO @payablesDeleted
		FROM tblAPVoucherPayable A
		INNER JOIN @vouchers B ON A.intEntityVendorId = B.intEntityVendorId
			AND A.intPurchaseDetailId = B.intPurchaseDetailId
			AND A.intContractDetailId = B.intContractDetailId
			AND A.intScaleTicketId = B.intScaleTicketId
			AND A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
			AND A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
			AND A.intInventoryShipmentItemId = B.intInventoryShipmentItemId
			AND A.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
			AND A.intLoadShipmentDetailId = B.intLoadShipmentDetailId
		WHERE A.dblQuantityToBill = 0

		SET @recordCountDeleted = @recordCountDeleted + @@ROWCOUNT;

		--REMOVE FROM @vouchers the deleted
		DELETE A
		FROM @vouchers A
		INNER JOIN @payablesDeleted B ON A.intEntityVendorId = B.intEntityVendorId
			AND A.intPurchaseDetailId = B.intPurchaseDetailId
			AND A.intContractDetailId = B.intContractDetailId
			AND A.intScaleTicketId = B.intScaleTicketId
			AND A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
			AND A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
			AND A.intInventoryShipmentItemId = B.intInventoryShipmentItemId
			AND A.intInventoryShipmentChargeId = B.intInventoryShipmentChargeId
			AND A.intLoadShipmentDetailId = B.intLoadShipmentDetailId
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
		FROM tblAPVoucherPayable A
		INNER JOIN @voucherPayable B ON A.intEntityVendorId = B.intEntityVendorId
			AND A.intPurchaseDetailId = B.intPurchaseDetailId
			AND A.intContractDetailId = B.intContractDetailId
			AND A.intScaleTicketId = B.intScaleTicketId
			AND A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
			AND A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
			AND A.intLoadShipmentDetailId = B.intLoadShipmentDetailId
		LEFT JOIN @vouchers C ON A.intEntityVendorId = C.intEntityVendorId
			AND A.intPurchaseDetailId = C.intPurchaseDetailId
			AND A.intContractDetailId = C.intContractDetailId
			AND A.intScaleTicketId = C.intScaleTicketId
			AND A.intInventoryReceiptChargeId = C.intInventoryReceiptChargeId
			AND A.intInventoryReceiptItemId = C.intInventoryReceiptItemId
			AND A.intInventoryShipmentItemId = C.intInventoryShipmentItemId
			AND A.intInventoryShipmentChargeId = C.intInventoryShipmentChargeId
			AND A.intLoadShipmentDetailId = C.intLoadShipmentDetailId
		WHERE C.intEntityVendorId IS NULL --make sure to delete only if no voucher created

		SET @recordCountDeleted = @recordCountDeleted + @@ROWCOUNT;
	END

	IF @recordCountToDelete != @recordCountDeleted
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
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION  @SavePoint
			END
		END	

	SET @error = @ErrorMessage;
	
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH
