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

BEGIN TRANSACTION

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

DECLARE @count INT = (SELECT COUNT(*) FROM #tmpRecurringBill);
DECLARE @counter INT = 0;
DECLARE @billId INT, @generatedBillId INT, @type INT;
DECLARE @billRecordId NVARCHAR(50)

WHILE @count != @counter
BEGIN

	SET @counter = @counter + 1
	SELECT TOP(@counter) @billId = intTransactionId FROM #tmpRecurringBill
	
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
		[intEntityVendorId],
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
		[intEntityVendorId],
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
	WHERE intBillId IN (@billId)

	SET @generatedBillId = SCOPE_IDENTITY()

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[strMiscDescription],
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
		@generatedBillId,
		[strMiscDescription],
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
	WHERE intBillId IN (@billId)

	--Update strBillId

	SELECT TOP(1) @type = intTransactionType FROM tblAPBill WHERE intBillId = @generatedBillId

	IF @type = 1 OR @type = 6
		EXEC uspSMGetStartingNumber 9, @billRecordId OUT
	ELSE IF @type = 3
		EXEC uspSMGetStartingNumber 18, @billRecordId OUT
	ELSE IF @type = 2
		EXEC uspSMGetStartingNumber 20, @billRecordId OUT

	UPDATE A
		SET A.strBillId = @billRecordId
	FROM tblAPBill A
	WHERE A.intBillId = @generatedBillId

	--Validate
	IF (SELECT COUNT(*) FROM tblAPBillDetail WHERE intBillId = @generatedBillId) != (SELECT COUNT(*) FROM tblAPBillDetail WHERE intBillId = @billId)
	BEGIN
		RAISERROR('There was an error duplicating bill detail', 16, 1);
	END

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
		[strTransactionId]		= B.strBillId, 
		[strTransactionCreated]	= @billRecordId, 
		[dtmDateProcessed]		= GETDATE(), 
		[strReference]			= D.strReference, 
		[dtmNextProcess]		= D.dtmNextProcess, 
		[dtmLastProcess]		= D.dtmLastProcess,
		[intTransactionType]	= 1
	FROM tblAPBill B
		INNER JOIN #tmpRecurringBill D ON B.intBillId = D.intTransactionId
		WHERE B.intBillId = @billId
END
	
ALTER TABLE tblAPBill
ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

IF @@ERROR > 0
BEGIN
	ROLLBACK TRANSACTION
END
ELSE
BEGIN
	COMMIT TRANSACTION
END

END