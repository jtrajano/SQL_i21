CREATE PROCEDURE [dbo].[uspGRCreateGLEntriesForTransferStorage]
	 @intTransferStorageId INT
	,@strBatchId AS NVARCHAR(40)
	,@dblCost DECIMAL(18,6)
	,@ysnPost AS BIT
	,@intTransactionTypeId INT = 56
	,@intTransferStorageReferenceId INT = NULL
AS
BEGIN TRY
BEGIN
	DECLARE
	 @ErrMsg					    NVARCHAR(MAX)
	,@intFunctionalCurrencyId		INT
	,@intScaleTicketId				INT
	,@LocationId					INT
	,@InventoryItemId				INT
	,@intItemLocationId				INT
	,@intEntityVendorId				INT
	,@intCurrencyId					INT
	,@intHaulerId					INT
	,@intFreightItemId				INT
	,@ysnAccrue					    BIT
	,@ysnPrice					    BIT
	,@ysnDeductFreightFarmer		BIT
	,@ysnDeductFeesCusVen		    BIT
	,@dblFreightRate				DECIMAL(24,10)
	,@dblUnits						DECIMAL(24,10)
	,@dblConvertedUnits				DECIMAL(24,10)
	,@dblGrossUnits					DECIMAL(24,10)
	,@intContractCostId				INT
	,@ysnIsStorage					BIT
	,@IntCommodityId				INT
	,@intStorageChargeItemId		INT
	,@intInventoryItemUOMId			INT
	,@intCSInventoryItemUOMId		INT
	,@intCustomerStorageId			INT
	,@StorageChargeItemDescription  NVARCHAR(100)

	DECLARE 
	@ACCOUNT_CATEGORY_Inventory				NVARCHAR(30) = 'Inventory'
	,@ACCOUNT_CATEGORY_APClearing			NVARCHAR(30) = 'AP Clearing'
	,@ACCOUNT_CATEGORY_OtherChargeExpense	NVARCHAR(30) = 'Other Charge Expense'
	,@ACCOUNT_CATEGORY_OtherChargeIncome	NVARCHAR(30) = 'Other Charge Income'
	,@ModuleName							NVARCHAR(50) = 'Grain'
	,@strCode								NVARCHAR(10) = 'TRA'
	,@strTransactionId						NVARCHAR(30)

	SELECT @strTransactionId = strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	SELECT @IntCommodityId = CS.intCommodityId from tblGRTransferStorage TS
	left join tblGRTransferStorageReference TSR on TSR.intTransferStorageId = TS.intTransferStorageId
	left join tblGRCustomerStorage CS on CS.intCustomerStorageId = TSR.intSourceCustomerStorageId where TS.intTransferStorageId = @intTransferStorageId

	SELECT TOP 1 @intStorageChargeItemId = intItemId
	FROM tblICItem 
	WHERE strType = 'Other Charge' 
	  AND strCostType = 'Storage Charge' 
	  AND intCommodityId = @IntCommodityId

	IF @intStorageChargeItemId IS NULL
	BEGIN
		SELECT TOP 1 @intStorageChargeItemId = intItemId
		FROM tblICItem
		WHERE strType = 'Other Charge' 
			AND strCostType = 'Storage Charge' 
			AND intCommodityId IS NULL
	END

	select  @intInventoryItemUOMId = intItemUOMId 
		from tblICInventoryTransaction 
			where intItemId = @InventoryItemId 
				and strBatchId = @strBatchId

	--Inventory Item
	SELECT 
		 @LocationId			= CS.intCompanyLocationId
		,@intCustomerStorageId  = CS.intCustomerStorageId
		,@intScaleTicketId		= CS.intTicketId
		,@intEntityVendorId		= CS.intEntityId 
		,@intCurrencyId			= CS.intCurrencyId
		,@InventoryItemId		= CS.intItemId  
		,@dblUnits				= SR.dblUnitQty--dbo.fnCalculateQtyBetweenUOM(CS.intItemUOMId, isnull(@intInventoryItemUOMId, CS.intItemUOMId) , SST.dblUnits) 
		,@dblGrossUnits			= ( 
									dbo.fnMultiply(
											case when @intInventoryItemUOMId is not null then dbo.fnCalculateQtyBetweenUOM(@intCSInventoryItemUOMId, (@intInventoryItemUOMId), CS.dblGrossQuantity) else  CS.dblGrossQuantity end
										, dbo.fnDivide(isnull(SR.dblSplitPercent, 100),	100)
										)
									)
		,@intCSInventoryItemUOMId = CS.intItemUOMId
	FROM tblGRTransferStorageReference SR
	JOIN tblGRCustomerStorage CS 
		ON SR.intSourceCustomerStorageId = CS.intCustomerStorageId
	WHERE SR.intTransferStorageId = @intTransferStorageId
		 AND SR.intTransferStorageReferenceId = @intTransferStorageReferenceId
	
	
	
			
	
	if @intInventoryItemUOMId is not null
		select @dblConvertedUnits = dbo.fnCalculateQtyBetweenUOM(@intCSInventoryItemUOMId, (@intInventoryItemUOMId), @dblUnits) 
	select @dblConvertedUnits = isnull(@dblConvertedUnits, @dblUnits)
	
	
	SELECT @intItemLocationId = intItemLocationId 
	FROM tblICItemLocation 
	WHERE intItemId = @InventoryItemId 
		AND intLocationId = @LocationId

	SELECT @StorageChargeItemDescription = strDescription
	FROM tblICItem
	WHERE intItemId = @intStorageChargeItemId
			
	DECLARE @tblOtherCharges AS TABLE
	(
		 [intItemId]					   INT
		,[strItemNo]	 				   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[intEntityVendorId]			   INT
		,[intCurrencyId]				   INT
		,[intCostCurrencyId]  			   INT
		,[intChargeId]					   INT
		,[intForexRateTypeId]			   INT
		,[dblForexRate] 				   DECIMAL(24,10)
		,[ysnInventoryCost] 			   BIT
		,[strCostMethod] 				   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[dblRate] 						   DECIMAL(24,10)
		,[intOtherChargeEntityVendorId]    INT
		,[dblAmount] 					   INT
		,[ysnAccrue]					   BIT
		,[ysnPrice]						   BIT
		,[intTicketDiscountId]			   INT
		,[dblUnits] 					   DECIMAL(24,10)
		,[dblConvertedUnits] 				DECIMAL(24,10)
	)

	INSERT INTO @tblOtherCharges
	(
		 [intItemId]
		,[strItemNo]
		,[intEntityVendorId]			
		,[intCurrencyId]				
		,[intCostCurrencyId]  			
		,[intChargeId]					
		,[intForexRateTypeId]			
		,[dblForexRate] 				
		,[ysnInventoryCost] 			
		,[strCostMethod] 				
		,[dblRate] 						
		,[intOtherChargeEntityVendorId] 
		,[dblAmount]	
		,[ysnAccrue]					
		,[ysnPrice]
		,[intTicketDiscountId]
		,[dblUnits]
		,[dblConvertedUnits] 	
	)
	--Discounts
	SELECT
		 [intItemId]						= IC.intItemId
		,[strItemNo]						= IC.strItemNo
		,[intEntityVendorId]				= @intEntityVendorId	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= DItem.intItemId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= DItem.ysnInventoryCost
		,[strCostMethod]					= DItem.strCostMethod
		,[dblRate]							= CASE
												WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * @dblCost											
												* 
														case when isnull(IC.strCostType, '') = 'Discount' and QM.dblDiscountAmount < 0 then 1 
														else  -1 end
												
												)

												WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount *  @dblCost)
												WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * 
												case when isnull(IC.strCostType, '') = 'Discount' and QM.dblDiscountAmount < 0 then 1 
														else  -1 end
												)
												WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount > 0 THEN QM.dblDiscountAmount
											END
		,[intOtherChargeEntityVendorId]		= @intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
													CASE 
														WHEN @ysnIsStorage = 1 THEN 0
														WHEN @ysnIsStorage = 0 THEN 0												
													END
											END
		,[ysnAccrue]						= case when isnull(IC.strCostType, '') = 'Discount' then
												0 
											else
												CASE
													WHEN QM.dblDiscountAmount < 0 THEN 1
													WHEN QM.dblDiscountAmount > 0 THEN 0
												END
											end
											/*CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END*/
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		,[intTicketDiscountId]				= QM.intTicketDiscountId
		,[dblUnits]							= CASE WHEN QM.strCalcMethod = 3 THEN @dblGrossUnits ELSE @dblUnits END
		,[dblConvertedUnits]				= CASE WHEN QM.strCalcMethod = 3 THEN @dblGrossUnits ELSE @dblConvertedUnits END
	FROM  tblGRTransferStorageReference SR
	JOIN tblGRCustomerStorage CS
		ON SR.intSourceCustomerStorageId = CS.intCustomerStorageId
	JOIN tblICItem IC
		ON IC.intItemId = CS.intItemId
	JOIN tblICItemUOM IU
	ON IU.intItemId = CS.intItemId
		AND IU.ysnStockUnit = 1
	JOIN tblQMTicketDiscount QM 
	ON QM.intTicketFileId = CS.intCustomerStorageId 
		AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	JOIN tblGRDiscountCalculationOption DCO
	ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
	JOIN tblICItem DItem 
	ON DItem.intItemId = DSC.intItemId
	WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 
		and SR.intTransferStorageId = @intTransferStorageId
		AND SR.intTransferStorageReferenceId = @intTransferStorageReferenceId


	UNION

	--Storage Charge
	SELECT
		 [intItemId]						= @intStorageChargeItemId
		,[strItemNo]						= @StorageChargeItemDescription	
		,[intEntityVendorId]				= NULL	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= @intStorageChargeItemId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= IC.ysnInventoryCost
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CS.dblStorageDue / @dblUnits
		,[intOtherChargeEntityVendorId]		= NULL
		,[dblAmount]						= CS.dblStorageDue
		,[ysnAccrue]						= 0
		,[ysnPrice]							= 1
		,[intTicketDiscountId]				= NULL
		,[dblUnits]							= @dblUnits
		,[dblConvertedUnits]				= @dblUnits
	FROM tblGRCustomerStorage CS
	JOIN tblICItem IC 
		ON 1 = 1
	WHERE CS.intCustomerStorageId = @intCustomerStorageId 
		AND ISNULL(CS.dblStorageDue,0) > 0 
		AND IC.intItemId = @intStorageChargeItemId


	
	DECLARE @InventoryCostCharges AS TABLE
	(
		 dtmDate							DATETIME
		,intItemId							INT
		,strItemNo		 				    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,intChargeId						INT
		,intItemLocationId					INT
		,intChargeItemLocation				INT
		,intTransactionId					INT
		,strTransactionId					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,dblCost							DECIMAL(24,10)
		,intTransactionTypeId				INT
		,intCurrencyId						INT
		,dblExchangeRate					DECIMAL(24,10)
		,intInventoryReceiptItemId			INT
		,strInventoryTransactionTypeName	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strTransactionForm					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,ysnAccrue							BIT
		,ysnPrice							BIT
		,ysnInventoryCost					BIT
		,dblForexRate						DECIMAL(24,10)
		,strRateType						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strCharge							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strItem							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strBundleType						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,dblUnits 							DECIMAL(24,10)
		,dblConvertedUnits 					DECIMAL(24,10)
		,strICCCostType						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	)
	DECLARE @tblItem AS TABLE 
	(
		 intItemId			INT
		,intItemLocationId  INT		
		,intItemType		INT
	)

	INSERT INTO @InventoryCostCharges
	(
		 dtmDate						
		,intItemId
		,strItemNo
		,intChargeId					
		,intItemLocationId				
		,intChargeItemLocation			
		,intTransactionId				
		,strTransactionId				
		,dblCost						
		,intTransactionTypeId			
		,intCurrencyId					
		,dblExchangeRate				
		,intInventoryReceiptItemId		
		,strInventoryTransactionTypeName
		,strTransactionForm				
		,ysnAccrue						
		,ysnPrice						
		,ysnInventoryCost				
		,dblForexRate					
		,strRateType					
		,strCharge						
		,strItem						
		,strBundleType
		,dblUnits
		,dblConvertedUnits		
		,strICCCostType					
	)
	SELECT 
		 dtmDate						 = GETDATE()
		,intItemId						 = @InventoryItemId
		,strItemNo						 = CS.strItemNo
		,intChargeId					 = CS.intChargeId
		,intItemLocationId				 = @intItemLocationId
		,intChargeItemLocation			 = ChargeItemLocation.intItemLocationId
		,intTransactionId				 = @intTransferStorageId
		,strTransactionId				 = @strTransactionId
		,dblCost						 = CS.dblRate
		,intTransactionTypeId			 = 56
		,intCurrencyId					 = CS.intCurrencyId
		,dblExchangeRate				 = 1
		,intInventoryReceiptItemId		 = @intTransferStorageId
		,strInventoryTransactionTypeName = 'Transfer Storage'
		,strTransactionForm				 = 'Transfer Storage'
		,ysnAccrue						 = CS.ysnAccrue
		,ysnPrice						 = CS.ysnPrice
		,ysnInventoryCost				 = CS.ysnInventoryCost
		,dblForexRate					 = 1
		,strRateType					 = NULL
		,strCharge						 = Item.strItemNo
		,strItem						 = Item.strItemNo
		,strBundleType					 = ISNULL(Item.strBundleType, '')
		,dblUnits						 = CS.dblUnits
		,dblConvertedUnits				 = CS.dblConvertedUnits
		,strCostType					= Item.strCostType
	FROM @tblOtherCharges CS
	JOIN tblICItem Item 
		ON Item.intItemId = CS.intChargeId
	LEFT JOIN dbo.tblICItemLocation ChargeItemLocation 
		ON ChargeItemLocation.intItemId = CS.intChargeId 
			AND ChargeItemLocation.intLocationId = @LocationId

	INSERT INTO @tblItem
	(
		intItemId
		,intItemLocationId
		,intItemType
	)
	--Inventory Item
	SELECT 
		intItemId		   = CS.intItemId
		,intItemLocationId = ItemLocation.intItemLocationId	
		,intItemType	   =  1
	FROM  tblGRTransferStorageReference SR
	JOIN tblGRCustomerStorage CS
		ON SR.intSourceCustomerStorageId = CS.intCustomerStorageId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = CS.intItemId 
			AND ItemLocation.intLocationId = CS.intCompanyLocationId 
	WHERE SR.intTransferStorageId = @intTransferStorageId		
		 AND SR.intTransferStorageReferenceId = @intTransferStorageReferenceId
	UNION
	--Discounts
	SELECT DISTINCT 
		 intItemId					= DItem.intItemId
		,intItemLocationId			= ItemLocation.intItemLocationId
		,intItemType				=  2
	FROM  tblGRTransferStorageReference SR
	JOIN tblGRCustomerStorage CS
		ON SR.intSourceCustomerStorageId = CS.intCustomerStorageId
	JOIN tblICItem IC
		ON IC.intItemId = CS.intItemId
	JOIN tblICItemUOM IU
	ON IU.intItemId = CS.intItemId
		AND IU.ysnStockUnit = 1
	JOIN tblQMTicketDiscount QM 
	ON QM.intTicketFileId = CS.intCustomerStorageId 
		AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	JOIN tblGRDiscountCalculationOption DCO
	ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
	JOIN tblICItem DItem 
	ON DItem.intItemId = DSC.intItemId
		LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = DItem.intItemId
			AND ItemLocation.intLocationId = @LocationId
	WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 and SR.intTransferStorageId = @intTransferStorageId		
		 AND SR.intTransferStorageReferenceId = @intTransferStorageReferenceId
	UNION
	--Storage Charge
	SELECT  
		 intItemId					= @intStorageChargeItemId
		,intItemLocationId			= ItemLocation.intItemLocationId
		,intItemType				=  2	
	FROM tblGRCustomerStorage CS
	JOIN tblICItem IC ON 1 = 1
	LEFT JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemId = IC.intItemId
			AND ItemLocation.intLocationId = @LocationId 
	WHERE CS.intCustomerStorageId = @intCustomerStorageId 
	AND   ISNULL(CS.dblStorageDue,0) > 0 
	AND   IC.intItemId = @intStorageChargeItemId

	DECLARE @ItemGLAccounts			AS dbo.ItemGLAccount;	
	--Inventory Item
	INSERT INTO @ItemGLAccounts 
	(
		 intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId
		,intTransactionTypeId
	)
	SELECT 
		 Query.intItemId
		,Query.intItemLocationId
		,intInventoryId		  = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_Inventory)
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing)
		,intTransactionTypeId = 56
	FROM @tblItem Query 
	WHERE Query.intItemType = 1	
		AND EXISTS(SELECT 1 FROM @tblOtherCharges WHERE ysnInventoryCost = 1)





	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount;
	--Charges
	INSERT INTO @OtherChargesGLAccounts 
	(
		intChargeId
		,intItemLocationId
		,intOtherChargeExpense
		,intOtherChargeIncome
		,intAPClearing
		,intTransactionTypeId
	)
	SELECT 
		 Query.intItemId
		,Query.intItemLocationId
		,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense)
		,intOtherChargeIncome  = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeIncome)
		,intAPClearing		   = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing)
		,intTransactionTypeId  = 56
	FROM @tblItem Query 
	WHERE intItemType IN (2,3) 	
		AND intItemLocationId IS NOT NULL

	DECLARE @ChargesGLEntries		AS RecapTableType;
	INSERT INTO @ChargesGLEntries
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
		,[strRateType]
	  )
	
	SELECT 
		  [dtmDate]                
		 ,[strBatchId]             
		 ,[intAccountId]           
		 ,[dblDebit] = CASE 
							WHEN (t.dblDebit) <> 0 THEN ROUND(ABS(t.dblCost * t.dblConvertedUnits),2)
							ELSE 0 
						END             
		 ,[dblCredit] = CASE 
							WHEN (t.dblCredit) <> 0 THEN ROUND(ABS(t.dblCost * t.dblConvertedUnits),2)
							ELSE 0 
						END             
		 ,[dblDebitUnit]           
		 ,[dblCreditUnit]          
		 ,[strDescription]         
		 ,[strCode]                
		 ,[strReference] = ''           
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
		 ,[strRateType]
	FROM  
	(
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case 
												when InventoryCostCharges.dblCost < 0 then
													InventoryCostCharges.dblCost  
												else 0 end
											else     0 end
			,dblCredit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											
											case when InventoryCostCharges.dblCost < 0 
												then 0 
												else InventoryCostCharges.dblCost end
												 
											
											else     InventoryCostCharges.dblCost end
			,dblDebitUnit				= 0
			,dblCreditUnit				= InventoryCostCharges.dblUnits
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'A'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription	= ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL
			,intEntityId				= @intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END
			,dblDebitReport				= NULL
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END
			,dblCreditReport			= NULL
			,dblReportingRate			= NULL
			,dblForeignRate				= InventoryCostCharges.dblForexRate
			,strRateType				= InventoryCostCharges.strRateType
			,dblUnits					= InventoryCostCharges.dblUnits
			,dblCost				    = InventoryCostCharges.dblCost
			,InventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts 
			ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType != 'Kit'
		
		UNION ALL
		
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case when InventoryCostCharges.dblCost < 0 
												then 0 else
												InventoryCostCharges.dblCost end
											else     InventoryCostCharges.dblCost end 
			,dblCredit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case when InventoryCostCharges.dblCost < 0 then
												InventoryCostCharges.dblCost 
												else 0 end
											else     0 end 
			,dblDebitUnit				= InventoryCostCharges.dblUnits
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'B'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL
			,intEntityId				= @intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END
			,dblDebitReport				= NULL
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END
			,dblCreditReport			= NULL
			,dblReportingRate			= NULL
			,dblForeignRate				= InventoryCostCharges.dblForexRate
			,strRateType				= InventoryCostCharges.strRateType
			,dblUnits					= InventoryCostCharges.dblUnits
			,dblCost				    = InventoryCostCharges.dblCost
			,InventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType != 'Kit'

		-------------------------------------------------------------------------------------------
		-- Cost billed by: None
		-- Add cost to inventory: Yes
		-- 
		-- Dr...... AP Clearing
		-- Cr..................... Item Inventory 
		-------------------------------------------------------------------------------------------
		UNION ALL
		
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case when InventoryCostCharges.dblCost < 0 
												then 0 else
												InventoryCostCharges.dblCost end
											else     InventoryCostCharges.dblCost end 
			,dblCredit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case when InventoryCostCharges.dblCost < 0 then
												InventoryCostCharges.dblCost 
												else 0 end
											else     0 end 
			,dblDebitUnit				= InventoryCostCharges.dblUnits
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'B'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL
			,intEntityId				= @intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END
			,dblDebitReport				= NULL
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END
			,dblCreditReport			= NULL
			,dblReportingRate			= NULL
			,dblForeignRate				= InventoryCostCharges.dblForexRate
			,strRateType				= InventoryCostCharges.strRateType
			,dblUnits					= InventoryCostCharges.dblUnits
			,dblCost				    = InventoryCostCharges.dblCost
			,InventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0
		AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
		AND InventoryCostCharges.strBundleType != 'Kit'

		UNION ALL

		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											case 
												when InventoryCostCharges.dblCost < 0 then
													InventoryCostCharges.dblCost  
												else 0 end
											else     0 end
			,dblCredit					= case when InventoryCostCharges.strICCCostType = 'Discount' then 
											
											case when InventoryCostCharges.dblCost < 0 
												then 0 
												else InventoryCostCharges.dblCost end
												 
											
											else     InventoryCostCharges.dblCost end
			,dblDebitUnit				= 0
			,dblCreditUnit				= InventoryCostCharges.dblUnits
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode					= @strCode
			,strReference				= 'A'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription	= ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL
			,intEntityId				= @intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END
			,dblDebitReport				= NULL
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END
			,dblCreditReport			= NULL
			,dblReportingRate			= NULL
			,dblForeignRate				= InventoryCostCharges.dblForexRate
			,strRateType				= InventoryCostCharges.strRateType
			,dblUnits					= InventoryCostCharges.dblUnits
			,dblCost				    = InventoryCostCharges.dblCost
			,InventoryCostCharges.dblConvertedUnits
			FROM @InventoryCostCharges InventoryCostCharges
			INNER JOIN @ItemGLAccounts ItemGLAccounts 
				ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
					AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount 
				ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
			CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
			WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0
				AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
				AND InventoryCostCharges.strBundleType != 'Kit'
		-------------------------------------------------------------------------------------------
		-- Cost billed by: None
		-- Add cost to inventory: No
		-- 
		-- Dr...... Other Charge Expense
		-- Cr..................... Other Charge Income 
		-------------------------------------------------------------------------------------------
		UNION ALL
		SELECT	
				 intItemId					= NonInventoryCostCharges.intChargeId
				,[strItemNo]				= NonInventoryCostCharges.strItemNo
				,dtmDate					= NonInventoryCostCharges.dtmDate
				,strBatchId					= @strBatchId
				,intAccountId				= GLAccount.intAccountId
				,dblDebit					= NonInventoryCostCharges.dblCost
				,dblCredit					= 0
				,dblDebitUnit				= NonInventoryCostCharges.dblUnits
				,dblCreditUnit				= 0
				,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
				,strCode					= @strCode
				,strReference				= 'G' 
				,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
				,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
				,dtmDateEntered				= GETDATE()
				,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
				,strJournalLineDescription  = '' 
				,intJournalLineNo			= NULL
				,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
				,intUserId					= NULL 
				,intEntityId				= @intEntityVendorId 
				,strTransactionId			= NonInventoryCostCharges.strTransactionId
				,intTransactionId			= NonInventoryCostCharges.intTransactionId
				,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
				,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
				,strModuleName				= @ModuleName
				,intConcurrencyId			= 1
				,dblDebitForeign			= CASE 
												WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
												ELSE 0 
											END 
				,dblDebitReport				= NULL 
				,dblCreditForeign			= CASE 
												WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
												ELSE 0 
											END  
				,dblCreditReport			= NULL 
				,dblReportingRate			= NULL 
				,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
				,strRateType				= NonInventoryCostCharges.strRateType
				,dblUnits					= NonInventoryCostCharges.dblUnits
				,dblCost				    = NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= 0
			,dblCredit					= NonInventoryCostCharges.dblCost
			,dblDebitUnit				= 0
			,dblCreditUnit				= NonInventoryCostCharges.dblUnits
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'H' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL 
			,intEntityId				= @intEntityVendorId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
			,dblUnits					= NonInventoryCostCharges.dblUnits
			,dblCost				    = NonInventoryCostCharges.dblCost
			,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

		-------------------------------------------------------------------------------------------
		-- Accrue Other Charge to Vendor 
		-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
		-- 
		-- Dr...... Other Charge Expense 
		-- Cr.................... AP Clearing	
		-------------------------------------------------------------------------------------------
		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= NonInventoryCostCharges.dblCost
			,dblCredit					= 0
			,dblDebitUnit				= NonInventoryCostCharges.dblUnits
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'I' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL 
			,intEntityId				= @intEntityVendorId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
			,dblUnits					= NonInventoryCostCharges.dblUnits
			,dblCost				    = NonInventoryCostCharges.dblCost
			,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0

		UNION ALL
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= 0
			,dblCredit					= NonInventoryCostCharges.dblCost
			,dblDebitUnit				= 0
			,dblCreditUnit				= NonInventoryCostCharges.dblUnits
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'J' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL 
			,intEntityId				= @intEntityVendorId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
			,dblUnits					= NonInventoryCostCharges.dblUnits
			,dblCost				    = NonInventoryCostCharges.dblCost
			,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0

		-------------------------------------------------------------------------------------------
		-- Price Down 
		-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
		-- 
		-- Dr...... AP Clearing
		-- Cr.................... Freight Expense 
		-------------------------------------------------------------------------------------------
		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= NonInventoryCostCharges.dblCost
			,dblCredit					= 0
			,dblDebitUnit				= NonInventoryCostCharges.dblUnits
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'K' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL 
			,intEntityId				= @intEntityVendorId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
			,dblUnits					= NonInventoryCostCharges.dblUnits
			,dblCost				    = NonInventoryCostCharges.dblCost
			,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0

		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= 0
			,dblCredit					= NonInventoryCostCharges.dblCost
			,dblDebitUnit				= 0
			,dblCreditUnit				= NonInventoryCostCharges.dblUnits
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'L' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
			,intUserId					= NULL 
			,intEntityId				= @intEntityVendorId
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
			,dblUnits					= NonInventoryCostCharges.dblUnits
			,dblCost				    = NonInventoryCostCharges.dblCost
			,NonInventoryCostCharges.dblConvertedUnits
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
	)t
	SELECT 
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
		,[strRateType]
	FROM @ChargesGLEntries
END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH