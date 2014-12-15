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

DECLARE @InsertedData TABLE (intBillId INT, intType INT)

INSERT INTO #tmpRecurringData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@recurrings)

SELECT * INTO #tmpRecurringBill FROM tblAPRecurringTransaction
WHERE intRecurringId IN (SELECT intRecurringId FROM #tmpRecurringData)

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

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
OUTPUT inserted.intBillId, inserted.intTransactionType INTO @InsertedData
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
	NULL,
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

--Update strBillId
DECLARE @type INT, @billKey INT, @billId NVARCHAR(50);
SELECT * INTO #tmpInsertedBill FROM @InsertedData

WHILE EXISTS(SELECT	1 FROM #tmpInsertedBill)
BEGIN
		
	SELECT TOP(1) @billKey = intBillId, @type = intType FROM #tmpInsertedBill

	IF @type = 1
		EXEC uspSMGetStartingNumber 9, @billId OUT
	ELSE IF @type = 3
		EXEC uspSMGetStartingNumber 18, @billId OUT
	ELSE IF @type = 2
		EXEC uspSMGetStartingNumber 20, @billId OUT

	UPDATE A
		SET A.strBillId = @billId
	FROM tblAPBill A
	WHERE A.intBillId = @billKey

	DELETE FROM #tmpInsertedBill
	WHERE intBillId = @billKey

END
	
ALTER TABLE tblAPBill
ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

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