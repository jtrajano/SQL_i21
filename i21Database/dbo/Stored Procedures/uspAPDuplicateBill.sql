CREATE PROCEDURE [dbo].[uspAPDuplicateBill]
	@billId INT,
	@userId INT,
	@billCreatedId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

BEGIN TRANSACTION #duplicateBill
SAVE TRANSACTION #duplicateBill

DECLARE @generatedBillRecordId NVARCHAR(50);
EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

--DUPLICATING tblAPBill
IF OBJECT_ID('tempdb..#tmpDuplicateBill') IS NOT NULL DROP TABLE #tmpDuplicateBill

SELECT * INTO #tmpDuplicateBill FROM tblAPBill WHERE intBillId = @billId
ALTER TABLE #tmpDuplicateBill DROP COLUMN intBillId

UPDATE A
	SET ysnPosted = 0
	,ysnPaid = 0
	,dblPayment = 0
	,dblAmountDue = 0
	,dblWithheld = 0
	,strVendorOrderNumber = NULL
	,strBillId = @generatedBillRecordId
	,intEntityId = @userId
FROM #tmpDuplicateBill A

--INSERT INTO tblAPBill(
--		[strVendorOrderNumber], 
--		[intTermsId],
--		[intTaxId],
--		[dtmDate],            
--		[dtmDueDate],
--		[intAccountId],
--		[strReference],
--		[dblTotal],
--		[dblSubtotal],
--		[ysnPosted],
--		[ysnPaid],
--		[strBillId],
--		[dblAmountDue],
--		[dtmDatePaid],
--		[dtmDiscountDate],
--		[intUserId],
--		[intConcurrencyId],
--		[dtmBillDate],
--		[intEntityVendorId],
--		[dblWithheld],
--		[dblDiscount],
--		[dblBillTax],
--		[dblPayment],
--		[dblInterest],
--		[intTransactionType],
--		[intPurchaseOrderId],
--		[intShipFromId],
--		[intShipToId],
--		[intStoreLocationId],
--		[intContactId],
--		[intOrderById],
--		[intEntityId]
--	)
--	SELECT 
--		NULL, 
--		[intTermsId],
--		[intTaxId],
--		[dtmDate],            
--		[dtmDueDate],
--		[intAccountId],
--		[strReference],
--		[dblTotal],
--		[dblSubtotal],
--		0,
--		0,
--		@generatedBillRecordId,
--		[dblTotal],
--		[dtmDatePaid],
--		[dtmDiscountDate],
--		[intUserId],
--		[intConcurrencyId],
--		GETDATE(),
--		[intEntityVendorId],
--		[dblWithheld],
--		[dblDiscount],
--		[dblBillTax],
--		0,
--		[dblInterest],
--		1,
--		[intPurchaseOrderId],
--		[intShipFromId],
--		[intShipToId],
--		[intStoreLocationId],
--		[intContactId],
--		[intOrderById],
--		ISNULL(@userId, intEntityId)
--	FROM tblAPBill
--	WHERE intBillId = @billId
INSERT INTO tblAPBill
SELECT * FROM #tmpDuplicateBill

SET @billCreatedId = SCOPE_IDENTITY();

--DUPLICATE tblAPBillDetail
IF OBJECT_ID('tempdb..#tmpDuplicateBillDetail') IS NOT NULL DROP TABLE #tmpDuplicateBillDetail

DECLARE @billDetailTaxes TABLE(intCreatedBillDetailId INT, originalBillDetailId INT)

SELECT * INTO #tmpDuplicateBillDetail FROM tblAPBillDetail WHERE intBillId = @billId
--ALTER TABLE #tmpDuplicateBillDetail DROP COLUMN intBillDetailId

UPDATE A
	SET A.intBillId = @billCreatedId
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
			[int1099Code], 
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
			[int1099Code], 
			[int1099Category], 
			[intLineNo]
		)
		OUTPUT inserted.intBillDetailId, A.intBillDetailId INTO @billDetailTaxes(intCreatedBillDetailId, originalBillDetailId); --get the new and old bill detail id

--INSERT INTO tblAPBillDetail
--SELECT * FROM #tmpDuplicateBillDetail A

--INSERT INTO tblAPBillDetail(
--		[intBillId],
--		[strMiscDescription],
--		[strComment], 
--		[intAccountId],
--		[dblTotal],
--		[intConcurrencyId], 
--		[dblQtyOrdered], 
--		[dblQtyReceived], 
--		[dblDiscount], 
--		[dblCost], 
--		[dblLandedCost], 
--		[dblWeight], 
--		[dblVolume], 
--		[dtmExpectedDate], 
--		[int1099Code], 
--		[int1099Category], 
--		[intTaxId],
--		[intLineNo]
--	)
--	SELECT
--		@billCreatedId,
--		[strMiscDescription],
--		[strComment], 
--		[intAccountId],
--		[dblTotal],
--		[intConcurrencyId], 
--		[dblQtyOrdered], 
--		[dblQtyReceived], 
--		[dblDiscount], 
--		[dblCost], 
--		[dblLandedCost], 
--		[dblWeight], 
--		[dblVolume], 
--		[dtmExpectedDate], 
--		[int1099Code], 
--		[int1099Category], 
--		[intTaxId],
--		[intLineNo]
--	FROM tblAPBillDetail
--	WHERE intBillId = @billId

IF OBJECT_ID('tempdb..#tmpDuplicateBillDetailTaxes') IS NOT NULL DROP TABLE #tmpDuplicateBillDetailTaxes

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

COMMIT TRANSACTION #duplicateBill
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
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Problem duplicating bill.' + CHAR(13) + 
			'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
			' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @@TRANCOUNT > 0
    BEGIN
		ROLLBACK TRANSACTION #duplicateBill
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
    END
END CATCH