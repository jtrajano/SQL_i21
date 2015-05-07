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

CREATE TABLE #tmpReceiptIds (
	[intInventoryReceiptId] [INT] PRIMARY KEY,
	UNIQUE ([intInventoryReceiptId])
);

CREATE TABLE #tmpReceiptBillIds (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryReceiptId] [INT],
	UNIQUE ([intBillId])
);

INSERT INTO #tmpReceiptIds(intInventoryReceiptId) SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@receiptIds)

SET @totalReceipts = (SELECT COUNT(*) FROM #tmpReceiptIds)

--Get the company location of the user to get the default ap account else get from preference
SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = 
						(SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityId = @userId))

--try to get from AP preference
IF @APAccount IS NULL
	SET @APAccount = (SELECT intDefaultAccountId FROM tblAPPreference)

--try to get from Gl Account
IF @APAccount IS NULL
	SET @APAccount = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE intAccountCategoryId = 1)

IF @APAccount IS NULL
BEGIN
	RAISERROR('Please setup default AP Account', 16, 1);
	RETURN;
END

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

WHILE @counter != @totalReceipts
BEGIn

	SET @counter = @counter + 1;
	SELECT TOP(1) @receiptId = intInventoryReceiptId FROM #tmpReceiptIds
	EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

	INSERT INTO tblAPBill(
		[intEntityVendorId],
		[strVendorOrderNumber], 
		[intTermsId], 
		[intShipViaId],
		[intShipFromId],
		[intShipToId],
		[intTaxId], 
		[dtmDate], 
		[dtmDateCreated], 
		[dtmBillDate],
		[dtmDueDate], 
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
		[dblWithheld]
	)
	OUTPUT inserted.intBillId, @receiptId INTO #tmpReceiptBillIds(intBillId, intInventoryReceiptId)
	SELECT
		[intEntityVendorId]		=	A.intEntityVendorId,
		[strVendorOrderNumber] 	=	A.strVendorRefNo,
		[intTermsId] 			=	ISNULL(Terms.intTermsId,(SELECT TOP 1 intTermID FROM tblSMTerm WHERE LOWER(strTerm) = 'due on receipt')),
		[intShipViaId]			=	A.intShipViaId,
		[intShipFromId]			=	A.intShipFromId,
		[intShipToId]			=	A.intLocationId,
		[intTaxId] 				=	NULL,
		[dtmDate] 				=	GETDATE(),
		[dtmDateCreated] 		=	GETDATE(),
		[dtmBillDate] 			=	GETDATE(),
		[dtmDueDate] 			=	GETDATE(),
		[intAccountId] 			=	@APAccount,
		[strBillId]				=	@generatedBillId,
		[strReference] 			=	NULL,
		[dblTotal] 				=	A.dblInvoiceAmount,
		[dblAmountDue]			=	A.dblInvoiceAmount,
		[intEntityId]			=	@userId,
		[ysnPosted]				=	0,
		[ysnPaid]				=	0,
		[intTransactionType]	=	1,
		[dblDiscount]			=	0,
		[dblWithheld]			=	0
	FROM tblICInventoryReceipt A
	OUTER APPLY 
	(
		SELECT 
			C.intTermsId
		FROM tblAPVendor B INNER JOIN tblEntityLocation C ON B.intEntityVendorId = C.intEntityId AND B.intDefaultLocationId = C.intEntityLocationId
		WHERE B.intEntityVendorId = A.intEntityVendorId
	) Terms
	WHERE A.intInventoryReceiptId = @receiptId

	SET @generatedBillId = SCOPE_IDENTITY()

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[intItemReceiptId],
		[intPODetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[intLineNo]
	)
	SELECT
		[intBillId]				=	@generatedBillId,
		[intItemId]				=	B.intItemId,
		[intItemReceiptId]		=	B.intInventoryReceiptItemId,
		[intPODetailId]			=	B.intLineNo,
		[dblQtyOrdered]			=	B.dblOrderQty,
		[dblQtyReceived]		=	B.dblOpenReceive,
		[intAccountId]			=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
		[dblTotal]				=	B.dblLineTotal,
		[dblCost]				=	B.dblUnitCost,
		[intLineNo]				=	B.intSort
	FROM tblICInventoryReceipt A
	INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	INNER JOIN tblICItem C
		ON B.intItemId = C.intItemId
	INNER JOIN tblICItemLocation D
		ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
	WHERE A.intInventoryReceiptId = @receiptId

	DELETE FROM #tmpReceiptIds WHERE intInventoryReceiptId = @receiptId
END

ALTER TABLE tblAPBill
	ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

SELECT * FROM #tmpReceiptBillIds
