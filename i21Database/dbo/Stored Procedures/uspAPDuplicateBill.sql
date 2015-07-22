CREATE PROCEDURE [dbo].[uspAPDuplicateBill]
	@billId INT,
	@userId INT,
	@billCreatedId INT OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

DECLARE @generatedBillRecordId NVARCHAR(50);
EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

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

IF OBJECT_ID('tempdb..#tmpDuplicateBillDetail') IS NOT NULL DROP TABLE #tmpDuplicateBillDetail

SELECT * INTO #tmpDuplicateBillDetail FROM tblAPBillDetail WHERE intBillId = @billId
ALTER TABLE #tmpDuplicateBillDetail DROP COLUMN intBillDetailId

UPDATE A
	SET A.intBillId = @billCreatedId
FROM #tmpDuplicateBillDetail A

INSERT INTO tblAPBillDetail
SELECT * FROM #tmpDuplicateBillDetail


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

END

GOTO DONE;

DONE:
COMMIT TRANSACTION;
RETURN;

UNDO:
ROLLBACK TRANSACTION;
RETURN;