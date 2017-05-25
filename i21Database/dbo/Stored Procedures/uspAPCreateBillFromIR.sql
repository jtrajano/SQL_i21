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
DECLARE @totalReceiptDetails INT;
DECLARE @counter INT = 0;
DECLARE @counter2 INT = 0;
DECLARE @receiptId INT;
DECLARE @receiptDetailId INT;
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
DECLARE @receiptType INT;
DECLARE @contractTermId INT;
DECLARE @balanceDue INT;
DECLARE @receipttDate DATETIME;


CREATE TABLE #tmpReceiptIds (
	[intInventoryReceiptId] [INT] PRIMARY KEY,
	UNIQUE ([intInventoryReceiptId])
);

CREATE TABLE #tmpReceiptBillIds (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryReceiptId] INT,
	[intEntityVendorId] INT
	UNIQUE ([intBillId])
);

CREATE TABLE #tmpCreatedBillDetail (
	[intBillDetailId] [INT]
	UNIQUE ([intBillDetailId])
);

--BEGIN TRANSACTION

INSERT INTO #tmpReceiptIds(intInventoryReceiptId) SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@receiptIds)

IF OBJECT_ID('tempdb..#tmpReceiptData') IS NOT NULL DROP TABLE #tmpReceiptData

SELECT IR.* INTO #tmpReceiptData FROM tblICInventoryReceipt IR INNER JOIN #tmpReceiptIds tIR ON IR.intInventoryReceiptId = tIR.intInventoryReceiptId

IF OBJECT_ID('tempdb..#tmpReceiptDetailData') IS NOT NULL DROP TABLE #tmpReceiptDetailData

SELECT IRDetail.* INTO #tmpReceiptDetailData FROM tblICInventoryReceiptItem IRDetail INNER JOIN #tmpReceiptIds tIR ON IRDetail.intInventoryReceiptId = tIR.intInventoryReceiptId

IF OBJECT_ID('tempdb..#tmpReceiptDetailTaxData') IS NOT NULL DROP TABLE #tmpReceiptDetailTaxData

SELECT IRDetailTax.* INTO #tmpReceiptDetailTaxData 
FROM tblICInventoryReceiptItemTax IRDetailTax 
INNER JOIN tblICInventoryReceiptItem IRDetail ON IRDetailTax.intInventoryReceiptItemId = IRDetail.intInventoryReceiptItemId
INNER JOIN #tmpReceiptIds tIR ON IRDetail.intInventoryReceiptId = tIR.intInventoryReceiptId

SET @totalReceipts = (SELECT COUNT(*) FROM #tmpReceiptIds)

SET @userLocation = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @userId);

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
	FROM	#tmpReceiptDetailData r
	WHERE	r.dblOpenReceive <> r.dblBillQty
)
BEGIN
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	#tmpReceiptData r
		WHERE	r.strReceiptType = 'Inventory Return'	
	)
	BEGIN 
		-- Debit Memo is no longer needed. All items have Debit Memo.
		EXEC uspICRaiseError 80110;
	END 
	ELSE 
	BEGIN 
		-- Voucher is no longer needed. All items have Voucher. 
		EXEC uspICRaiseError 80111; 
	END 
