CREATE PROCEDURE [dbo].[uspAPRecurBill]
	@billId INT,
	@billDate DATETIME,
	@userId INT,
	@newBillId NVARCHAR(50) OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @InsertedData TABLE (intBillId INT, intType INT)
	DECLARE @generatedBillId INT
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
	OUTPUT inserted.intBillId, inserted.intTransactionType INTO @InsertedData
	SELECT 
		[strVendorOrderNumber], 
		[intTermsId],
		[intTaxId],
		@billDate,            
		dbo.fnGetDueDateBasedOnTerm(@billDate, intTermsId),
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
	DECLARE @type INT, @billKey INT, @billRecordId NVARCHAR(50);
	SELECT * INTO #tmpInsertedBill FROM @InsertedData

	WHILE EXISTS(SELECT	1 FROM #tmpInsertedBill)
	BEGIN
		
		SELECT TOP(1) @billKey = intBillId, @type = intType FROM #tmpInsertedBill

		IF @type = 1
			EXEC uspSMGetStartingNumber 9, @billRecordId OUT
		ELSE IF @type = 3
			EXEC uspSMGetStartingNumber 18, @billRecordId OUT
		ELSE IF @type = 2
			EXEC uspSMGetStartingNumber 20, @billRecordId OUT

		UPDATE A
			SET A.strBillId = @billRecordId
		FROM tblAPBill A
		WHERE A.intBillId = @billKey

		SET @newBillId = @billRecordId

		DELETE FROM #tmpInsertedBill
		WHERE intBillId = @billKey

	END
	
	ALTER TABLE tblAPBill
	ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

END