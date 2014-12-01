CREATE PROCEDURE [dbo].[uspAPBillRecurring]
	@recurrings NVARCHAR(MAX),
	@userId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tmpRecurringData (
	[intRecurringId] [int] PRIMARY KEY,
	UNIQUE ([intRecurringId])
);

DECLARE @InsertedData TABLE (intBillId INT)

INSERT INTO #tmpRecurringData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@recurrings)

SELECT * INTO #tmpRecurringBill FROM tblAPRecurringTransaction
WHERE intRecurringId IN (SELECT intRecurringId FROM #tmpRecurringData)

INSERT INTO tblAPBill(
		[strVendorOrderNumber], 
		[intTermsId],
		[intTaxId],
		[dtmDate],            
		[dtmDueDate],
		[intAccountId],
		[strReference],
		[dblTotal],
		[dblSubtotal],
		[ysnPosted],
		[ysnPaid],
		[strBillId],
		[dblAmountDue],
		[dtmDatePaid],
		[dtmDiscountDate],
		[intUserId],
		[intConcurrencyId],
		[dtmBillDate],
		[intVendorId],
		[dblWithheld],
		[dblDiscount],
		[dblBillTax],
		[dblPayment],
		[dblInterest],
		[intTransactionType],
		[intPurchaseOrderId],
		[intShipFromId],
		[intShipToId],
		[intStoreLocationId],
		[intContactId],
		[intOrderById],
		[intEntityId]
	)
	OUTPUT inserted.intBillId INTO @InsertedData
	SELECT 
		[strVendorOrderNumber], 
		[intTermsId],
		[intTaxId],
		[dtmDate],            
		[dtmDueDate],
		[intAccountId],
		[strReference],
		[dblTotal],
		[dblSubtotal],
		0,
		0,
		[strBillId],
		[dblAmountDue],
		[dtmDatePaid],
		[dtmDiscountDate],
		[intUserId],
		[intConcurrencyId],
		GETDATE(),
		[intVendorId],
		[dblWithheld],
		[dblDiscount],
		[dblBillTax],
		0,
		[dblInterest],
		1,
		[intPurchaseOrderId],
		[intShipFromId],
		[intShipToId],
		[intStoreLocationId],
		[intContactId],
		[intOrderById],
		@userId
	FROM tblAPBill
	WHERE intBillId IN (SELECT intTransactionId FROM #tmpRecurringBill)

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[strDescription],
		[strComment], 
		[intAccountId],
		[dblTotal],
		[intConcurrencyId], 
		[dblQtyOrdered], 
		[dblQtyReceived], 
		[dblDiscount], 
		[dblCost], 
		[dblLandedCost], 
		[dblWeight], 
		[dblVolume], 
		[dtmExpectedDate], 
		[int1099Code], 
		[int1099Category], 
		[intTaxId],
		[intLineNo]
	)
	SELECT
		[intBillId],
		[strDescription],
		[strComment], 
		[intAccountId],
		[dblTotal],
		[intConcurrencyId], 
		[dblQtyOrdered], 
		[dblQtyReceived], 
		[dblDiscount], 
		[dblCost], 
		[dblLandedCost], 
		[dblWeight], 
		[dblVolume], 
		[dtmExpectedDate], 
		[int1099Code], 
		[int1099Category], 
		[intTaxId],
		[intLineNo]
	FROM tblAPBillDetail
	WHERE intBillId IN (SELECT intTransactionId FROM #tmpRecurringBill)

	--Create History
	INSERT INTO tblAPRecurringHistory(
		[strTransactionId], 
		[strTransactionCreated], 
		[dtmDateProcessed], 
		[strReference], 
		[dtmNextProcess], 
		[dtmLastProcess], 
		[intTransactionType]
	)
	SELECT 
		[strTransactionId]		= C.strBillId, 
		[strTransactionCreated]	= B.strBillId, 
		[dtmDateProcessed]		= GETDATE(), 
		[strReference]			= D.strReference, 
		[dtmNextProcess]		= D.dtmNextProcess, 
		[dtmLastProcess]		= D.dtmLastProcess,
		[intTransactionType]	= 1
	FROM @InsertedData A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
		INNER JOIN tblAPBill C ON B.strVendorOrderNumber = C.strVendorOrderNumber
		INNER JOIN #tmpRecurringBill D ON C.intBillId = D.intTransactionId

END