END
ELSE 
BEGIN
	DECLARE @availableQty INT;
	DECLARE @chargeQty INT;
	DECLARE @rtype NVARCHAR(50);
	SET @rtype =  (SELECT TOP 1 strReceiptType FROM #tmpReceiptData) 

	SET @availableQty =	(SELECT CASE WHEN SUM(A.dblOpenReceive) =  SUM(bilLDetails.dblQtyReceived) THEN 0 ELSE 1 END
					FROM #tmpReceiptDetailData A
						OUTER APPLY
						(
							SELECT SUM(B.dblQtyReceived) AS dblQtyReceived  FROM dbo.tblAPBillDetail B
							WHERE B.intInventoryReceiptItemId = A.intInventoryReceiptItemId  
							AND B.intInventoryReceiptChargeId IS NULL
						) bilLDetails
					WHERE A.intInventoryReceiptItemId IN  (SELECT intInventoryReceiptItemId FROM #tmpReceiptDetailData WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpReceiptIds)))
	IF EXISTS (	SELECT TOP 1 1 FROM dbo.tblICInventoryReceiptCharge A
				INNER JOIN dbo.tblAPBillDetail B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
				WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM #tmpReceiptIds))
				BEGIN 
					SET @chargeQty = 0
				END
	ELSE
				BEGIN
					SET @chargeQty = 1
				END              
		
	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblICInventoryReceiptCharge WHERE intInventoryReceiptId IN ((SELECT intInventoryReceiptId FROM #tmpReceiptIds)))
	BEGIN
		IF(@availableQty = 0 AND  @chargeQty = 0)
		BEGIN 
			-- Debit Memo is no longer needed. All items have Debit Memo.
			IF(@rtype = 'Inventory Return')
				BEGIN
					EXEC uspICRaiseError 80110;
					GOTO Post_Exit           
				END              
			ELSE
			-- Voucher is no longer needed. All items have Voucher.      
				BEGIN
					EXEC uspICRaiseError 80111; 
					GOTO Post_Exit
				END   
		END
	END
	ELSE
	BEGIN
		IF(@availableQty = 0)
		BEGIN 
			-- Debit Memo is no longer needed. All items have Debit Memo.
			IF(@rtype = 'Inventory Return')
				BEGIN
					EXEC uspICRaiseError 80110;
					GOTO Post_Exit           
				END              
			ELSE
			-- Voucher is no longer needed. All items have Voucher.      
				BEGIN
					EXEC uspICRaiseError 80111; 
					GOTO Post_Exit
				END   
		END  
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
	FROM #tmpReceiptData 
	WHERE intInventoryReceiptId = @receiptId

	--EXEC uspSMGetStartingNumber @receiptType, @generatedBillRecordId OUT

	--PRIORITIZE RECEIPT LOCATION
	SET @receiptLocation = (SELECT intLocationId FROM #tmpReceiptData WHERE intInventoryReceiptId = @receiptId)
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
	--SELECT @receiptAmount = ISNULL(SUM(A.dblLineTotal),0) + ISNULL(SUM(dblTax),0) FROM tblICInventoryReceiptItem A WHERE A.intInventoryReceiptId = @receiptId;
	
	--SELECT @totalCharges = ISNULL((SUM(dblUnitCost) + ISNULL(SUM(dblTax),0.00)),0.00)
	--FROM vyuICChargesForBilling WHERE intInventoryReceiptId = @receiptId
	
	--SELECT @totalLineItem =   SUM(A.dblLineTotal) + ISNULL(SUM(dblTax),0)
	--FROM #tmpReceiptDetailData A 
	--WHERE A.dblUnitCost > 0 AND A.intInventoryReceiptId = @receiptId
	
	--SET @totalReceiptAmount = @totalLineItem + @totalCharges;

	SET @cashPrice = (SELECT SUM(E1.dblCashPrice) FROM #tmpReceiptData A
		INNER JOIN #tmpReceiptDetailData B ON A.intInventoryReceiptId = B.intInventoryReceiptId
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
					@intProducerId = ctd.intProducerId--ct.intProducerId 
			FROM	#tmpReceiptData rtn INNER JOIN tblICInventoryReceipt r
						on r.intInventoryReceiptId = rtn.intSourceInventoryReceiptId
					INNER JOIN #tmpReceiptDetailData rtnItem
						on rtnItem.intInventoryReceiptId = rtn.intInventoryReceiptId
					INNER JOIN tblCTContractHeader ct
						on rtnItem.intOrderId = ct.intContractHeaderId
					INNER JOIN tblCTContractDetail ctd
						ON ct.intContractHeaderId = ctd.intContractHeaderId AND rtnItem.intLineNo = ctd.intContractDetailId
			WHERE	rtn.intInventoryReceiptId = @receiptId
					AND r.strReceiptType = 'Purchase Contract'
					AND rtn.strReceiptType = 'Inventory Return'
					AND ctd.ysnClaimsToProducer = 1
					AND rtnItem.intOrderId IS NOT NULL 
		END 

		-- Check if the inventory return needs to use the producer as the vendor for the debit memo. 
		-- make sure we already have voucher created for that producer

		SET @generatedBillId = (SELECT TOP 1 intBillId FROM #tmpReceiptBillIds WHERE intEntityVendorId = @intProducerId)
		
		IF @generatedBillId IS NULL
		BEGIN

			EXEC uspSMGetStartingNumber @receiptType, @generatedBillRecordId OUT
			--process the inventory receipt/inventory return to voucher/debit memo. 
			IF @intProducerId IS NULL
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
			OUTPUT inserted.intBillId, @receiptId, @intProducerId INTO #tmpReceiptBillIds(intBillId, intInventoryReceiptId, intEntityVendorId)
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
				[dblTotal] 				=	0,
				[dblAmountDue]			=	0,
				[intEntityId]			=	@userId,
				[ysnPosted]				=	0,
				[ysnPaid]				=	0,
				[intTransactionType]	=	CASE WHEN A.strReceiptType = 'Inventory Return' THEN 3 ELSE 1 END, -- CASE WHEN @receiptAmount > 0 THEN 1 ELSE 3 END,
				[dblDiscount]			=	0,
				[dblWithheld]			=	0,
				[intStoreLocationId]	=	A.intLocationId,
				[intPayToAddressId]		=	A.intShipFromId,
				[intSubCurrencyCents]	=	ISNULL(A.intSubCurrencyCents,1)
			FROM #tmpReceiptData A
			OUTER APPLY 
			(
				SELECT 
					C.intTermsId
				FROM tblAPVendor B INNER JOIN tblEMEntityLocation C ON B.intEntityId = C.intEntityId AND C.ysnDefaultLocation = 1
				WHERE B.intEntityId = A.intEntityVendorId
			) Terms
			WHERE A.intInventoryReceiptId = @receiptId AND A.ysnPosted = 1

			SET @generatedBillId = SCOPE_IDENTITY()
			END
		END

	SELECT @totalReceiptDetails = COUNT(*) FROM #tmpReceiptDetailData ReceiptItem WHERE ReceiptItem.intInventoryReceiptId = @receiptId
	
	WHILE @totalReceiptDetails != @counter2
	BEGIN	

		SET @counter2 = @counter2 + 1;
		SELECT TOP(1) @receiptDetailId = intInventoryReceiptItemId FROM #tmpReceiptDetailData WHERE intInventoryReceiptId = @receiptId
		
		-- Get the producer id. 
		BEGIN 
			SELECT	TOP 1 
					@intProducerId = ctd.intProducerId--ct.intProducerId 
			FROM	#tmpReceiptData rtn INNER JOIN tblICInventoryReceipt r
						on r.intInventoryReceiptId = rtn.intSourceInventoryReceiptId
					INNER JOIN #tmpReceiptDetailData rtnItem
						on rtnItem.intInventoryReceiptId = rtn.intInventoryReceiptId
					INNER JOIN tblCTContractHeader ct
						on rtnItem.intOrderId = ct.intContractHeaderId
					INNER JOIN tblCTContractDetail ctd
						ON ct.intContractHeaderId = ctd.intContractHeaderId AND rtnItem.intLineNo = ctd.intContractDetailId
			WHERE	rtn.intInventoryReceiptId = @receiptId AND rtnItem.intInventoryReceiptItemId = @receiptDetailId
					AND r.strReceiptType = 'Purchase Contract'
					AND rtn.strReceiptType = 'Inventory Return'
					AND ctd.ysnClaimsToProducer = 1
					AND rtnItem.intOrderId IS NOT NULL 
		END
		
		----GET THE TOTAL IR AMOUNT PER RECEIPT ITEM
		--SELECT @totalLineItem =   SUM(A.dblLineTotal) + ISNULL(SUM(dblTax),0)
		--FROM #tmpReceiptDetailData A 
		--WHERE A.dblUnitCost > 0 AND A.intInventoryReceiptItemId = @receiptDetailId 
		
		--SET @totalReceiptAmount = @totalLineItem;

		IF @intProducerId IS NOT NULL 
		BEGIN
			-- Check if the inventory return needs to use the producer as the vendor for the debit memo. 
			-- make sure we already have voucher created for that producer

			SET @generatedBillId = (SELECT TOP 1 intBillId FROM #tmpReceiptBillIds WHERE intEntityVendorId = @intProducerId)
		END
		IF @generatedBillId IS NULL
		BEGIN

			EXEC uspSMGetStartingNumber @receiptType, @generatedBillRecordId OUT
			--process the inventory inventory return to debit memo with producer consideration.
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
				OUTPUT inserted.intBillId, @receiptId, @intProducerId INTO #tmpReceiptBillIds(intBillId, intInventoryReceiptId, intEntityVendorId)
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
					,[dblTotal] 			=	0
					,[dblAmountDue]			=	0
					,[intEntityId]			=	@userId
					,[ysnPosted]			=	0
					,[ysnPaid]				=	0
					,[intTransactionType]	=	3 
					,[dblDiscount]			=	0
					,[dblWithheld]			=	0
					,[intStoreLocationId]	=	A.intLocationId
					,[intPayToAddressId]	=	A.intShipFromId
					,[intSubCurrencyCents]	=	ISNULL(A.intSubCurrencyCents,1)
				FROM #tmpReceiptData A
				OUTER APPLY 
				(
					SELECT 
							C.intTermsId
					FROM	tblAPVendor B INNER JOIN tblEMEntityLocation C 
								ON B.[intEntityId] = C.intEntityId 
								AND C.ysnDefaultLocation = 1
					WHERE	B.[intEntityId] = @intProducerId
				) Terms	
				WHERE	A.intInventoryReceiptId = @receiptId 
						AND A.ysnPosted = 1

				SET @generatedBillId = SCOPE_IDENTITY()
			END
		END
        
		IF(@availableQty != 0)
		BEGIN
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
				[intCurrencyExchangeRateTypeId],
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
				[dblQtyOrdered]				=	ABS(B.dblOpenReceive - B.dblBillQty),--CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END,
				[dblQtyReceived]			=	ABS(B.dblOpenReceive - B.dblBillQty),--CASE WHEN A.strReceiptType = 'Inventory Return' THEN ABS(B.dblOpenReceive) ELSE ABS(B.dblOpenReceive - B.dblBillQty) END,
				[dblTax]					=	ISNULL(B.dblTax,0),
				[dblForexRate]				=	ISNULL(B.dblForexRate,0),
				[intForexRateTypeId]		=	B.intForexRateTypeId,
				[ysnSubCurrency]			=	CASE WHEN B.ysnSubCurrency > 0 THEN 1 ELSE 0 END,
				[intTaxGroupId]				=	NULL,
				[intAccountId]				=	[dbo].[fnGetItemGLAccount](B.intItemId, D.intItemLocationId, 'AP Clearing'),
				[dblTotal]					=	ISNULL((CASE WHEN B.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
												 THEN (CASE WHEN B.intWeightUOMId > 0 
															THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
																		   THEN E1.dblCashPrice 
																		   ELSE B.dblUnitCost 
																	  END / ISNULL(A.intSubCurrencyCents,1)  * B.dblNet * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
															WHEN (B.intUnitMeasureId > 0 AND B.intCostUOMId > 0)
															THEN CAST(ABS(B.dblOpenReceive - B.dblBillQty) 
																		* 
																		(CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1)) 
																		*  
																		(ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1)) 
																AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
															ELSE CAST(ABS(B.dblOpenReceive - B.dblBillQty)
																		* 
																		(CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END / ISNULL(A.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
													   END) 
												 ELSE (CASE WHEN B.intWeightUOMId > 0
															THEN CAST(CASE WHEN (E1.dblCashPrice > 0 AND B.dblUnitCost = 0) 
																		   THEN E1.dblCashPrice 
																		   ELSE B.dblUnitCost 
																	  END * B.dblNet  * ItemWeightUOM.dblUnitQty / ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
															WHEN (B.intUnitMeasureId > 0  AND B.intCostUOMId > 0)
															THEN CAST(ABS(B.dblOpenReceive - B.dblBillQty)
																		* CASE WHEN E1.dblCashPrice > 0 THEN E1.dblCashPrice ELSE B.dblUnitCost END * (ItemUOM.dblUnitQty/ ISNULL(ItemCostUOM.dblUnitQty,1))  
																AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
															ELSE CAST(ABS(B.dblOpenReceive - B.dblBillQty) 
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
				[dblNetWeight]				=	CASE WHEN B.intWeightUOMId > 0 THEN  
														(CASE WHEN B.dblBillQty > 0 
																THEN ABS(B.dblOpenReceive - B.dblBillQty) * (ItemUOM.dblUnitQty/ ISNULL(ItemWeightUOM.dblUnitQty ,1)) --THIS IS FOR PARTIAL
															ELSE B.dblNet --THIS IS FOR NO RECEIVED QTY YET BUT HAS NET WEIGHT DIFFERENT FROM GROSS
												END)
												ELSE 0 END,
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
			FROM #tmpReceiptData A
			INNER JOIN #tmpReceiptDetailData B
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
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.intEntityId = D2.intEntityId) ON A.[intEntityVendorId] = D1.intEntityId
			LEFT JOIN tblCTWeightGrade W ON E.intWeightId = W.intWeightGradeId
			OUTER APPLY (
				SELECT 
					K.dblNetWt AS dblNet
				FROM tblLGLoadContainer K
				WHERE 1 = (CASE WHEN A.strReceiptType = 'Purchase Contract' AND A.intSourceType = 2
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
			AND B.intInventoryReceiptItemId = @receiptDetailId
		
			--CREATE TAXES FROM CREATED ITEM RECEIPT

			--EXCLUDE CHARGES FOR GENERATING TAXES
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

				--INSERT ITEM TAX
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
				FROM #tmpReceiptDetailTaxData A
				WHERE A.intInventoryReceiptItemId = @receiptItemId

				DELETE FROM #tmpCreatedBillDetail WHERE intBillDetailId = @intBillDetailId
			END

			DELETE FROM #tmpReceiptDetailData WHERE intInventoryReceiptItemId = @receiptDetailId
		END
	END  

	--ADD CHARGES
	IF(@chargeQty != 0 )
	BEGIN
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
		[intCurrencyExchangeRateTypeId],
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
	SELECT DISTINCT
		[intBillId]					=	@generatedBillId,
		[intItemId]					=	A.intItemId,
		[intInventoryReceiptItemId]	=	A.intInventoryReceiptItemId,
		[intInventoryReceiptChargeId]	=	A.[intInventoryReceiptChargeId],
		[intPODetailId]				=	NULL,
		[dblQtyOrdered]				=	A.dblOrderQty,
		[dblQtyReceived]			=	A.dblQuantityToBill,
		[dblTax]					=	(CASE WHEN C.ysnPrice = 1 THEN ISNULL(A.dblTax,0) * -1 ELSE ISNULL(A.dblTax,0) END), -- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN 
		[dblForexRate]				=	ISNULL(A.dblForexRate,0),
		[intForexRateTypeId]		=   A.intForexRateTypeId,
		[ysnSubCurrency]			=	ISNULL(A.ysnSubCurrency,0),
		[intTaxGroupId]				=	NULL,
		[intAccountId]				=	A.intAccountId,
		[dblTotal]					=	CASE WHEN C.ysnPrice > 0 THEN  (CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END) * -1 
											 ELSE (CASE WHEN A.ysnSubCurrency > 0 THEN A.dblUnitCost / A.intSubCurrencyCents ELSE A.dblUnitCost END)
										END,
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
	OUTER APPLY(
		SELECT ysnPrice FROM tblICInventoryReceiptCharge RC
		WHERE RC.intInventoryReceiptId = A.intInventoryReceiptId AND RC.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
	) C   
	WHERE A.intInventoryReceiptId = @receiptId
	END
	
END

--UPDATE VOUCHER DATA
DECLARE @totalCreatedVouchers INT = (SELECT COUNT(*) FROM #tmpReceiptBillIds);
DECLARE @voucherCount INT = 0;
DECLARE @currentVoucher INT;

IF OBJECT_ID(N'tempdb..#tmpVouchersCreated') IS NOT NULL DROP TABLE #tmpVouchersCreated
SELECT * INTO #tmpVouchersCreated FROM #tmpReceiptBillIds

WHILE @voucherCount != @totalCreatedVouchers
BEGIN
	SET @voucherCount = @voucherCount + 1;
	SELECT TOP(1) @currentVoucher = intBillId FROM #tmpVouchersCreated

	UPDATE A
	SET --A.dblTotal = (SELECT SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @generatedBillId) AP-2116
	A.dblTax = ISNULL((SELECT SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = @generatedBillId),0)
	FROM tblAPBill A
	WHERE intBillId = @currentVoucher

	UPDATE A
		SET A.dblSubtotal = Details.dblTotal--ISNULL(dblTotal - (SELECT SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = @currentVoucher),0)--AP-3180 Update the subtotal when posting directly from Scale
		,A.dblTotal = Details.dblTotal--ISNULL(dblTotal - (SELECT SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = @currentVoucher),0)--AP-3180 Update the subtotal when posting directly from Scale
		,A.dblAmountDue = Details.dblTotal
	FROM tblAPBill A
	CROSS APPLY (
		SELECT
			SUM(ISNULL(dblTotal,0) + ISNULL(dblTax,0)) AS dblTotal
		FROM tblAPBillDetail B
		WHERE B.intBillId = A.intBillId
	) Details
	WHERE intBillId = @currentVoucher
	
	SELECT @shipFrom = intShipFromId, @shipTo = intShipToId FROM tblAPBill WHERE intBillId = @currentVoucher
	EXEC uspAPBillUpdateAddressInfo @generatedBillId, @shipFrom, @shipTo

	--UPDATE Term of Voucher base on Contract term AP-3450
	SELECT	TOP 1 
			@contractTermId = ContractTerm.intTermId,
			@balanceDue = (SELECT intBalanceDue FROM dbo.tblSMTerm WHERE intTermID = ContractTerm.intTermId),
			@receipttDate = ContractTerm.dtmReceiptDate
	FROM	tblAPBill Voucher
	CROSS APPLY (
		SELECT TOP 1
			ct.intTermId, r.dtmReceiptDate
		FROM tblAPBillDetail VoucherDetail
		INNER JOIN tblCTContractHeader ct
			ON VoucherDetail.intContractHeaderId = ct.intContractHeaderId
		LEFT JOIN dbo.tblICInventoryReceiptItem ri
			ON ri.intInventoryReceiptItemId = VoucherDetail.intInventoryReceiptItemId
		LEFT JOIN dbo.tblICInventoryReceipt r
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		WHERE VoucherDetail.intBillId = @currentVoucher
	) ContractTerm

	IF @contractTermId > 0
	BEGIN
		UPDATE Voucher
			SET Voucher.intTermsId = @contractTermId, Voucher.dtmDueDate = ISNULL(dbo.fnGetDueDateBasedOnTerm(@receipttDate, @contractTermId), Voucher.dtmDueDate)
		FROM tblAPBill Voucher
		WHERE Voucher.intBillId = @currentVoucher
	END
	
	--INSERT BILLDETAIL CHARGE TAX
	IF(@chargeQty != 0)
	BEGIN
	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
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
		[intBillDetailId]		=	D.intBillDetailId, 
		[intTaxGroupId]			=	A.intTaxGroupId, 
		[intTaxCodeId]			=	A.intTaxCodeId, 
		[intTaxClassId]			=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	A.strCalculationMethod, 
		[dblRate]				=	A.dblRate, 
		[intAccountId]			=	A.intTaxAccountId, 
		[dblTax]				=	(CASE WHEN ISNULL(B.intEntityVendorId,E.intEntityVendorId) != (SELECT TOP 1 intEntityVendorId FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId) AND ysnCheckoffTax = 0 THEN  (CASE WHEN B.ysnPrice = 1 AND A.dblTax > 0 THEN A.dblTax * -1 ELSE ABS(A.dblTax) END) 
										  WHEN ISNULL(B.intEntityVendorId,E.intEntityVendorId) != (SELECT TOP 1 intEntityVendorId FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId) AND ysnCheckoffTax = 1 THEN A.dblTax * -1
											-- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN 
											ELSE (CASE WHEN B.ysnPrice = 1 AND A.dblTax > 0 THEN A.dblTax * -1 ELSE A.dblTax END) END), 
		[dblAdjustedTax]		=	(CASE WHEN ISNULL(B.intEntityVendorId,E.intEntityVendorId) != (SELECT TOP 1 intEntityVendorId FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId) AND ysnCheckoffTax = 0 THEN (CASE WHEN B.ysnPrice = 1  AND A.dblTax > 0  THEN A.dblTax  ELSE ABS(dblAdjustedTax) END) 
										  WHEN ISNULL(B.intEntityVendorId,E.intEntityVendorId) != (SELECT TOP 1 intEntityVendorId FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @receiptId) AND ysnCheckoffTax = 1 THEN dblAdjustedTax * -1
											-- RECEIPT VENDOR: WILL NEGATE THE TAX IF PRCE DOWN 
											ELSE (CASE WHEN B.ysnPrice = 1 AND dblAdjustedTax > 0 THEN dblAdjustedTax * -1  ELSE dblAdjustedTax END) END), 
		[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	0, 
		[ysnCheckOffTax]		=	A.ysnCheckoffTax
	FROM tblICInventoryReceiptChargeTax A
	INNER JOIN dbo.tblICInventoryReceiptCharge B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN dbo.tblAPBillDetail D ON D.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	INNER JOIN dbo.tblAPBill E ON E.intBillId = D.intBillId
	AND B.intInventoryReceiptId IN (@receiptId) AND D.intBillId  = @currentVoucher
	END
	DELETE FROM #tmpReceiptIds WHERE intInventoryReceiptId = @receiptId  
	DELETE FROM #tmpVouchersCreated WHERE intBillId = @currentVoucher
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

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReceiptData')) DROP TABLE #tmpReceiptData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReceiptDetailData')) DROP TABLE #tmpReceiptDetailData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpReceiptDetailTaxData')) DROP TABLE #tmpReceiptDetailTaxData
