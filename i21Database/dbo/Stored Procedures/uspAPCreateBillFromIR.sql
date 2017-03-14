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
DECLARE @receiptAmount DECIMAL(18,6);
DECLARE @totalReceiptAmount DECIMAL(18,6);
DECLARE @totalLineItem DECIMAL(18,6);
DECLARE @totalCharges DECIMAL(18,6);
DECLARE @receiptType INT

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
IF NOT EXISTS(
	SELECT	TOP 1 1 
	FROM	tblICInventoryReceiptItem r INNER JOIN #tmpReceiptIds tmp
				ON r.intInventoryReceiptId = tmp.intInventoryReceiptId
	WHERE	r.dblOpenReceive <> r.dblBillQty
)
BEGIN
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri 
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				INNER JOIN #tmpReceiptIds tmp
					ON ri.intInventoryReceiptId = tmp.intInventoryReceiptId
		WHERE	r.strReceiptType = 'Inventory Return'	
	)
	BEGIN 
		-- Debit Memo is no longer needed. All items have Debit Memo.
		RAISERROR(80110, 11, 1)  
	END 
	ELSE 
	BEGIN 
		-- Voucher is no longer needed. All items have Voucher.
		RAISERROR(80111, 11, 1)  
	END 
END
ELSE 
BEGIN
	
	DECLARE @availableQty INT
	SET @availableQty =	(SELECT  CASE WHEN A.dblOpenReceive =  SUM(B.dblQtyReceived) THEN 1 ELSE 0 END
					FROM tblICInventoryReceiptItem A
						INNER JOIN tblAPBillDetail B ON B.[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
					where A.intInventoryReceiptItemId IN  (SELECT intInventoryReceiptItemId FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpReceiptIds))  AND B.intInventoryReceiptChargeId IS NULL
					GROUP BY A.dblOpenReceive)
		IF(@availableQty = 1)
		BEGIN 
			-- Voucher is no longer needed. All items have Voucher.
			RAISERROR(80111, 11, 1)  
		END 
END

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

