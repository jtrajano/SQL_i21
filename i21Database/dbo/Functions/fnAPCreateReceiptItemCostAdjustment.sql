﻿CREATE FUNCTION [dbo].[fnAPCreateReceiptItemCostAdjustment]
(
	@voucherIds AS Id READONLY,
	@intFunctionalCurrencyId INT
)
RETURNS @returntable TABLE (
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
	,[intItemId] INT NOT NULL								-- The item. 
	,[intItemLocationId] INT NULL							-- The location where the item is stored.
	,[intItemUOMId] INT NULL								-- The UOM used for the item.
	,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
	,[dblQty] NUMERIC(38, 20) NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
	,[dblUOMQty] NUMERIC(38, 20) NULL DEFAULT 1				-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
	,[intCostUOMId] INT NULL								-- The uom related to the cost of the item. Ex: A box can be priced as $4 per LB. 
	--,[dblVoucherCost] NUMERIC(38, 20) NULL DEFAULT 0		-- Cost of the item. It must be related to the cost uom. Ex: $4/LB. 
	,[dblNewValue] NUMERIC(38, 20) NULL
	,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
	--,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
	,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
	,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
	,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
	,[intLotId] INT NULL									-- Place holder field for lot numbers
	,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
	,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
	,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
	,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- If there is a value, this means the item is used in Actual Costing. 
	,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
	,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
	,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
	,[intRelatedInventoryTransactionId] INT NULL 
	,[intFobPointId] TINYINT NULL
	,[intInTransitSourceLocationId] INT NULL 
	,[intOtherChargeItemId] INT NULL
)
AS
BEGIN
	INSERT @returntable(
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] 
		,[intCostUOMId] 
		--,[dblVoucherCost] 
		,[dblNewValue]
		,[intCurrencyId] 
		--,[dblExchangeRate] 
		,[intTransactionId] 
		,[intTransactionDetailId] 
		,[strTransactionId] 
		,[intTransactionTypeId] 
		,[intLotId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[ysnIsStorage] 
		,[strActualCostId] 
		,[intSourceTransactionId] 
		,[intSourceTransactionDetailId] 
		,[strSourceTransactionId] 
		,[intFobPointId]
		,[intInTransitSourceLocationId]
	)
	--INVENTORY RECEIPT
	SELECT
		[intItemId]							=	B.intItemId
		,[intItemLocationId]				=	D.intItemLocationId
		,[intItemUOMId]						=   itemUOM.intItemUOMId
		,[dtmDate] 							=	A.dtmDate
		,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END 
		,[dblUOMQty] 						=	itemUOM.dblUnitQty
		,[intCostUOMId]						=	voucherCostUOM.intItemUOMId 
		-- ,[dblNewCost] 						=	CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 
		-- 												-- Convert the voucher cost to the functional currency. 
		-- 												dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost) * ISNULL(B.dblRate, 0) 
		-- 											ELSE 
		-- 												dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost)
		-- 										END 
		,[dblNewValue]						= 

												/*
													New Formula: 
													Cost Adjustment Value = 
													[Voucher Qty x Voucher Cost] - [Voucher Qty x Receipt Cost]												
												*/
												CAST(
												dbo.fnMultiply(
													--[Voucher Qty]
													CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													--[Voucher Cost]
													,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
															dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
																COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
														ELSE 
															dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
																COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
													END 													
												)
												AS DECIMAL(18,2))
												- 
												CAST(
												dbo.fnMultiply(
													--[Voucher Qty]
													CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													
													,--[Receipt Cost]
													CASE WHEN E2.ysnSubCurrency = 1 AND E1.intSubCurrencyCents <> 0 THEN 
															CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
																	dbo.fnCalculateCostBetweenUOM(
																		receiptCostUOM.intItemUOMId
																		, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																		, E2.dblUnitCost
																	) 
																	/ E1.intSubCurrencyCents
																	* E2.dblForexRate
																ELSE 
																	dbo.fnCalculateCostBetweenUOM(
																		receiptCostUOM.intItemUOMId
																		, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																		, E2.dblUnitCost
																	) 
																	/ E1.intSubCurrencyCents
															END 
														ELSE
															CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
																dbo.fnCalculateCostBetweenUOM(
																	receiptCostUOM.intItemUOMId
																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																	, E2.dblUnitCost
																) 
																* E2.dblForexRate
															ELSE 
																dbo.fnCalculateCostBetweenUOM(
																	receiptCostUOM.intItemUOMId
																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																	, E2.dblUnitCost
																) 
														END 
													END
												)
												AS DECIMAL(18,2))
		,[intCurrencyId] 					=	@intFunctionalCurrencyId -- It is always in functional currency. 
		--,[dblExchangeRate] 					=	1 -- Exchange rate is always 1. 
		,[intTransactionId]					=	A.intBillId
		,[intTransactionDetailId] 			=	B.intBillDetailId
		,[strTransactionId] 				=	A.strBillId
		,[intTransactionTypeId] 			=	transType.intTransactionTypeId
		,[intLotId] 						=	NULL 
		,[intSubLocationId] 				=	E2.intSubLocationId
		,[intStorageLocationId] 			=	E2.intStorageLocationId
		,[ysnIsStorage] 					=	0
		,[strActualCostId] 					=	E2.strActualCostId
		,[intSourceTransactionId] 			=	E2.intInventoryReceiptId
		,[intSourceTransactionDetailId] 	=	E2.intInventoryReceiptItemId
		,[strSourceTransactionId] 			=	E1.strReceiptNumber
		,[intFobPointId]					=	fp.intFobPointId
		,[intInTransitSourceLocationId]		=	NULL --sourceLocation.intItemLocationId
		FROM @voucherIds ids
		INNER JOIN tblAPBill A ON A.intBillId = ids.intId
		INNER JOIN tblAPBillDetail B
			ON A.intBillId = B.intBillId
		INNER JOIN (
			tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
				ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
			LEFT JOIN tblICItemLocation sourceLocation
				ON sourceLocation.intItemId = E2.intItemId
				AND sourceLocation.intLocationId = E1.intLocationId
			LEFT JOIN tblSMFreightTerms ft
				ON ft.intFreightTermId = E1.intFreightTermId
			LEFT JOIN tblICFobPoint fp
				ON fp.strFobPoint = ft.strFreightTerm
		)
			ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
		INNER JOIN tblICItem item 
			ON B.intItemId = item.intItemId
		INNER JOIN tblICItemLocation D
			ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
		LEFT JOIN tblICItemUOM itemUOM
			ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
		LEFT JOIN tblICItemUOM voucherCostUOM
			ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
		LEFT JOIN tblICItemUOM receiptCostUOM
			ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
		LEFT JOIN tblICInventoryTransactionType transType
			ON transType.strName = 'Bill' -- 'Cost Adjustment'

		WHERE	 
			B.intInventoryReceiptChargeId IS NULL 
		AND B.intInventoryReceiptItemId > 0
		AND E2.intOwnershipType != 2
		AND item.strType IN ('Inventory','Finished Good','Raw Material')
		-- Compare the cost used in Voucher against the IR cost. 
		-- Compare the ForexRate use in Voucher against IR Rate
		-- If there is a difference, add it to @adjustedEntries table variable. 
		AND (
			dbo.fnCalculateCostBetweenUOM(
				voucherCostUOM.intItemUOMId
				,receiptCostUOM.intItemUOMId
				,B.dblCost - (B.dblCost * (B.dblDiscount / 100))
				) <> E2.dblUnitCost
			OR E2.dblForexRate <> B.dblRate
		) 
		UNION ALL
		--SETTLE STORAGE
		--ITEM
		SELECT
			[intItemId]							=	C.intItemId
			,[intItemLocationId]				=	E.intItemLocationId
			,[intItemUOMId]						=	F.intItemUOMId
			,[dtmDate]							=	A.dtmDate
			,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END 
			,[dblUOMQty] 						=	F.dblUnitQty
			,[intCostUOMId]						=	B.intUnitOfMeasureId 
			,[dblNewValue]						=	CAST(
													dbo.fnMultiply(
														--[Voucher Qty]
														CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
														--[Voucher Cost]
														,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
																dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
																	COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																	(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
															ELSE 
																dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
																	COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																	(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
														END 													
													)
													AS DECIMAL(18,2)) 
													- sh.dblPaidAmount
			,[intCurrencyId] 					=	@intFunctionalCurrencyId -- It is always in functional currency. 
			,[intTransactionId]					=	A.intBillId
			,[intTransactionDetailId] 			=	B.intBillDetailId
			,[strTransactionId] 				=	A.strBillId
			,[intTransactionTypeId] 			=	27
			,[intLotId] 						=	NULL 
			,[intSubLocationId] 				=	C.intCompanyLocationSubLocationId
			,[intStorageLocationId] 			=	C.intStorageLocationId
			,[ysnIsStorage] 					=	0
			,[strActualCostId] 					=	NULL
			,[intSourceTransactionId] 			=	C3.intSettleStorageId
			,[intSourceTransactionDetailId] 	=	C2.intSettleStorageTicketId
			,[strSourceTransactionId] 			=	C3.strStorageTicket
			,[intFobPointId]					=	NULL
			,[intInTransitSourceLocationId]		=	NULL
		FROM @voucherIds ids
		INNER JOIN tblAPBill A ON A.intBillId = ids.intId
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN tblGRSettleStorage C3 ON A.intBillId = C3.intBillId
		INNER JOIN tblGRSettleStorageTicket C2 ON C3.intSettleStorageId = C2.intSettleStorageId
		INNER JOIN tblGRCustomerStorage C ON C2.intCustomerStorageId = C.intCustomerStorageId AND B.intCustomerStorageId = C.intCustomerStorageId
		INNER JOIN tblGRStorageHistory sh 
			ON sh.intCustomerStorageId = C2.intCustomerStorageId AND sh.intSettleStorageId = C3.intSettleStorageId 
				AND ISNULL(sh.intContractHeaderId,-1) = ISNULL(B.intContractHeaderId,-1)
		INNER JOIN tblGRTransferStorageReference TSR ON TSR.intToCustomerStorageId = C.intCustomerStorageId
		INNER JOIN tblGRTransferStorage TS ON TS.intTransferStorageId = TSR.intTransferStorageId
		INNER JOIN tblICItem D ON B.intItemId = D.intItemId
		INNER JOIN tblICItemLocation E ON C.intCompanyLocationId = E.intLocationId AND E.intItemId = D.intItemId
		INNER JOIN tblICItemUOM F ON D.intItemId = F.intItemId AND C.intItemUOMId = F.intItemUOMId
		INNER JOIN tblSCTicket G ON C.intTicketId = G.intTicketId
		LEFT JOIN tblICItemUOM voucherCostUOM
			ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
		WHERE sh.dblPaidAmount != B.dblCost AND B.intCustomerStorageId > 0 AND D.strType = 'Inventory' AND TS.intTransferStorageId IS NULL
		-- UNION ALL
		-- --DISCOUNTS
		-- SELECT
		-- 	[intItemId]							=	C.intItemId
		-- 	,[intItemLocationId]				=	E.intItemLocationId
		-- 	,[intItemUOMId]						=	J.intItemUOMId
		-- 	,[dtmDate]							=	A.dtmDate
		-- 	,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END 
		-- 	,[dblUOMQty] 						=	F.dblUnitQty
		-- 	,[intCostUOMId]						=	B.intUnitOfMeasureId 
		-- 	,[dblNewValue]						=	B.dblCost - H.dblDiscountPaid
		-- 	,[intCurrencyId] 					=	@intFunctionalCurrencyId -- It is always in functional currency. 
		-- 	,[intTransactionId]					=	A.intBillId
		-- 	,[intTransactionDetailId] 			=	B.intBillDetailId
		-- 	,[strTransactionId] 				=	A.strBillId
		-- 	,[intTransactionTypeId] 			=	27
		-- 	,[intLotId] 						=	NULL 
		-- 	,[intSubLocationId] 				=	C.intCompanyLocationSubLocationId
		-- 	,[intStorageLocationId] 			=	C.intStorageLocationId
		-- 	,[ysnIsStorage] 					=	0
		-- 	,[strActualCostId] 					=	NULL
		-- 	,[intSourceTransactionId] 			=	1
		-- 	,[intSourceTransactionDetailId] 	=	C.intCustomerStorageId
		-- 	,[strSourceTransactionId] 			=	G.strTicketNumber
		-- 	,[intFobPointId]					=	NULL
		-- 	,[intInTransitSourceLocationId]		=	NULL
		-- FROM @voucherIds ids
		-- INNER JOIN tblAPBill A ON A.intBillId = ids.intId
		-- INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		-- INNER JOIN tblGRSettleStorage C3 ON A.intBillId = C3.intBillId
		-- INNER JOIN tblGRSettleStorageTicket C2 ON C3.intSettleStorageId = C2.intSettleStorageId
		-- INNER JOIN tblGRCustomerStorage C ON C2.intCustomerStorageId = C.intCustomerStorageId AND B.intCustomerStorageId = C.intCustomerStorageId
		-- INNER JOIN tblQMTicketDiscount H ON C.intCustomerStorageId = H.intTicketFileId 
		-- INNER JOIN tblGRDiscountScheduleCode I ON H.intDiscountScheduleCodeId = I.intDiscountScheduleCodeId AND I.intItemId = B.intItemId
		-- INNER JOIN tblICItem D ON I.intItemId = D.intItemId 
		-- INNER JOIN tblICItemLocation E ON C.intCompanyLocationId = E.intLocationId AND E.intItemId = D.intItemId
		-- INNER JOIN tblSCTicket G ON C.intTicketId = G.intTicketId
		-- INNER JOIN tblICCommodityUnitMeasure F ON C.intCommodityId = F.intCommodityId AND F.ysnStockUnit = 1
		-- INNER JOIN tblICItemUOM J ON F.intUnitMeasureId = J.intUnitMeasureId AND D.intItemId = J.intItemId
		-- WHERE H.dblDiscountPaid != B.dblCost AND B.intCustomerStorageId > 0 AND D.strType != 'Inventory'
		-- AND H.strSourceType = 'Storage'

		UNION ALL
		--TRANSFER STORAGE
		--ITEM
		SELECT
			[intItemId]							=	C.intItemId
			,[intItemLocationId]				=	E.intItemLocationId
			,[intItemUOMId]						=	F.intItemUOMId
			,[dtmDate]							=	A.dtmDate
			,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END 
			,[dblUOMQty] 						=	F.dblUnitQty
			,[intCostUOMId]						=	B.intUnitOfMeasureId 
			,[dblNewValue]						=	CAST(
													dbo.fnMultiply(
														--[Voucher Qty]
														CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
														--[Voucher Cost]
														,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
																dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
																	COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																	(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
															ELSE 
																dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
																	COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																	(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
														END 													
													)
													AS DECIMAL(18,2)) 
													- sh.dblPaidAmount
			,[intCurrencyId] 					=	@intFunctionalCurrencyId -- It is always in functional currency. 
			,[intTransactionId]					=	A.intBillId
			,[intTransactionDetailId] 			=	B.intBillDetailId
			,[strTransactionId] 				=	A.strBillId
			,[intTransactionTypeId] 			=	27
			,[intLotId] 						=	NULL 
			,[intSubLocationId] 				=	C.intCompanyLocationSubLocationId
			,[intStorageLocationId] 			=	C.intStorageLocationId
			,[ysnIsStorage] 					=	0
			,[strActualCostId] 					=	NULL
			,[intSourceTransactionId] 			=	TS.intTransferStorageId
			,[intSourceTransactionDetailId] 	=	TSS.intTransferStorageSplitId
			,[strSourceTransactionId] 			=	TS.strTransferStorageTicket
			,[intFobPointId]					=	NULL
			,[intInTransitSourceLocationId]		=	NULL
		FROM @voucherIds ids
		INNER JOIN tblAPBill A ON A.intBillId = ids.intId 
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN tblGRSettleStorage C3 ON A.intBillId = C3.intBillId
		INNER JOIN tblGRSettleStorageTicket C2 ON C3.intSettleStorageId = C2.intSettleStorageId
		INNER JOIN tblGRCustomerStorage C ON C2.intCustomerStorageId = C.intCustomerStorageId AND B.intCustomerStorageId = C.intCustomerStorageId
		INNER JOIN tblGRStorageHistory sh 
			ON sh.intCustomerStorageId = C2.intCustomerStorageId AND sh.intSettleStorageId = C3.intSettleStorageId 
		INNER JOIN tblGRTransferStorageReference TSR ON TSR.intToCustomerStorageId = C.intCustomerStorageId
		INNER JOIN tblGRTransferStorage TS ON TS.intTransferStorageId = TSR.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TSS on TSS.intTransferStorageId = TS.intTransferStorageId
		INNER JOIN tblICItem D ON B.intItemId = D.intItemId
		INNER JOIN tblICItemLocation E ON C.intCompanyLocationId = E.intLocationId AND E.intItemId = D.intItemId
		INNER JOIN tblICItemUOM F ON D.intItemId = F.intItemId AND C.intItemUOMId = F.intItemUOMId
		INNER JOIN tblSCTicket G ON C.intTicketId = G.intTicketId
		LEFT JOIN tblICItemUOM voucherCostUOM
			ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
		WHERE sh.dblPaidAmount != B.dblCost AND B.intCustomerStorageId > 0 AND D.strType = 'Inventory'

	RETURN;
END
