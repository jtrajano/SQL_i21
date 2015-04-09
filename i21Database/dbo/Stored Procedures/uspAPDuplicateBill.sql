﻿CREATE PROCEDURE [dbo].[uspAPDuplicateBill]
	@BillIds NVARCHAR(MAX),
	@userId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tmpBillData (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE ([intBillId])
);

INSERT INTO #tmpBillData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@BillIds)

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
		[strBillId],
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
		ISNULL(@userId, intEntityId)
	FROM tblAPBill
	WHERE intBillId IN (SELECT [intBillId] FROM #tmpBillData)

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
	WHERE intBillId IN (SELECT [intBillId] FROM #tmpBillData)

END
