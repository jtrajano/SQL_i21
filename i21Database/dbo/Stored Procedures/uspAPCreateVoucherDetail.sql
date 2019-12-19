﻿CREATE PROCEDURE [dbo].[uspAPCreateVoucherDetail]
	@billId INT,
	@voucherPODetails AS VoucherPODetail READONLY,
	@voucherNonInvDetails AS VoucherDetailNonInventory READONLY,
	@voucherDetailReceipt AS [VoucherDetailReceipt] READONLY,
	@voucherDetailReceiptCharge AS [VoucherDetailReceiptCharge] READONLY,
	@voucherNonInvDetailContracts AS VoucherDetailNonInvContract READONLY,
	@voucherDetailCC AS VoucherDetailCC READONLY,
	@voucherDetailStorage AS VoucherDetailStorage READONLY,
	@voucherDetailLoadNonInv AS VoucherDetailLoadNonInv READONLY,
	@voucherDetailClaim AS VoucherDetailClaim READONLY,
	@voucherDetailDirect AS VoucherDetailDirectInventory READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @voucherIds AS Id;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	IF EXISTS(SELECT 1 FROM @voucherPODetails)
	BEGIN
		EXEC uspAPCreateVoucherPODetail @billId, @voucherPODetails
	END

	IF EXISTS(SELECT 1 FROM @voucherNonInvDetails)
	BEGIN
		EXEC uspAPCreateVoucherNonInvDetail @billId, @voucherNonInvDetails
	END

	IF EXISTS(SELECT 1 FROM @voucherDetailReceipt)
	BEGIN
		EXEC uspAPCreateVoucherDetailReceipt @billId, @voucherDetailReceipt
	END

	IF EXISTS(SELECT 1 FROM @voucherDetailReceiptCharge)
	BEGIN
		EXEC uspAPCreateVoucherDetailReceiptCharge @billId, @voucherDetailReceiptCharge
	END 

	IF EXISTS(SELECT 1 FROM @voucherNonInvDetailContracts)
	BEGIN
		EXEC uspAPCreateVoucherDetailNonInvContract @billId, @voucherNonInvDetailContracts
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailCC)
	BEGIN
		EXEC uspAPCreateVoucherDetailCC @billId, @voucherDetailCC
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailStorage)
	BEGIN
		EXEC uspAPCreateVoucherDetailStorage  @billId, @voucherDetailStorage
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailLoadNonInv)
	BEGIN
		EXEC uspAPCreateVoucherDetailLoadNonInv  @billId, @voucherDetailLoadNonInv
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailClaim)
	BEGIN
		EXEC uspAPCreateVoucherDetailClaim  @billId, @voucherDetailClaim
	END 

	IF EXISTS(SELECT 1 FROM @voucherDetailDirect)
	BEGIN
		EXEC uspAPCreateVoucherDetailDirectInventory  @billId, @voucherDetailDirect
	END 

	EXEC uspAPUpdateVoucherDetailForeignRate @voucherId = @billId

	UPDATE A
	SET
		A.int1099Form = CASE WHEN B.intTransactionType IN (1, 3, 9, 14) THEN A.int1099Form ELSE 0 END,
		A.int1099Category = CASE WHEN B.intTransactionType IN (1, 3, 9, 14) THEN A.int1099Category ELSE 0 END,
		A.dbl1099 = CASE WHEN B.intTransactionType IN (1, 3, 9, 14) THEN A.dbl1099 ELSE 0 END
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	WHERE B.intBillId = @billId

	INSERT INTO @voucherIds
	SELECT @billId
	EXEC uspAPUpdateVoucherTotal @voucherIds

IF @transCount = 0 COMMIT TRANSACTION

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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH