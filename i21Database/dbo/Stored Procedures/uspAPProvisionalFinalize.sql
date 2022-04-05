CREATE PROCEDURE [dbo].[uspAPProvisionalFinalize]
	@billId INT,
	@percentage DECIMAL(18, 2),
	@userId INT,
	@createdVoucher INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @postSuccess BIT = 0;
DECLARE @postParam NVARCHAR(50);
DECLARE @batchId NVARCHAR(50);
DECLARE @error NVARCHAR(200);
DECLARE @debitMemoRecordNum NVARCHAR(50);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateBillReversal';
DECLARE @transCount INT;

BEGIN TRY

--PERCENTAGE LOGIC AND VALIDATION

--MAKE SURE BILL TYPE ONLY
IF (SELECT intTransactionType FROM tblAPBill WHERE intBillId = @billId) <> 16
BEGIN
	RAISERROR('Invalid transaction type for provisional finalize.', 16, 1);
	RETURN;
END

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

DECLARE @generatedBillRecordId NVARCHAR(50);
DECLARE @vendorId INT;
DECLARE @locationId INT;
DECLARE @requireApproval BIT = 0;
DECLARE @currencyId INT;
DECLARE @Total NUMERIC (18, 6);
DECLARE @DueDate DATE;

--DUPLICATE tblAPBill
IF OBJECT_ID('tempdb..#tmpDuplicateBill') IS NOT NULL DROP TABLE #tmpDuplicateBill

--SELECT * INTO #tmpDuplicateBill FROM tblAPProvisional WHERE intBillId = @billId
SELECT * INTO #tmpDuplicateBill FROM tblAPBill WHERE intBillId = @billId
ALTER TABLE #tmpDuplicateBill DROP COLUMN intBillId

EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

UPDATE A
	SET A.strBillId = @generatedBillRecordId
	,A.intTransactionType = 1
	,A.intEntityId = @userId
FROM #tmpDuplicateBill A

INSERT INTO tblAPBill SELECT * FROM #tmpDuplicateBill

SET @createdVoucher = SCOPE_IDENTITY();

--DUPLICATE tblAPBillDetail
IF OBJECT_ID('tempdb..#tmpDuplicateBillDetail') IS NOT NULL DROP TABLE #tmpDuplicateBillDetail

DECLARE @billDetailTaxes TABLE(intCreatedBillDetailId INT, originalBillDetailId INT)

--SELECT * INTO #tmpDuplicateBillDetail FROM tblAPProvisionalDetail WHERE intBillId = @billId ORDER BY intBillDetailId
SELECT * INTO #tmpDuplicateBillDetail FROM tblAPBillDetail WHERE intBillId = @billId ORDER BY intBillDetailId

UPDATE A
	SET A.intBillId = @createdVoucher
FROM #tmpDuplicateBillDetail A

MERGE INTO tblAPBillDetail
USING #tmpDuplicateBillDetail A
ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT(
			[intBillId],
			[strMiscDescription],
			[strComment], 
			[intAccountId],
			[intItemId],
			[intInventoryReceiptItemId],
			[intInventoryReceiptChargeId],
			[intPurchaseDetailId],
			[intContractHeaderId],
			[intContractDetailId],
			[intPrepayTypeId],
			[intTaxGroupId],
			[dblTotal],
			[intConcurrencyId], 
			[dblQtyOrdered], 
			[dblQtyReceived], 
			[dblDiscount], 
			[dblCost], 
			[dblLandedCost], 
			[dblTax], 
			[dblPrepayPercentage], 
			[dblWeight], 
			[dblVolume], 
			[dtmExpectedDate], 
			[int1099Form], 
			[int1099Category], 
			[intLineNo]
		)
		VALUES
		(
			[intBillId],
			[strMiscDescription],
			[strComment], 
			[intAccountId],
			[intItemId],
			[intInventoryReceiptItemId],
			[intInventoryReceiptChargeId],
			[intPurchaseDetailId],
			[intContractHeaderId],
			[intContractDetailId],
			[intPrepayTypeId],
			[intTaxGroupId],
			[dblTotal],
			[intConcurrencyId], 
			[dblQtyOrdered], 
			[dblQtyReceived], 
			[dblDiscount], 
			[dblCost], 
			[dblLandedCost], 
			[dblTax], 
			[dblPrepayPercentage], 
			[dblWeight], 
			[dblVolume], 
			[dtmExpectedDate], 
			[int1099Form], 
			[int1099Category], 
			[intLineNo]
		)
		OUTPUT inserted.intBillDetailId, A.intBillDetailId INTO @billDetailTaxes(intCreatedBillDetailId, originalBillDetailId);

--DUPLICATE tblAPBillDetailTax
IF OBJECT_ID('tempdb..#tmpDuplicateBillDetailTaxes') IS NOT NULL DROP TABLE #tmpDuplicateBillDetailTaxes

-- SELECT A.* INTO #tmpDuplicateBillDetailTaxes 
-- FROM tblAPProvisionalDetailTax A
-- INNER JOIN tblAPProvisionalDetail B ON A.intBillDetailId = B.intBillDetailId
-- WHERE B.intBillId = @billId
SELECT A.* INTO #tmpDuplicateBillDetailTaxes 
FROM tblAPBillDetailTax A
INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
WHERE B.intBillId = @billId

ALTER TABLE #tmpDuplicateBillDetailTaxes DROP COLUMN intBillDetailTaxId

UPDATE A
SET A.intBillDetailId = B.intCreatedBillDetailId
FROM #tmpDuplicateBillDetailTaxes A
INNER JOIN @billDetailTaxes B ON A.intBillDetailId = B.originalBillDetailId

INSERT INTO tblAPBillDetailTax
SELECT * FROM #tmpDuplicateBillDetailTaxes

SELECT
	@vendorId = A.intEntityVendorId
	,@locationId = A.intShipToId
	,@currencyId = A.intCurrencyId
	,@Total = A.dblTotal
	,@DueDate = A.dtmDueDate
FROM tblAPBill A
WHERE A.intBillId = @createdVoucher

EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
	@type = N'AccountsPayable.view.Voucher',
	@transactionEntityId = @vendorId,
	@currentUserEntityId = @userId,
	@locationId = @locationId,
	@amount = @Total,
	@requireApproval = @requireApproval OUTPUT

IF @requireApproval = 1
BEGIN
	EXEC uspSMUnSubmitTransaction
		@type = 'AccountsPayable.view.Voucher',
		@recordId = @createdVoucher,
		@transactionNo = @generatedBillRecordId,
		@transactionEntityId = @vendorId,
		@currentUserEntityId = @userId,
		@amount = @Total, 
		@dueDate = @DueDate,
		@currencyId = @currencyId
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
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
