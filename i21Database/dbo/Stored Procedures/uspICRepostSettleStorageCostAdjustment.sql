CREATE PROCEDURE [dbo].[uspICRepostSettleStorageCostAdjustment]
	@strSettleTicketId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Rebuild the cost adjustment using the Storage History. 
-- This means (1) tblGRStorageHistory will be linked with (2) tblICInventoryReceiptItem and (3) tblAPBillDetail. 
-- (1) - The storage history holds when the DP stock was settled. 
-- (2) - The IR tables are used to source ids (i.e., intSourceTransactionId and intSourceTransactionDetailId) to ensure the cost adjustment will happen. 
-- (3) - The Voucher table is used to get the cost. Grain tables does not have this data. We can only get the cost from the Voucher. 
BEGIN 
	DECLARE @adjustCostOfDelayedPricingStock AS ItemCostAdjustmentTableType
	DECLARE @GLEntries AS RecapTableType 
	DECLARE @intDefaultCurrencyId AS INT 

	SELECT	@intDefaultCurrencyId = intDefaultCurrencyId 
	FROM	tblSMCompanyPreference

	INSERT INTO @adjustCostOfDelayedPricingStock (
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] 
		,[intCostUOMId] 
		,[dblVoucherCost] 
		,[intCurrencyId] 
		,[dblExchangeRate] 
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
	SELECT
			[intItemId]							=	vd.intItemId 
			,[intItemLocationId]				=	il.intItemLocationId
			,[intItemUOMId]						=   qtyItemUOM.intItemUOMId
			,[dtmDate] 							=	v.dtmBillDate
			,[dblQty] 							=	vd.dblQtyReceived
			,[dblUOMQty] 						=	qtyItemUOM.dblUnitQty
			,[intCostUOMId]						=	vd.intCostUOMId 
			,[dblNewCost] 						=	vd.dblCost
			,[intCurrencyId] 					=	@intDefaultCurrencyId -- Always default to the functional currency. 
			,[dblExchangeRate] 					=	1 -- Since it is using the default currency, the exchange rate is set to 1. 
			,[intTransactionId]					=	SH.[intCustomerStorageId]
			,[intTransactionDetailId] 			=	SH.[intCustomerStorageId]
			,[strTransactionId] 				=	SH.strSettleTicket
			,[intTransactionTypeId] 			=	transType.intTransactionTypeId
			,[intLotId] 						=	NULL 
			,[intSubLocationId] 				=	NULL 
			,[intStorageLocationId] 			=	NULL 
			,[ysnIsStorage] 					=	0
			,[strActualCostId] 					=	NULL 
			,[intSourceTransactionId] 			=	r.intInventoryReceiptId
			,[intSourceTransactionDetailId] 	=	ri.intInventoryReceiptItemId
			,[strSourceTransactionId] 			=	r.strReceiptNumber
			,[intFobPointId]					=	NULL 
			,[intInTransitSourceLocationId]		=	NULL 
	FROM	tblGRStorageHistory SH INNER JOIN tblGRCustomerStorage CS 
				ON SH.intCustomerStorageId = CS.intCustomerStorageId
			INNER JOIN tblGRStorageType St 
				ON St.intStorageScheduleTypeId = CS.intStorageTypeId 
				AND St.ysnDPOwnedType = 1
			INNER JOIN tblSCTicket t
				ON t.intTicketId = CS.intTicketId 
			INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					AND r.strReceiptType = 'Purchase Contract'
					AND r.intSourceType = 1 -- '1 = Scale' 
			)
				ON ri.intSourceId = t.intTicketId
				AND ri.intLineNo = t.intContractId
				AND ri.intItemId = t.intItemId
			INNER JOIN (
				tblAPBill v INNER JOIN tblAPBillDetail vd
					ON v.intBillId = vd.intBillId
			)
				ON v.intBillId = SH.intBillId
				AND vd.intItemId = ri.intItemId
				AND vd.intContractDetailId = t.intContractId 

			LEFT JOIN tblICItemLocation il
				ON il.intItemId = vd.intItemId
				AND il.intLocationId = r.intLocationId 

			LEFT JOIN tblICItemUOM qtyItemUOM
				ON qtyItemUOM.intItemUOMId = vd.intUnitOfMeasureId
							
			LEFT JOIN tblICInventoryTransactionType transType
				ON transType.strName = 'Settle Storage'			

	WHERE	SH.strSettleTicket = @strSettleTicketId 

	-- NOTES: 
	-- tblICInventoryReceiptItem.intSourceId	= Scale Ticket Id
	-- tblICInventoryReceiptItem.intOrderId		= Contract Header Id 
	-- tblICInventoryReceiptItem.intLineNo		= Contract Detail Id
	-- tblSCTicket.intContractId				= Contract Detail Id

	IF EXISTS(SELECT TOP 1 1 FROM @adjustCostOfDelayedPricingStock)
	BEGIN
		INSERT INTO @GLEntries (
			dtmDate						
			,strBatchId					
			,intAccountId				
			,dblDebit					
			,dblCredit					
			,dblDebitUnit				
			,dblCreditUnit				
			,strDescription				
			,strCode					
			,strReference				
			,intCurrencyId				
			,dblExchangeRate			
			,dtmDateEntered				
			,dtmTransactionDate			
			,strJournalLineDescription  
			,intJournalLineNo			
			,ysnIsUnposted				
			,intUserId					
			,intEntityId				
			,strTransactionId			
			,intTransactionId			
			,strTransactionType			
			,strTransactionForm			
			,strModuleName				
			,intConcurrencyId			
			,dblDebitForeign			
			,dblDebitReport				
			,dblCreditForeign			
			,dblCreditReport			
			,dblReportingRate			
			,dblForeignRate						
		)
		EXEC uspICPostCostAdjustment @adjustCostOfDelayedPricingStock, @strBatchId, @intEntityUserSecurityId
	END

	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC uspGLBookEntries @GLEntries, 1
	END 			
END 

_Exit:
