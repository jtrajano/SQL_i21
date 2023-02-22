CREATE PROCEDURE uspSCDeliverySheetShrinkage
	@DeliverySheetId int
	,@InventoryAdjustmentId int 
	,@intEntityUserSecurityId int
	,@ysnPost bit = 1
AS


set nocount on

--return 


declare @DeliverySheetNumber nvarchar(100)
declare @DPOwned BIT = 1
declare @StorageCost decimal(18, 6)
declare @dblDSShrink NUMERIC(38, 20)
declare @dblTotalDSShrink NUMERIC(38, 20)
declare @CurrentDate datetime
DECLARE @APClearing AS APClearing;


select @DeliverySheetNumber =  strDeliverySheetNumber 
		,@dblDSShrink = dblShrink		
	from tblSCDeliverySheet  DeliverySheet		
	where intDeliverySheetId = @DeliverySheetId

select @StorageCost = isnull(dblBasis, 0) + isnull(dblSettlementPrice, 0)
	from tblGRCustomerStorage 
		where intDeliverySheetId = @DeliverySheetId
			and ysnTransferStorage = 0
select @CurrentDate = getdate()


UPDATE tblSCDeliverySheet
		set ysnInvolvedWithShrinkage = @ysnPost
	where intDeliverySheetId = @DeliverySheetId 

--
delete 
	from tblSCDeliverySheetShrinkReceiptDistribution
		where intDeliverySheetId = @DeliverySheetId

