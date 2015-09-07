CREATE PROCEDURE [dbo].[uspAPCreateBillFromIR]
	@receiptIds NVARCHAR(MAX),
	@userId	INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @totalReceipts INT;
DECLARE @counter INT = 0;
DECLARE @receiptId INT;
DECLARE @generatedBillId INT;
DECLARE @generatedBillRecordId NVARCHAR(50);
DECLARE @APAccount INT;
DECLARE @shipFrom INT, @shipTo INT;
DECLARE @receiptLocation INT;
DECLARE @userLocation INT;

CREATE TABLE #tmpReceiptIds (
	[intInventoryReceiptId] [INT] PRIMARY KEY,
	UNIQUE ([intInventoryReceiptId])
);

CREATE TABLE #tmpReceiptBillIds (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryReceiptId] [INT],
	UNIQUE ([intBillId])
);

CREATE TABLE #tmpCreatedBillDetail (
	[intBillDetailId] [INT]
	UNIQUE ([intBillDetailId])
);

BEGIN TRANSACTION

INSERT INTO #tmpReceiptIds(intInventoryReceiptId) SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@receiptIds)

SET @totalReceipts = (SELECT COUNT(*) FROM #tmpReceiptIds)
SET @userLocation = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityId = @userId);

--Get the company location of the user to get the default ap account else get from preference
SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @userLocation)

----try to get from Gl Account
--IF @APAccount IS NULL
--	SET @APAccount = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE intAccountCategoryId = 1)

IF @APAccount IS NULL OR @APAccount <= 0
BEGIN
	RAISERROR('Please setup default AP Account', 16, 1);
	GOTO DONE
END

--Make sure all items were not yet billed.
IF NOT EXISTS(SELECT 1 FROM tblICInventoryReceiptItem A
					WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpReceiptIds)
					AND A.dblOpenReceive != A.dblBillQty)
BEGIN
	RAISERROR('All of the item in the receipt was fully billed.', 16, 1);
	GOTO DONE
END

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

