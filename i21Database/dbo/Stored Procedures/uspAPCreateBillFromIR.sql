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
DECLARE @receiptItemId INT;
DECLARE @generatedBillId INT;
DECLARE @generatedBillRecordId NVARCHAR(50);
DECLARE @APAccount INT;
DECLARE @shipFrom INT, @shipTo INT;
DECLARE @receiptLocation INT;
DECLARE @userLocation INT;
DECLARE @location INT;
DECLARE @cashPrice DECIMAL;

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

--BEGIN TRANSACTION

INSERT INTO #tmpReceiptIds(intInventoryReceiptId) SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@receiptIds)

SET @totalReceipts = (SELECT COUNT(*) FROM #tmpReceiptIds)

SET @userLocation = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @userId);

--Get the company location of the user to get the default ap account else get from preference
SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @userLocation)

----try to get from Gl Account
--IF @APAccount IS NULL
--	SET @APAccount = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE intAccountCategoryId = 1)

--IF @APAccount IS NULL OR @APAccount <= 0
--BEGIN
--	RAISERROR('Please setup default AP Account', 16, 1);
--	GOTO DONE
--END

--Make sure all items were not yet billed.
IF NOT EXISTS(SELECT 1 FROM tblICInventoryReceiptItem A
					WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpReceiptIds)
					AND A.dblOpenReceive != A.dblBillQty)
BEGIN
	RAISERROR('All of the item in the receipt was fully billed.', 16, 1);
	--GOTO DONE
END

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