WHILE @counter != @totalReceipts
BEGIN

	SET @counter = @counter + 1;
	SELECT TOP(1) @receiptId = intInventoryReceiptId FROM #tmpReceiptIds
	--CHECK THE INVENTORY TYPE
	SELECT @receiptType = (CASE WHEN strReceiptType = 'Inventory Return' THEN 18 ELSE 9 END) 
	FROM tblICInventoryReceipt 
	WHERE intInventoryReceiptId = @receiptId

	EXEC uspSMGetStartingNumber @receiptType, @generatedBillRecordId OUT

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
	
	----GET THE TOTAL IR AMOUNT
	SELECT @receiptAmount = SUM(A.dblLineTotal) + ISNULL(SUM(dblTax),0) FROM tblICInventoryReceiptItem A WHERE A.intInventoryReceiptId = @receiptId;
	
	SELECT @totalCharges = ISNULL((SUM(dblUnitCost) + ISNULL(SUM(dblTax),0.00)),0.00)
	FROM vyuICChargesForBilling WHERE intInventoryReceiptId = @receiptId
	
	SELECT @totalLineItem =   SUM(A.dblLineTotal) + ISNULL(SUM(dblTax),0)
	FROM tblICInventoryReceiptItem A 
	WHERE A.dblUnitCost > 0 AND A.intInventoryReceiptId = @receiptId
	
	SET @totalReceiptAmount = @totalLineItem + @totalCharges;

	SET @cashPrice = (SELECT SUM(E1.dblCashPrice) FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
		INNER JOIN tblICItemLocation D ON A.intLocationId = D.intLocationId AND B.intItemId = D.intItemId
		LEFT JOIN (tblCTContractHeader E INNER JOIN tblCTContractDetail E1 ON E.intContractHeaderId = E1.intContractHeaderId)  ON E.intEntityId = A.intEntityVendorId 
																															AND E.intContractHeaderId = B.intOrderId 
																															AND E1.intContractDetailId = B.intLineNo 
		WHERE A.intInventoryReceiptId = @receiptId AND E1.intPricingTypeId = 2)
	IF (@cashPrice = 0 OR @receiptAmount = 0)
		BEGIN
			RAISERROR('Cannot create Voucher with 0.00 amount.', 16, 1);
			--GOTO DONE			 									       
		END

	-- Get the producer id. 
	BEGIN 
		DECLARE @intProducerId AS INT 	

		SELECT	TOP 1 
				@intProducerId = ct.intProducerId 
		FROM	tblICInventoryReceipt rtn INNER JOIN tblICInventoryReceipt r
					on r.intInventoryReceiptId = rtn.intSourceInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem rtnItem
					on rtnItem.intInventoryReceiptId = rtn.intInventoryReceiptId
				INNER JOIN tblCTContractHeader ct
					on rtnItem.intOrderId = ct.intContractHeaderId
		WHERE	rtn.intInventoryReceiptId = @receiptId
				AND r.strReceiptType = 'Purchase Contract'
				AND rtn.strReceiptType = 'Inventory Return'
				AND ct.ysnClaimsToProducer = 1 
				AND ct.intProducerId IS NOT NULL 
				AND rtnItem.intOrderId IS NOT NULL 
	END 

	-- Check if the inventory return needs to use the producer as the vendor for the debit memo. 
	IF @intProducerId IS NOT NULL 
	BEGIN 					
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
			[intEntityVendorId]		=	@intProducerId
			,[strVendorOrderNumber] =	A.strVendorRefNo
			,[intTermsId] 			=	ISNULL(Terms.intTermsId,(SELECT TOP 1 intTermID FROM tblSMTerm WHERE LOWER(strTerm) = 'due on receipt'))
			,[intShipViaId]			=	A.intShipViaId
			,[intShipFromId]		=	NULLIF(A.intShipFromId,0)
			,[intShipToId]			=	A.intLocationId
			,[dtmDate] 				=	GETDATE()
			,[dtmDateCreated] 		=	GETDATE()
			,[dtmBillDate] 			=	GETDATE()
			,[dtmDueDate] 			=	GETDATE()
			,[intCurrencyId]		=	ISNULL(A.intCurrencyId,CAST((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') AS INT))
			,[intAccountId] 		=	@APAccount
			,[strBillId]			=	@generatedBillRecordId
			,[strReference] 		=	A.strBillOfLading
			,[dblTotal] 			=	@totalReceiptAmount
			,[dblAmountDue]			=	@totalReceiptAmount
			,[intEntityId]			=	@userId
			,[ysnPosted]			=	0
			,[ysnPaid]				=	0
			,[intTransactionType]	=	3 
			,[dblDiscount]			=	0
			,[dblWithheld]			=	0
			,[intStoreLocationId]	=	A.intLocationId
			,[intPayToAddressId]	=	A.intShipFromId
			,[intSubCurrencyCents]	=	ISNULL(A.intSubCurrencyCents,1)
		FROM tblICInventoryReceipt A
		OUTER APPLY 
		(
			SELECT 
					C.intTermsId
			FROM	tblAPVendor B INNER JOIN tblEMEntityLocation C 
						ON B.intEntityVendorId = C.intEntityId 
						AND C.ysnDefaultLocation = 1
			WHERE	B.intEntityVendorId = @intProducerId
		) Terms	
		WHERE	A.intInventoryReceiptId = @receiptId 
				AND A.ysnPosted = 1

		SET @generatedBillId = SCOPE_IDENTITY()
	END

	-- Otherwise, process the inventory receipt/inventory return to voucher/debit memo. 
	ELSE 
	BEGIN			
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
			[intShipFromId]			=	NULLIF(A.intShipFromId,0),
			[intShipToId]			=	A.intLocationId,
			[dtmDate] 				=	GETDATE(),
			[dtmDateCreated] 		=	GETDATE(),
			[dtmBillDate] 			=	GETDATE(),
			[dtmDueDate] 			=	GETDATE(),
			[intCurrencyId]			=	ISNULL(A.intCurrencyId,CAST((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') AS INT)),
			[intAccountId] 			=	@APAccount,
			[strBillId]				=	@generatedBillRecordId,
			[strReference] 			=	A.strBillOfLading,
			[dblTotal] 				=	A.dblInvoiceAmount,
			[dblAmountDue]			=	A.dblInvoiceAmount,
			[intEntityId]			=	@userId,
			[ysnPosted]				=	0,
			[ysnPaid]				=	0,
			[intTransactionType]	=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END, -- CASE WHEN @receiptAmount > 0 THEN 1 ELSE 3 END,
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
	END 

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
		[dblClaimAmount],
		[dblNetWeight],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[intContractDetailId],
		[intContractHeaderId],
		[intUnitOfMeasureId],
		[intCostUOMId],
		[intWeightUOMId],
		[intLineNo],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[intCurrencyId],
		[intStorageLocationId],
		[int1099Form],
		[int1099Category]
	)
	OUTPUT inserted.intBillDetailId INTO #tmpCreatedBillDetail(intBillDetailId)
	SELECT 
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	B.intItemId,
		[intInventoryReceiptItemId]	=	B.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId] = NULL,
		[intPODetailId]				=	CASE WHEN A.strReceiptType = 'Purchase Order' THEN (CASE WHEN B.intLineNo <= 0 THEN NULL ELSE B.intLineNo END) ELSE NULL END,
		[dblQtyOrdered]				=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END,
		[dblQtyReceived]			=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END,
		[dblTax]					=	ISNULL(B.dblTax,0),
		[dblRate]					=	ISNULL(G.dblRate,0),
		[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
		[dblTotal]					=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
										 THEN (CASE WHEN B.intWeightUOMId > 0 
													THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
																   THEN E1.dblCashPrice 
																   ELSE B.dblUnitCost 
															  END / ISNULL(A.intSubCurrencyCents,1)  * ((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
															     * (CAST(ItemUOM.dblUnitQty AS DECIMAL(18,6))/ CAST(ISNULL(ItemWeightUOM.dblUnitQty ,1) AS DECIMAL(18,6))))  * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
													WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
													THEN CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
																* 
																(CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1)) 
																*  
																(ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1)) 
														AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
													ELSE CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
																* 
																(CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
											   END) 
										 ELSE (CASE WHEN B.intWeightUOMId > 0
													THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
																   THEN E1.dblCashPrice 
																   ELSE B.dblUnitCost 
															  END * ((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
															      * (CAST(ItemUOM.dblUnitQty AS DECIMAL(18,6))/ CAST(ISNULL(ItemWeightUOM.dblUnitQty ,1) AS DECIMAL(18,6))))  * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
													WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
													THEN CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
																* CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END * (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1))  
														AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
													ELSE CAST((CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END) 
																* CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END  
															AS DECIMAL(18,2))  --Orig Calculation
											   END)
										 END),0),
		[dblCost]					=	CASE WHEN (B.dblUnitCost IS NULL OR B.dblUnitCost = 0)
											 THEN (CASE WHEN E1.dblCashPrice IS NOT NULL THEN E1.dblCashPrice ELSE B.dblUnitCost END)
											 ELSE B.dblUnitCost
										END,
		[dblOldCost]				=	NULL,
		[dblClaimAmount]			=	ISNULL(CASE WHEN ISNULL(B.dblGross - B.dblNet,0) > 0 THEN  
										(
										 (ISNULL(B.dblGross - B.dblNet,0) - (CASE WHEN J.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (J.dblFranchise / 100) ELSE 0 END)) * 
										 (CASE WHEN B.dblNet > 0 THEN B.dblUnitCost * (CAST(ItemWeightUOM.dblUnitQty AS DECIMAL(18,6)) / CAST(ISNULL(ItemCostUOM.dblUnitQty,1)AS DECIMAL(18,6))) 
											   WHEN B.intCostUOMId > 0 THEN B.dblUnitCost * ( CAST(ItemUOM.dblUnitQty AS DECIMAL(18,6)) / CAST(ISNULL(ItemCostUOM.dblUnitQty,1)AS DECIMAL(18,6))) ELSE B.dblUnitCost END) / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(A.intSubCurrencyCents,1) ELSE 1 END
										) ELSE 0.00 END,0),
		[dblNetWeight]				=	CASE WHEN B.intWeightUOMId > 0 THEN (CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END)
										* (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) ELSE 0 END,
		[dblNetShippedWeight]		=	ISNULL(Loads.dblNet,0),
		[dblWeightLoss]				=	ISNULL(B.dblGross - B.dblNet,0),
		[dblFranchiseWeight]		=	CASE WHEN J.dblFranchise > 0 THEN ISNULL(B.dblGross,0) * (J.dblFranchise / 100) ELSE 0 END,
		[intContractDetailId]		=	CASE WHEN ((A.strReceiptType = 'Purchase Contract') OR
													 ( A.strReceiptType = 'Inventory Return' AND InventoryReturnOrigReceipt.strReceiptType = 'Purchase Contract'))
													 THEN E1.intContractDetailId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractDetailId
											ELSE NULL END,
		[intContractHeaderId]		=	CASE WHEN ((A.strReceiptType = 'Purchase Contract') OR
													 ( A.strReceiptType = 'Inventory Return' AND InventoryReturnOrigReceipt.strReceiptType = 'Purchase Contract'))
													 THEN E.intContractHeaderId 
											WHEN A.strReceiptType = 'Purchase Order' THEN POContractItems.intContractHeaderId
											ELSE NULL END,
		[intUnitOfMeasureId]		=	B.intUnitMeasureId,
		[intCostUOMId]				=	B.intCostUOMId,
		[intWeightUOMId]			=	B.intWeightUOMId,
		[intLineNo]					=	ISNULL(B.intSort,0),
		[dblWeightUnitQty]			=	ISNULL(ItemWeightUOM.dblUnitQty,0),
		[dblCostUnitQty]			=	ABS(ISNULL(ItemCostUOM.dblUnitQty,0)),
		[dblUnitQty]				=	ABS(ISNULL(ItemUOM.dblUnitQty,0)),
		[intCurrencyId]				=	CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										ELSE ISNULL(A.intCurrencyId,0) END,
		[intStorageLocationId]		=   B.intStorageLocationId,
		[int1099Form]				=	CASE WHEN (SELECT CHARINDEX('MISC', D2.str1099Form)) > 0 THEN 1 
										     WHEN (SELECT CHARINDEX('INT', D2.str1099Form)) > 0 THEN 2 
											 WHEN (SELECT CHARINDEX('B', D2.str1099Form)) > 0 THEN 3 
										ELSE 0
										END,
		[int1099Category]			=	ISNULL((SELECT TOP 1 int1099CategoryId FROM tblAP1099Category WHERE strCategory = D2.str1099Type),0)							   
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
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN dbo.tblSMCurrency H ON H.intCurrencyID = A.intCurrencyId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = B.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = B.intCostUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = B.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
	LEFT JOIN tblCTWeightGrade J ON E.intWeightId = J.intWeightGradeId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityVendorId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityVendorId
	LEFT JOIN tblCTWeightGrade W ON E.intWeightId = W.intWeightGradeId
	OUTER APPLY (
		SELECT 
			K.dblNetWt AS dblNet
		FROM tblLGLoadContainer K
		WHERE 1 = (CASE WHEN (A.strReceiptType = 'Purchase Contract' OR A.strReceiptType = 'Inventory Return') AND A.intSourceType = 2
							AND K.intLoadContainerId = B.intContainerId 
						THEN 1
						ELSE 0 END)
	) Loads
	OUTER APPLY (
		SELECT
			PODetails.intContractDetailId
			,PODetails.intContractHeaderId
		FROM tblPOPurchaseDetail PODetails
		WHERE intPurchaseDetailId = B.intLineNo
	) POContractItems
	OUTER APPLY (
		SELECT
			TOP 1 ReturnReceipt.strReceiptType
		FROM tblICInventoryReceipt ReturnReceipt
		INNER JOIN tblICInventoryReceiptItem ReturnReceiptItem ON ReturnReceipt.intInventoryReceiptId = ReturnReceiptItem.intInventoryReceiptId
		WHERE ReturnReceiptItem.intInventoryReceiptItemId = B.intSourceInventoryReceiptItemId
	) InventoryReturnOrigReceipt
	WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1 AND B.dblUnitCost != 0
	UNION ALL
	--CHARGES
	SELECT
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	A.intItemId,
		[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPODetailId]				=	NULL,
		[dblQtyOrdered]				=	A.dblOrderQty,
		[dblQtyReceived]			=	A.dblQuantityToBill,
		[dblTax]					=	ISNULL(A.dblTax,0),
		[dblRate]					=	ISNULL(G.dblRate,0),
		[ysnSubCurrency]			=	ISNULL(A.ysnSubCurrency,0),
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	A.intAccountId,
		[dblTotal]					=	CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END,
		[dblCost]					=	ABS(A.dblUnitCost),
		[dblOldCost]				=	NULL,
		[dblClaimAmount]			=	0,
		[dblNetWeight]				=	0,
		[dblNetShippedWeight]		=	0,
		[dblWeightLoss]				=	0,
		[dblFranchiseWeight]		=	0,
		[intContractDetailId]		=	A.intContractDetailId,
		[intContractHeaderId]		=	A.intContractHeaderId,
		[intUnitOfMeasureId]		=	NULL,
		[intCostUOMId]              =    A.intCostUnitMeasureId,
		[intWeightUOMId]			=	NULL,
		[intLineNo]					=	1,
		[dblWeightUnitQty]			=	1,
		[dblCostUnitQty]			=	1,
		[dblUnitQty]				=	1,
		[intCurrencyId]				=	ISNULL(A.intCurrencyId,0),
		[intStorageLocationId]		=	NULL,
		[int1099Form]				=	0,
		[int1099Category]			=	0       
	FROM [vyuICChargesForBilling] A
	INNER JOIN tblICInventoryReceipt B ON A.intEntityVendorId = B.intEntityVendorId
	AND A.intInventoryReceiptId = B.intInventoryReceiptId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intToCurrencyId = A.intCurrencyId) 
											--OR (F.intToCurrencyId = (SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) AND F.intFromCurrencyId = C.intCurrencyId)
	LEFT JOIN dbo.tblSMCurrencyExchangeRateDetail G ON F.intCurrencyExchangeRateId = G.intCurrencyExchangeRateId AND G.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	--LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = A.intCurrencyId 
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