WHILE @counter != @totalReceipts
BEGIN

	SET @counter = @counter + 1;
	SELECT TOP(1) @receiptId = intInventoryReceiptId FROM #tmpReceiptIds
	EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

	--IF DEFAULT LOCATION OF USER WAS DIFFERENT FROM CURRENT IR LOCATION
	SET @receiptLocation = (SELECT intLocationId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId)
	IF @userLocation != @receiptLocation
	BEGIN
		SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @receiptLocation)
		IF @APAccount IS NULL
		BEGIN
			RAISERROR('Please setup default AP Account.', 16, 1);
			GOTO DONE
		END
	END
						

	INSERT INTO tblAPBill(
		[intEntityVendorId],
		[strVendorOrderNumber], 
		[intTermsId], 
		[intShipViaId],
		[intShipFromId],
		[intShipToId],
		[dtmDate], 
		[dtmDateCreated], 
		[dtmBillDate],
		[dtmDueDate], 
		[intCurrencyId],
		[intAccountId], 
		[strBillId],
		[strReference], 
		[dblTotal], 
		[dblAmountDue],
		[intEntityId],
		[ysnPosted],
		[ysnPaid],
		[intTransactionType],
		[dblDiscount],
		[dblWithheld],
		[intStoreLocationId]
	)
	OUTPUT inserted.intBillId, @receiptId INTO #tmpReceiptBillIds(intBillId, intInventoryReceiptId)
	SELECT
		[intEntityVendorId]		=	A.intEntityVendorId,
		[strVendorOrderNumber] 	=	A.strVendorRefNo,
		[intTermsId] 			=	ISNULL(Terms.intTermsId,(SELECT TOP 1 intTermID FROM tblSMTerm WHERE LOWER(strTerm) = 'due on receipt')),
		[intShipViaId]			=	A.intShipViaId,
		[intShipFromId]			=	A.intShipFromId,
		[intShipToId]			=	A.intLocationId,
		[dtmDate] 				=	GETDATE(),
		[dtmDateCreated] 		=	GETDATE(),
		[dtmBillDate] 			=	GETDATE(),
		[dtmDueDate] 			=	GETDATE(),
		[intCurrencyId]			=	ISNULL(A.intCurrencyId,CAST((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') AS INT)),
		[intAccountId] 			=	@APAccount,
		[strBillId]				=	@generatedBillRecordId,
		[strReference] 			=	NULL,
		[dblTotal] 				=	A.dblInvoiceAmount,
		[dblAmountDue]			=	A.dblInvoiceAmount,
		[intEntityId]			=	@userId,
		[ysnPosted]				=	0,
		[ysnPaid]				=	0,
		[intTransactionType]	=	1,
		[dblDiscount]			=	0,
		[dblWithheld]			=	0,
		[intStoreLocationId]	=	A.intLocationId
	FROM tblICInventoryReceipt A
	OUTER APPLY 
	(
		SELECT 
			C.intTermsId
		FROM tblAPVendor B INNER JOIN tblEntityLocation C ON B.intEntityVendorId = C.intEntityId AND C.ysnDefaultLocation = 1
		WHERE B.intEntityVendorId = A.intEntityVendorId
	) Terms
	WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1

	SET @generatedBillId = SCOPE_IDENTITY()

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[intInventoryReceiptItemId],
		[intPurchaseDetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblTax],
		[intTaxGroupId],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[intContractDetailId],
		[intContractHeaderId],
		[intLineNo]
	)
	OUTPUT inserted.intBillDetailId INTO #tmpCreatedBillDetail(intBillDetailId)
	SELECT
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	B.intItemId,
		[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
		[intPODetailId]				=	CASE WHEN B.intLineNo <= 0 THEN NULL ELSE B.intLineNo END,
		[dblQtyOrdered]				=	B.dblOpenReceive - B.dblBillQty,
		[dblQtyReceived]			=	B.dblOpenReceive - B.dblBillQty,
		[dblTax]					=	B.dblTax,
		[intTaxGroupId]				=	B.intTaxGroupId,
		[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
		--[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, A.intLocationId, 'AP Clearing'),
		[dblTotal]					=	(B.dblOpenReceive - B.dblBillQty) * B.dblUnitCost,
		[dblCost]					=	B.dblUnitCost,
		[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E1.intContractDetailId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractDetailId
											ELSE NULL END,
		[intContractHeaderId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E.intContractHeaderId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractHeaderId
											ELSE NULL END,
		[intLineNo]					=	ISNULL(B.intSort,0)
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
	LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId) 
		ON E.intEntityId = A.intEntityVendorId 
				AND E.intContractHeaderId = B.intOrderId 
				AND E1.intContractDetailId = B.intLineNo
	OUTER APPLY (
		SELECT
			PODetails.intContractDetailId
			,PODetails.intContractHeaderId
		FROM tblPOPurchaseDetail PODetails
		WHERE intPurchaseDetailId = B.intLineNo
	) POContractItems
	WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1
	UNION ALL
	--CHARGES
	SELECT
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	A.intItemId,
		[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
		[intPODetailId]				=	NULL,
		[dblQtyOrdered]				=	1,
		[dblQtyReceived]			=	1,
		[dblTax]					=	0,
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	A.intAccountId,
		[dblTotal]					=	A.dblUnitCost,
		[dblCost]					=	A.dblUnitCost,
		[intContractDetailId]		=	NULL,
		[intContractHeaderId]		=	NULL,
		[intLineNo]					=	1
	FROM [vyuAPChargesForBilling] A
	WHERE A.intEntityVendorId = (SELECT intEntityVendorId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId)

	--CREATE TAXES FROM CREATED ITEM RECEIPT
	DECLARE @intBillDetailId INT;
	WHILE(EXISTS(SELECT 1 FROM #tmpCreatedBillDetail))
	BEGIN
		SET @intBillDetailId = (SELECT TOP 1 intBillDetailId FROM #tmpCreatedBillDetail)
		INSERT INTO tblAPBillDetailTax(
			[intBillDetailId]		, 
			[intTaxGroupMasterId]	, 
			[intTaxGroupId]			, 
			[intTaxCodeId]			, 
			[intTaxClassId]			, 
			[strTaxableByOtherTaxes], 
			[strCalculationMethod]	, 
			[dblRate]				, 
			[intAccountId]			, 
			[dblTax]				, 
			[dblAdjustedTax]		, 
			[ysnTaxAdjusted]		, 
			[ysnSeparateOnBill]		, 
			[ysnCheckOffTax]
		)
		SELECT
			[intBillDetailId]		=	@intBillDetailId, 
			[intTaxGroupMasterId]	=	A.intTaxGroupMasterId, 
			[intTaxGroupId]			=	A.intTaxGroupId, 
			[intTaxCodeId]			=	A.intTaxCodeId, 
			[intTaxClassId]			=	A.intTaxClassId, 
			[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
			[strCalculationMethod]	=	A.strCalculationMethod, 
			[dblRate]				=	A.dblRate, 
			[intAccountId]			=	A.intTaxAccountId, 
			[dblTax]				=	A.dblTax, 
			[dblAdjustedTax]		=	A.dblAdjustedTax, 
			[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
			[ysnSeparateOnBill]		=	A.ysnSeparateOnInvoice, 
			[ysnCheckOffTax]		=	A.ysnCheckoffTax
		FROM tblICInventoryReceiptItemTax A
		INNER JOIN tblAPBillDetail B ON B.intInventoryReceiptItemId = A.intInventoryReceiptItemId
		WHERE B.intBillDetailId = @intBillDetailId

		DELETE FROM #tmpCreatedBillDetail WHERE intBillDetailId = @intBillDetailId
	END
	
	UPDATE A
		SET A.dblTotal = (SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @generatedBillId)
		,A.dblTax = (SELECT SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = @generatedBillId)
	FROM tblAPBill A
	WHERE intBillId = @generatedBillId

	SELECT @shipFrom = intShipFromId, @shipTo = intShipToId FROM tblAPBill
	EXEC uspAPBillUpdateAddressInfo @generatedBillId, @shipFrom, @shipTo

	DELETE FROM #tmpReceiptIds WHERE intInventoryReceiptId = @receiptId
END

ALTER TABLE tblAPBill
	ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

DONE:
IF @@ERROR != 0
BEGIN
	ROLLBACK TRANSACTION
END
ELSE
BEGIN
	COMMIT TRANSACTION
END

SELECT * FROM #tmpReceiptBillIds