if @ysnPost = 1
begin

	
	if @DPOwned = 1 
	begin
		insert into tblSCDeliverySheetShrinkReceiptDistribution
		( intDeliverySheetId, intInventoryReceiptId, intInventoryReceiptItemId,  dblDSShrink, dblIRNet, dblComputedShrinkPerIR)
		select 
			Sheet.intDeliverySheetId	
			, ReceiptItem.intInventoryReceiptId
			, ReceiptItem.intInventoryReceiptItemId
			, Sheet.dblShrink
			, ReceiptItem.dblNet
			, round(dbo.fnMultiply(dbo.fnDivide(Sheet.dblShrink, (Sheet.dblNet + Sheet.dblShrink)) ,ReceiptItem.dblNet), 6)
		
		
			from tblSCDeliverySheet Sheet
			join tblSCTicket Ticket
				on Ticket.intDeliverySheetId = Sheet.intDeliverySheetId
			join tblSCTicketSplit Split
				on Ticket.intTicketId = Split.intTicketId
			join tblGRStorageType StorageType
				on Split.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId
					and StorageType.ysnDPOwnedType = 1						
			join tblICInventoryReceiptItem ReceiptItem
				on ReceiptItem.intSourceId = Ticket.intTicketId
					and ReceiptItem.intOwnershipType = 1
			join tblICInventoryReceipt Receipt
				on ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
					and Receipt.intSourceType = 1
					and Receipt.intEntityVendorId = Split.intCustomerId
			where 
				Sheet.dblShrink <> 0
				and Sheet.intDeliverySheetId = @DeliverySheetId

			select @dblTotalDSShrink = sum(dblComputedShrinkPerIR) 
				from tblSCDeliverySheetShrinkReceiptDistribution 
					where intDeliverySheetId = @DeliverySheetId
						and intInventoryReceiptItemId is not null

			if @dblTotalDSShrink <> @dblDSShrink
			begin
				insert into tblSCDeliverySheetShrinkReceiptDistribution
				( intDeliverySheetId, intInventoryReceiptId, intInventoryReceiptItemId,  dblDSShrink, dblIRNet, dblComputedShrinkPerIR)
				values(
					@DeliverySheetId, null, null, @dblDSShrink, 0, @dblDSShrink- @dblTotalDSShrink
				)

			end

			INSERT INTO @APClearing
			(
				[intTransactionId],			--TRANSACTION ID
				[strTransactionId],			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
				[intTransactionType],		--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
				[strReferenceNumber],		--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
				[dtmDate],					--TRANSACTION POST DATE
				[intEntityVendorId],		--TRANSACTION VENDOR ID
				[intLocationId],			--TRANSACTION LOCATION ID
				--DETAIL
				[intTransactionDetailId],	--TRANSACTION DETAIL ID
				[intAccountId],				--TRANSACTION ACCOUNT ID
				[intItemId],				--TRANSACTION ITEM ID
				[intItemUOMId],				--TRANSACTION ITEM UOM ID
				[dblQuantity],				--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
				[dblAmount],				--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
				--OFFSET TRANSACTION DETAILS
				[intOffsetId],				--TRANSACTION ID
				[strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
				[intOffsetDetailId],		--TRANSACTION DETAIL ID
				[intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
				--OTHER INFORMATION
				[strCode],					--TRANSACTION SOURCE MODULE E.G. IR, AP
				strRemarks					
			)
			select 
				Receipt.intInventoryReceiptId,											--TRANSACTION ID
				Receipt.strReceiptNumber,												--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
				1 as [intTransactionType],												--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
				DeliverySheet.strDeliverySheetNumber as [strReferenceNumber],			--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
				DeliverySheet.dtmDeliverySheetDate as [dtmDate],						--TRANSACTION POST DATE
				Receipt.intEntityVendorId as [intEntityVendorId],						--TRANSACTION VENDOR ID
				DeliverySheet.intCompanyLocationId as [intLocationId],					--TRANSACTION LOCATION ID
				--DETAIL
				ReceiptItem.[intInventoryReceiptItemId] as [intTransactionDetailId],	--TRANSACTION DETAIL ID
				APC.intAccountId as [intAccountId],										--TRANSACTION ACCOUNT ID
				ReceiptItem.intItemId as [intItemId],									--TRANSACTION ITEM ID
				ReceiptItem.intUnitMeasureId as [intItemUOMId],							--TRANSACTION ITEM UOM ID
				Shrink.dblComputedShrinkPerIR * -1 as [dblQuantity],							--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
				Shrink.dblComputedShrinkPerIR * ReceiptItem.dblUnitCost * -1 as [dblAmount],	--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
				--OFFSET TRANSACTION DETAILS
				DeliverySheet.intDeliverySheetId as [intOffsetId],					--TRANSACTION ID
				DeliverySheet.strDeliverySheetNumber as [strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
				null as [intOffsetDetailId],		--TRANSACTION DETAIL ID
				null as [intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
				--OTHER INFORMATION
				'SC' as [strCode],					--TRANSACTION SOURCE MODULE E.G. IR, AP
				'DS SHRINK' AS strRemarks
		
			from tblSCDeliverySheetShrinkReceiptDistribution Shrink
				join tblSCDeliverySheet DeliverySheet
					on Shrink.intDeliverySheetId = DeliverySheet.intDeliverySheetId				
				join tblICInventoryReceipt Receipt
					on Receipt.intInventoryReceiptId = Shrink.intInventoryReceiptId
				join tblICInventoryReceiptItem ReceiptItem
					on ReceiptItem.intInventoryReceiptItemId = Shrink.intInventoryReceiptItemId
				join tblGRCustomerStorage CustomerStorage
					on CustomerStorage.intDeliverySheetId = DeliverySheet.intDeliverySheetId
						and CustomerStorage.ysnTransferStorage = 0
						and Receipt.intEntityVendorId = CustomerStorage.intEntityId

			OUTER APPLY (
				SELECT [intAccountId] = dbo.fnGetItemGLAccount(DeliverySheet.intItemId, DeliverySheet.intCompanyLocationId, 'AP Clearing')
			) APC
			where DeliverySheet.intDeliverySheetId = @DeliverySheetId

			EXEC uspAPClearing @APClearing = @APClearing, @post = 1;

	end

	
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
			,@InventoryTransactionTypeId_AutoNegative AS INT = 1
			,@InventoryTransactionTypeId_WriteOffSold AS INT = 2
			,@InventoryTransactionTypeId_RevalueSold AS INT = 3
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35						
			
			,@ModuleName AS NVARCHAR(50) = 'Scale'
			,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
			,@AccountCategory_AP_Clearing AS NVARCHAR(255) = 'AP Clearing'
			,@AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
			,@AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment'
			,@GLEntries AS RecapTableType
			,@TRANSACTION_TYPE_INVENTORY_RECEIPT INT = 4
			,@TRANSACTION_TYPE_TRANSFER_STORAGE INT = 56					
			,@GLAccounts AS dbo.ItemGLAccount
			,@Code as nvarchar(10) = 'SC'
			,@TransactionType as nvarchar(50)= 'Delivery Sheet'
			,@GLDescription nvarchar(150) = 'Delivery Sheet Shrinkage:' + @DeliverySheetNumber
		
	
	declare @ItemIds table(
		id int
	)

	insert into @ItemIds(id)
	select intItemId 
		from tblICInventoryAdjustmentDetail
			where intInventoryAdjustmentId = @InventoryAdjustmentId

	-- Get the GL Account ids to use
	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 	
		,intContraInventoryId 
		,intAutoNegativeId 
		,intTransactionTypeId
	)
	SELECT	
		Query.intItemId
		,Query.intItemLocationId	
		,intContraInventoryId	= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_AP_Clearing) --@AccountCategory_ContraInventory) 
		,intAutoNegativeId		= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
		,intTransactionTypeId
	FROM (
		SELECT DISTINCT 
			t.intItemId
			,t.intItemLocationId
			,t.intTransactionTypeId
		FROM dbo.tblICInventoryTransaction t 
		INNER JOIN tblICItem i
			ON t.intItemId = i.intItemId 
		
		WHERE 
			t.intItemId in ( select id from @ItemIds) 
			AND i.strType <> 'Non-Inventory'
	) Query


	-- select * from @GLAccounts

			INSERT INTO @GLEntries 
			(
				[dtmDate]
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
				,[dblDebitForeign]
				,[dblDebitReport]
				,[dblCreditForeign]
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]			
				--,strComments
			)
			SELECT	
				dtmDate						= GLDetailFinTrax.dtmDate
				,strBatchId					= GLDetailFinTrax.strBatchId
				,intAccountId				= tblGLAccount.intAccountId
				,dblDebit					= Debit.Value
				,dblCredit					= Credit.Value
				,dblDebitUnit				= DebitUnit.Value
				,dblCreditUnit				= CreditUnit.Value
				,strDescription				= tblGLAccount.strDescription + '. ' + @GLDescription
				,strCode					= @Code
				,strReference				= '' 
				,intCurrencyId				= GLDetailFinTrax.intCurrencyId
				,dblExchangeRate			= GLDetailFinTrax.dblExchangeRate
				,dtmDateEntered				= GETDATE()
				,dtmTransactionDate			= GLDetailFinTrax.dtmDate
				,strJournalLineDescription  = '' 
				,intJournalLineNo			= @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
				,ysnIsUnposted				= case when @ysnPost = 1 then 0 else 1 end 
				,intUserId					= @intEntityUserSecurityId
				,intEntityId				= NULL 
				,strTransactionId			= @DeliverySheetNumber --Adjustment.strAdjustmentNo
				,intTransactionId			= @DeliverySheetId --Adjustment.intInventoryAdjustmentId
				,strTransactionType			= @TransactionType
				,strTransactionForm			= @TransactionType
				,strModuleName				= @ModuleName
				,intConcurrencyId			= 1
				,dblDebitForeign			= DebitForeign.Value 
				,dblDebitReport				= NULL 
				,dblCreditForeign			= CreditForeign.Value
				,dblCreditReport			= NULL 
				,dblReportingRate			= NULL 
				,dblForeignRate				= GLDetailFinTrax.dblForeignRate 			
			
		from tblICInventoryAdjustment Adjustment			
			--cross apply (
			--	select sum(dblDebit) as dblAmount
			--		,sum(dblDebitUnit) as dblUnit	
			--			from tblGLDetail 
			--				where strTransactionId = Adjustment.strAdjustmentNo
			--				 and strCode = 'IC'
			--				 and ysnIsUnposted = 0

			--) GLDetailData
			cross apply (
				select top 1 intCurrencyId					
					,dblExchangeRate
					,dblForeignRate
					,dtmDate
					,strBatchId
					,strDescription
						from tblGLDetail where strTransactionId = Adjustment.strAdjustmentNo
							 and strCode = 'IC'
							 and ysnIsUnposted = 0

			) GLDetailFinTrax
			join tblICInventoryAdjustmentDetail AdjustmentDetail
				on AdjustmentDetail.intInventoryAdjustmentId = Adjustment.intInventoryAdjustmentId
			join tblICItemLocation ItemLocation
				on AdjustmentDetail.intItemId = ItemLocation.intItemId
					and ItemLocation.intLocationId = Adjustment.intLocationId
			INNER JOIN @GLAccounts GLAccounts
				ON AdjustmentDetail.intItemId = GLAccounts.intItemId
				AND ItemLocation.intItemLocationId = GLAccounts.intItemLocationId
				AND 10 = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount
				ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		

		
			CROSS APPLY dbo.fnGetDebit(isnull(@StorageCost, AdjustmentDetail.dblCost) * abs(dblNewQuantity)) Debit
			CROSS APPLY dbo.fnGetCredit(isnull(@StorageCost, AdjustmentDetail.dblCost) * abs(dblNewQuantity)) Credit
			CROSS APPLY dbo.fnGetDebitForeign(
				AdjustmentDetail.dblCost * abs(dblNewQuantity)
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) DebitForeign
			CROSS APPLY dbo.fnGetCreditForeign(
				AdjustmentDetail.dblCost * abs(dblNewQuantity)
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) CreditForeign
			CROSS APPLY dbo.fnGetDebitUnit( abs(dblNewQuantity)) DebitUnit
			CROSS APPLY dbo.fnGetCreditUnit( abs(dblNewQuantity)) CreditUnit

		 where Adjustment.intInventoryAdjustmentId = @InventoryAdjustmentId

		 union all






		SELECT	
				dtmDate						= GLDetailFinTrax.dtmDate
				,strBatchId					= GLDetailFinTrax.strBatchId
				,intAccountId				= tblGLAccount.intAccountId
				,dblDebit					= Credit.Value
				,dblCredit					= Debit.Value
				,dblDebitUnit				= CreditUnit.Value
				,dblCreditUnit				= DebitUnit.Value
				,strDescription				= tblGLAccount.strDescription  + '. ' + @GLDescription
				,strCode					= @Code
				,strReference				= '' 
				,intCurrencyId				= GLDetailFinTrax.intCurrencyId
				,dblExchangeRate			= GLDetailFinTrax.dblExchangeRate
				,dtmDateEntered				= GETDATE()
				,dtmTransactionDate			= GLDetailFinTrax.dtmDate
				,strJournalLineDescription  = '' 
				,intJournalLineNo			= @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
				,ysnIsUnposted				= case when @ysnPost = 1 then 0 else 1 end 
				,intUserId					= @intEntityUserSecurityId
				,intEntityId				= NULL 
				,strTransactionId			= @DeliverySheetNumber --Adjustment.strAdjustmentNo
				,intTransactionId			= @DeliverySheetId --Adjustment.intInventoryAdjustmentId
				,strTransactionType			= @TransactionType
				,strTransactionForm			= @TransactionType
				,strModuleName				= @ModuleName
				,intConcurrencyId			= 1
				,dblDebitForeign			= DebitForeign.Value 
				,dblDebitReport				= NULL 
				,dblCreditForeign			= CreditForeign.Value
				,dblCreditReport			= NULL 
				,dblReportingRate			= NULL 
				,dblForeignRate				= GLDetailFinTrax.dblForeignRate 
		from tblICInventoryAdjustment Adjustment			
			--cross apply (
			--	select sum(dblDebit) as dblAmount
			--		,sum(dblDebitUnit) as dblUnit	
			--			from tblGLDetail where strTransactionId = Adjustment.strAdjustmentNo
			--				 and strCode = 'IC'
			--				 and ysnIsUnposted = 0

			--) GLDetailData
			cross apply (
				select top 1 intCurrencyId					
					,dblExchangeRate
					,dblForeignRate
					,dtmDate
					,strBatchId
					,strDescription
						from tblGLDetail 
							where strTransactionId = Adjustment.strAdjustmentNo
							 and strCode = 'IC'
							 and ysnIsUnposted = 0

			) GLDetailFinTrax
			join tblICInventoryAdjustmentDetail AdjustmentDetail
				on AdjustmentDetail.intInventoryAdjustmentId = Adjustment.intInventoryAdjustmentId
			join tblICItemLocation ItemLocation
				on AdjustmentDetail.intItemId = ItemLocation.intItemId
					and ItemLocation.intLocationId = Adjustment.intLocationId
			INNER JOIN @GLAccounts GLAccounts
				ON AdjustmentDetail.intItemId = GLAccounts.intItemId
				AND ItemLocation.intItemLocationId = GLAccounts.intItemLocationId
				AND 10 = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount
				ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId

			CROSS APPLY dbo.fnGetDebit(isnull(@StorageCost, AdjustmentDetail.dblCost) * abs(dblNewQuantity)) Debit
			CROSS APPLY dbo.fnGetCredit(isnull(@StorageCost, AdjustmentDetail.dblCost) * abs(dblNewQuantity)) Credit
			CROSS APPLY dbo.fnGetDebitForeign(
				AdjustmentDetail.dblCost * abs(dblNewQuantity)
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) DebitForeign
			CROSS APPLY dbo.fnGetCreditForeign(
				AdjustmentDetail.dblCost * abs(dblNewQuantity)
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) CreditForeign
			CROSS APPLY dbo.fnGetDebitUnit(abs(dblNewQuantity)) DebitUnit
			CROSS APPLY dbo.fnGetCreditUnit(abs(dblNewQuantity)) CreditUnit


		 where Adjustment.intInventoryAdjustmentId = @InventoryAdjustmentId

		if exists ( select top 1 1 from @GLEntries)
			EXEC uspGLBookEntries @GLEntries, @ysnPost	


