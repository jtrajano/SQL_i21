CREATE PROCEDURE uspSCDeliverySheetShrinkage
	@DeliverySheetId int
	,@InventoryAdjustmentId int 
	,@intEntityUserSecurityId int
	,@ysnPost bit = 1
AS


set nocount on

declare @DeliverySheetNumber nvarchar(100)
declare @CurrentDate datetime

select @DeliverySheetNumber =  strDeliverySheetNumber from tblSCDeliverySheet where intDeliverySheetId = @DeliverySheetId
select @CurrentDate = getdate()

if @ysnPost = 1
begin
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
				,strDescription				= GLDetailFinTrax.strDescription
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
			cross apply (
				select sum(dblDebit) as dblAmount
					,sum(dblDebitUnit) as dblUnit	
						from tblGLDetail 
							where strTransactionId = Adjustment.strAdjustmentNo
							 and strCode = 'IC'
							 and ysnIsUnposted = 0

			) GLDetailData
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

			CROSS APPLY dbo.fnGetDebit(GLDetailData.dblAmount) Debit
			CROSS APPLY dbo.fnGetCredit(GLDetailData.dblAmount) Credit
			CROSS APPLY dbo.fnGetDebitForeign(
				GLDetailData.dblAmount
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) DebitForeign
			CROSS APPLY dbo.fnGetCreditForeign(
				GLDetailData.dblAmount
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) CreditForeign
			CROSS APPLY dbo.fnGetDebitUnit(GLDetailData.dblUnit) DebitUnit
			CROSS APPLY dbo.fnGetCreditUnit(GLDetailData.dblUnit) CreditUnit

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
				,strDescription				= GLDetailFinTrax.strDescription--ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) --+ 'Z'
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
			cross apply (
				select sum(dblDebit) as dblAmount
					,sum(dblDebitUnit) as dblUnit	
						from tblGLDetail where strTransactionId = Adjustment.strAdjustmentNo
							 and strCode = 'IC'
							 and ysnIsUnposted = 0

			) GLDetailData
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

			CROSS APPLY dbo.fnGetDebit(GLDetailData.dblAmount) Debit
			CROSS APPLY dbo.fnGetCredit(GLDetailData.dblAmount) Credit
			CROSS APPLY dbo.fnGetDebitForeign(
				GLDetailData.dblAmount
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) DebitForeign
			CROSS APPLY dbo.fnGetCreditForeign(
				GLDetailData.dblAmount
				,GLDetailFinTrax.intCurrencyId
				,@DefaultCurrencyId
				,GLDetailFinTrax.dblExchangeRate
			) CreditForeign
			CROSS APPLY dbo.fnGetDebitUnit(GLDetailData.dblUnit) DebitUnit
			CROSS APPLY dbo.fnGetCreditUnit(GLDetailData.dblUnit) CreditUnit


		 where Adjustment.intInventoryAdjustmentId = @InventoryAdjustmentId


		if exists ( select top 1 1 from @GLEntries)
			EXEC uspGLBookEntries @GLEntries, @ysnPost	


end
else 
begin
	
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
	DECLARE @strBatchId NVARCHAR(100)
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT

	exec uspGLInsertReverseGLEntry 
		@strTransactionId = @DeliverySheetNumber
		,@intEntityId = @intEntityUserSecurityId
		,@dtmDateReverse  = @CurrentDate
		,@strBatchId = @strBatchId

end