WHILE @counter != @totalReceipts
BEGIN

	SET @counter = @counter + 1;
	SELECT TOP(1) @receiptId = intInventoryReceiptId FROM #tmpReceiptIds
	EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT

	--PRIORITIZE RECEIPT LOCATION
	SET @receiptLocation = (SELECT intLocationId FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId)
	SET @location = @receiptLocation; 

	IF @receiptLocation IS NULL
	BEGIN
		SET @location = @userLocation --USE USER LOCATION
	END

	SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @location)
	IF @APAccount IS NULL OR @APAccount <= 0
	BEGIN
		RAISERROR('Please setup default AP Account.', 16, 1);
		--GOTO DONE
	END
		
	SET @cashPrice = (SELECT SUM(E1.dblCashPrice) FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation D ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
		LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId)  ON E.intEntityId = A.intEntityVendorId 
																															AND E.intContractHeaderId = B.intOrderId 
																															AND E1.intContractDetailId = B.intLineNo 
		WHERE A.intInventoryReceiptId = @receiptId AND E1.intPricingTypeId = 2)
	IF (@cashPrice = 0)
		BEGIN
			RAISERROR('Cannot create Voucher with 0.00 amount.', 16, 1);
			--GOTO DONE			 									       
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
		[intStoreLocationId],
		[intPayToAddressId],
		[intSubCurrencyCents]
		
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
		[intStoreLocationId]	=	A.intLocationId,
		[intPayToAddressId]		=	A.intShipFromId,
		[intSubCurrencyCents]	=	ISNULL(A.intSubCurrencyCents,1)
	FROM tblICInventoryReceipt A
	OUTER APPLY 
	(
		SELECT 
			C.intTermsId
		FROM tblAPVendor B INNER JOIN tblEMEntityLocation C ON B.intEntityVendorId = C.intEntityId AND C.ysnDefaultLocation = 1
		WHERE B.intEntityVendorId = A.intEntityVendorId
	) Terms
	WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1

	SET @generatedBillId = SCOPE_IDENTITY()

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[intInventoryReceiptItemId],
		[intInventoryReceiptChargeId],
		[intPurchaseDetailId],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblTax],
		[dblRate],
		[ysnSubCurrency],
		[intTaxGroupId],
		[intAccountId],
		[dblTotal],
		[dblCost],
		[dblOldCost],
		[dblNetWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[intCurrencyId]
	)
	OUTPUT inserted.intBillDetailId INTO #tmpCreatedBillDetail(intBillDetailId)
	SELECT
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	B.intItemId,
		[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId] = NULL,
		[intPODetailId]				=	CASE WHEN A.strReceiptType = 'Purchase Order' THEN (CASE WHEN B.intLineNo <= 0 THEN NULL ELSE B.intLineNo END) ELSE NULL END,
		[dblQtyOrdered]				=	B.dblOpenReceive - B.dblBillQty,
		[dblQtyReceived]			=	B.dblOpenReceive - B.dblBillQty,
		[dblTax]					=	B.dblTax,
		[dblRate]					=	ISNULL(G.dblRate,0),
		[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
		[dblTotal]					=	CASE WHEN B.ysnSubCurrency > 0 --SubCur True
											 THEN (CASE WHEN B.dblNet > 0 
														THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1)  * (B.dblNet ) * (ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1))  AS DECIMAL(18,2)) --Calculate Sub-Cur Base Gross/Net UOM
														ELSE CAST((B.dblOpenReceive - B.dblBillQty) * (CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1)) *  (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1)) AS DECIMAL(18,2))  --Calculate Sub-Cur 
												   END) 
											 ELSE (CASE WHEN B.dblNet > 0 --SubCur False
														THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) THEN E1.dblCashPrice ELSE B.dblUnitCost END *(B.dblNet ) * (ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1)) AS DECIMAL(18,2)) --Base Gross/Net UOM 
														ELSE CAST((B.dblOpenReceive - B.dblBillQty) * CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END * (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1))  AS DECIMAL(18,2))  --Orig Calculation
												   END)
										END,
		[dblCost]					=	CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
											 THEN (CASE WHEN E1.dblCashPrice IS NOT NULL THEN E1.dblCashPrice ELSE B.dblUnitCost END)
											 ELSE B.dblUnitCost
										END,
		[dblOldCost]				=	0,
		[dblNetWeight]				=	ISNULL(B.dblNet,0),
		[intContractDetailId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E1.intContractDetailId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractDetailId
											ELSE NULL END,
		[intContractHeaderId]		=	CASE WHEN A.strReceiptType = 'Purchase Contract' THEN E.intContractHeaderId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractHeaderId
											ELSE NULL END,
		[intUnitOfMeasureId]		=	B.intUnitMeasureId,
		[intCostUOMId]				=	B.intCostUOMId,
		[intWeightUOMId]			=	B.intWeightUOMId,
		[intLineNo]					=	ISNULL(B.intSort,0),
		[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
		[dblCostUnitQty]			=	ISNULL(ItemCostUOM.dblUnitQty,0),
		[dblUnitQty]				=	ISNULL(ItemUOM.dblUnitQty,0),
		[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										ELSE ISNULL(A.intCurrencyId,0) END
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
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId) 
											--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = A.intCurrencyId)
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId
	LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A.intCurrencyId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
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
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPODetailId]				=	NULL,
		[dblQtyOrdered]				=	1,
		[dblQtyReceived]			=	1,
		[dblTax]					=	0,
		[dblRate]					=	ISNULL(G.dblRate,0),
		[ysnSubCurrency]			=	ISNULL(A.ysnSubCurrency,0),
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	A.intAccountId,
		[dblTotal]					=	CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END,
		[dblCost]					=	A.dblUnitCost,
		[dblOldCost]				=	0,
		[dblNetWeight]				=	0,
		[intContractDetailId]		=	A.intContractDetailId,
		[intContractHeaderId]		=	A.intContractHeaderId,
		[intUnitOfMeasureId]		=	NULL,
		[intCostUOMId]              =    A.intCostUnitMeasureId,
		[intWeightUOMId]			=	NULL,
		[intLineNo]					=	1,
		[dblWeightUnitQty]			=	1,
		[dblCostUnitQty]			=	1,
		[dblUnitQty]				=	1,
		[intCurrencyId]				=	CASE WHEN A.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										ELSE ISNULL(A.intCurrencyId,0) END
	FROM [vyuAPChargesForBilling] A
	INNER JOIN tblICInventoryReceipt B ON A.intEntityVendorId = B.intEntityVendorId
	AND A.intInventoryReceiptId = B.intInventoryReceiptId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId) 
											--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = C.intCurrencyId)
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	WHERE A.intInventoryReceiptId = @receiptId

	--CREATE TAXES FROM CREATED ITEM RECEIPT

	--EXCLUDE CHARGES FOR TAXES
	DELETE A
	FROM #tmpCreatedBillDetail A
	INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
	WHERE B.intInventoryReceiptChargeId IS NOT NULL
	 
	DECLARE @intBillDetailId INT;
	WHILE(EXISTS(SELECT 1 FROM #tmpCreatedBillDetail))
	BEGIN

		SELECT TOP 1 
			@intBillDetailId = A.intBillDetailId
			,@receiptItemId = B.intInventoryReceiptItemId 
		FROM #tmpCreatedBillDetail A 
		INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId

		INSERT INTO tblAPBillDetailTax(
			[intBillDetailId]		, 
			--[intTaxGroupMasterId]	, 
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
			--[intTaxGroupMasterId]	=	A.intTaxGroupMasterId, 
			[intTaxGroupId]			=	A.intTaxGroupId, 
			[intTaxCodeId]			=	A.intTaxCodeId, 
			[intTaxClassId]			=	A.intTaxClassId, 
			[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
			[strCalculationMethod]	=	A.strCalculationMethod, 
			[dblRate]				=	A.dblRate, 
			[intAccountId]			=	A.intTaxAccountId, 
			[dblTax]				=	A.dblTax, 
			[dblAdjustedTax]		=	ISNULL(A.dblAdjustedTax,0), 
			[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
			[ysnSeparateOnBill]		=	A.ysnSeparateOnInvoice, 
			[ysnCheckOffTax]		=	A.ysnCheckoffTax
		FROM tblICInventoryReceiptItemTax A
		WHERE A.intInventoryReceiptItemId = @receiptItemId

		DELETE FROM #tmpCreatedBillDetail WHERE intBillDetailId = @intBillDetailId
	END
	
	UPDATE A
		SET --A.dblTotal = (SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @generatedBillId) AP-2116
		A.dblTax = (SELECT SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = @generatedBillId)
	FROM tblAPBill A
	WHERE intBillId = @generatedBillId

	SELECT @shipFrom = intShipFromId, @shipTo = intShipToId FROM tblAPBill
	EXEC uspAPBillUpdateAddressInfo @generatedBillId, @shipFrom, @shipTo

	DELETE FROM #tmpReceiptIds WHERE intInventoryReceiptId = @receiptId
END

ALTER TABLE tblAPBill
	ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

--DONE:
--IF @@ERROR != 0
--BEGIN
--	ROLLBACK TRANSACTION
--END
--ELSE
--BEGIN
--	COMMIT TRANSACTION
--END

SELECT * FROM #tmpReceiptBillIds