end
else 
begin
	if @DPOwned = 1 
	begin	
		declare @strCode nvarchar(2) = 'SC'
		delete from @APClearing
		INSERT INTO @APClearing
		(
			[intTransactionId],			--TRANSACTION ID
			[strTransactionId],			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
			[intTransactionType],		--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
			[strReferenceNumber],		--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
			[dtmDate],					--TRANSACTION POST DATE
			[intEntityVendorId],		--TRANSACTION VENDOR ID
			[intLocationId],			--TRANSACTION LOCATION ID
			--DETAIL
			[intTransactionDetailId],	--TRANSACTION DETAIL ID
			[intAccountId],				--TRANSACTION ACCOUNT ID
			[intItemId],				--TRANSACTION ITEM ID
			[intItemUOMId],				--TRANSACTION ITEM UOM ID
			[dblQuantity],				--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
			[dblAmount],				--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
			--OFFSET TRANSACTION DETAILS
			[intOffsetId],				--TRANSACTION ID
			[strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
			[intOffsetDetailId],		--TRANSACTION DETAIL ID
			[intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
			--OTHER INFORMATION
			[strCode],					--TRANSACTION SOURCE MODULE E.G. IR, AP
			strRemarks
		)
		-- APC Entries for Item
		SELECT
			[intTransactionId],			--TRANSACTION ID
			[strTransactionId],			--TRANSACTION NUMBER E.G. IR-XXXX, PAT-XXXX
			[intTransactionType],		--TRANSACTION TYPE (DESIGNATED TRANSACTION NUMBERS ARE LISTED BELOW)
			[strReferenceNumber],		--TRANSACTION REFERENCE E.G. BOL NUMBER, INVOICE NUMBER
			[dtmDate],					--TRANSACTION POST DATE
			[intEntityVendorId],		--TRANSACTION VENDOR ID
			[intLocationId],			--TRANSACTION LOCATION ID
			--DETAIL
			[intTransactionDetailId],	--TRANSACTION DETAIL ID
			[intAccountId],				--TRANSACTION ACCOUNT ID
			[intItemId],				--TRANSACTION ITEM ID
			[intItemUOMId],				--TRANSACTION ITEM UOM ID
			[dblQuantity],				--TRANSACTION QUANTITY (WE CAN DIRECTLY PUT THE QUANTITY OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
			[dblAmount],				--TRANSACTION TOTAL (WE CAN DIRECTLY PUT THE AMOUNT OF THE TRANSACTION, uspAPClearing WILL AUTOMATICALLY NEGATE IT IF @post = 0)
			--OFFSET TRANSACTION DETAILS
			[intOffsetId],				--TRANSACTION ID
			[strOffsetId],				--TRANSACTION NUMBER E.G. BL-XXXX
			[intOffsetDetailId],		--TRANSACTION DETAIL ID
			[intOffsetDetailTaxId],		--TRANSACTION DETAIL TAX ID
			--OTHER INFORMATION
			[strCode],					--TRANSACTION SOURCE MODULE E.G. IR, AP
			'DS SHRINK' AS strRemarks
		FROM tblAPClearing
		WHERE       
			(intOffsetId = @DeliverySheetId
				AND strOffsetId = @DeliverySheetNumber
				and strCode = @strCode
				and strRemarks = 'DS SHRINK'
			)
    
		EXEC uspAPClearing @APClearing = @APClearing, @post = 0;
	end




	if exists(select top 1 1 from tblGLDetail 
					where strTransactionId = @DeliverySheetNumber 
						and ysnIsUnposted = 0 
						and strCode = 'SC' 
						and strTransactionType = 'Delivery Sheet')
	begin
		DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
		DECLARE @strBatchId NVARCHAR(100)
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT

		exec uspGLInsertReverseGLEntry 
			@strTransactionId = @DeliverySheetNumber
			,@intEntityId = @intEntityUserSecurityId
			,@dtmDateReverse  = @CurrentDate
			,@strBatchId = @strBatchId
			,@SkipICValidation = 1

	end
	

end
