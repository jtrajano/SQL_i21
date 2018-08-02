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

DECLARE @vouchers AS TABLE(strBillId NVARCHAR(50));
DECLARE @voucherIds NVARCHAR(MAX);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPRemoveVoucherPayable';
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF EXISTS(SELECT TOP 1 1 FROM @voucherPayable)
BEGIN

	--Validate, there should be no voucher created
	INSERT INTO @vouchers
	SELECT TOP 10
		A.strBillId
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherPayable C
		ON C.intPurchaseDetailId = B.intPurchaseDetailId
		AND C.intContractDetailId = B.intContractDetailId
		AND C.intScaleTicketId = B.intScaleTicketId
		AND C.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
		AND C.intInventoryReceiptItemId = B.intInventoryReceiptItemId
		AND C.intLoadShipmentDetailId = B.intLoadShipmentDetailId
		AND C.intEntityVendorId = A.intEntityVendorId
	
	IF EXISTS(SELECT 1 FROM @vouchers)
	BEGIN
		SELECT @voucherIds = COALESCE(@voucherIds + ',', '') +  strBillId
		FROM @vouchers
		SET @voucherIds = 'Unable to delete payable. Voucher(s) ' + @voucherIds + ' have been created.';
		RAISERROR(@voucherIds, 16, 1);
		RETURN;
	END

	DELETE A
	FROM tblAPVoucherPayable A
	INNER JOIN @voucherPayable B ON A.intEntityVendorId = B.intEntityVendorId
	AND A.intPurchaseDetailId = B.intPurchaseDetailId
	AND A.intContractDetailId = B.intContractDetailId
	AND A.intScaleTicketId = B.intScaleTicketId
	AND A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	AND A.intInventoryReceiptItemId = B.intInventoryReceiptItemId
	AND A.intLoadShipmentDetailId = B.intLoadShipmentDetailId
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
