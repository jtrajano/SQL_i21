CREATE PROCEDURE [dbo].[uspGRCreateGLEntries]
	 @strTransactionType AS NVARCHAR(100) --'Storage Settlement'
	,@strType AS NVARCHAR(40)			  --'1.Inventory 2.OtherCharges '
	,@intSettleStorageId INT
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT	
	,@ysnPost AS BIT 
AS
BEGIN TRY
BEGIN
	DECLARE
	 @ErrMsg					    NVARCHAR(MAX) 
	,@intInventoryReceiptId			INT	
	,@intFunctionalCurrencyId		INT
	,@intCustomerStorageId			INT
	,@intScaleTicketId				INT
	,@LocationId					INT
	,@InventoryItemId				INT
	,@intItemLocationId				INT
	,@intEntityVendorId				INT
	,@intCurrencyId					INT
	,@intTransactionTypeId			INT
	,@intHaulerId					INT
	,@intFreightItemId				INT
	,@ysnAccrue					    BIT
	,@ysnPrice					    BIT
	,@ysnDeductFreightFarmer		BIT
	,@ysnDeductFeesCusVen		    BIT
	,@dblFreightRate				DECIMAL(24,10)
	,@dblUnits						DECIMAL(24,10)
	,@intContractCostId				INT
	,@ysnIsStorage					BIT

	DECLARE 
	 @ACCOUNT_CATEGORY_Inventory		   NVARCHAR(30) = 'Inventory'
	,@ACCOUNT_CATEGORY_APClearing		   NVARCHAR(30) = 'AP Clearing'
	,@ACCOUNT_CATEGORY_OtherChargeExpense  NVARCHAR(30) = 'Other Charge Expense'
	,@ACCOUNT_CATEGORY_OtherChargeIncome   NVARCHAR(30) = 'Other Charge Income'
	,@ModuleName						   NVARCHAR(50) = 'Grain'
	,@strTransactionForm				   NVARCHAR(50) = 'Settle Storage'
	,@strCode							   NVARCHAR(10) = 'STR'
	,@strTransactionId                     NVARCHAR(30)

	SELECT @strTransactionId = strStorageTicket 
	FROM tblGRSettleStorage 
	WHERE intSettleStorageId = @intSettleStorageId
	
	DECLARE @ItemGLAccounts			AS dbo.ItemGLAccount;
	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount;
	DECLARE @ChargesGLEntries		AS RecapTableType;

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	SET @ysnIsStorage = 1	

	SELECT @intTransactionTypeId = intTransactionTypeId 
	FROM tblICInventoryTransactionType 
	WHERE strName = @strTransactionType
	
	--Inventory Item
	SELECT 
		 @LocationId			 = CS.intCompanyLocationId
		,@intCustomerStorageId   = CS.intCustomerStorageId
		,@intScaleTicketId		 = CS.intTicketId
		,@intEntityVendorId		 = CS.intEntityId 
		,@intCurrencyId			 = CS.intCurrencyId
		,@InventoryItemId		 = CS.intItemId  
		,@dblUnits				 = SST.dblUnits
	FROM tblGRCustomerStorage CS 
	JOIN tblGRSettleStorageTicket SST 
		ON  SST.intCustomerStorageId = CS.intCustomerStorageId
	WHERE SST.intSettleStorageId = @intSettleStorageId
	
	--Freight
	SELECT 
		 @intFreightItemId			= SCSetup.intFreightItemId
		,@intHaulerId				= SCTicket.intHaulerId 
		,@dblFreightRate			= SCTicket.dblFreightRate
		,@ysnDeductFreightFarmer	= SCTicket.ysnFarmerPaysFreight 
		,@ysnDeductFeesCusVen		= SCTicket.ysnCusVenPaysFees
		,@intContractCostId			= SCTicket.intContractCostId

	FROM tblSCScaleSetup SCSetup 
	LEFT JOIN tblSCTicket SCTicket 
		ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
	WHERE SCTicket.intTicketId = @intScaleTicketId

	SELECT @intItemLocationId = intItemLocationId 
	FROM tblICItemLocation 
	WHERE intItemId = @InventoryItemId 
		AND intLocationId = @LocationId

	IF  @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
	END
	ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
		SET @ysnPrice = 1
	END
	ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnPrice = 1
	END

	IF @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnAccrue = 0
		SET @ysnPrice = 0
	END
	
	SET @intFreightItemId = ISNULL(@intFreightItemId,0)

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
		,[intContractDetailId] 			   INT
		,[ysnAccrue]					   BIT
		,[ysnPrice]						   BIT
		,[intTicketDiscountId]			   INT
		,[intContractCostId]			   INT
		,[dblUnits] 					   DECIMAL(24,10)
	)

	INSERT INTO @tblOtherCharges
	(
		 intItemId
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
		,[intContractDetailId] 			
		,[ysnAccrue]					
		,[ysnPrice]
		,[intTicketDiscountId]	
		,[intContractCostId]
		,[dblUnits] 	
	)
	SELECT
		 intItemId							= IC.intItemId
		,[strItemNo]						= IC.strItemNo	
		,[intEntityVendorId]				= @intEntityVendorId	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= IC.ysnInventoryCost
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE 
													WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)	
													WHEN QM.dblDiscountAmount > 0 THEN  QM.dblDiscountAmount		
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
		,[intContractDetailId]				= RE.intContractDetailId
		,[ysnAccrue]						= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		,[intTicketDiscountId]				= QM.intTicketDiscountId
		,[intContractCostId]				= NULL
		,[dblUnits]							= @dblUnits
	FROM tblGRSettleContract RE
	JOIN tblGRSettleStorageTicket SST 
		ON SST.intSettleStorageId = RE.intSettleStorageId
	JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = SST.intCustomerStorageId AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode GR 
		ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	JOIN tblICItem IC 
		ON IC.intItemId = GR.intItemId
	WHERE RE.intSettleStorageId = @intSettleStorageId 
			AND ISNULL(QM.dblDiscountAmount,0) <> ISNULL(QM.dblDiscountPaid,0)
	
	UNION

	SELECT
		 intItemId							= IC.intItemId
		,[strItemNo]						= IC.strItemNo	
		,[intEntityVendorId]				= @intEntityVendorId	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= IC.ysnInventoryCost
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE 
													WHEN QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)	
													WHEN QM.dblDiscountAmount > 0 THEN  QM.dblDiscountAmount		
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
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		,[intTicketDiscountId]				= QM.intTicketDiscountId
		,[intContractCostId]				= NULL
		,[dblUnits]							= @dblUnits
	FROM tblGRSettleStorageTicket SST
	JOIN tblGRSettleStorage SS 
		ON SS.intSettleStorageId = SST.intSettleStorageId
	JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = SST.intCustomerStorageId 
			AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode GR 
		ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	JOIN tblICItem IC 
		ON IC.intItemId = GR.intItemId
	WHERE SST.intSettleStorageId = @intSettleStorageId 
		  AND ISNULL(QM.dblDiscountAmount,0) <> ISNULL(QM.dblDiscountPaid,0)
		  AND SS.dblSpotUnits > 0

	UNION

	--freight
    SELECT 
		  intItemId							= Item.intItemId
		,[strItemNo]						= Item.strItemNo		
		,[intEntityVendorId]				= @intEntityVendorId	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= RC.intChargeId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= RC.ysnInventoryCost
		,[strCostMethod]					= RC.strCostMethod
		,[dblRate]							= RC.dblRate
		,[intOtherChargeEntityVendorId]		= RC.intEntityVendorId
		,[dblAmount]						= RC.dblAmount
		,[intContractDetailId]				= NULL
		,[ysnAccrue]						= CASE WHEN RIAC.ysnAccrue = 1 THEN 0 END
		,[ysnPrice]							= RIAC.ysnPrice
		,[intTicketDiscountId]				= NULL
		,[intContractCostId]				= NULL
		,[dblUnits]							= RC.dblQuantity
	FROM tblICInventoryReceiptCharge RC
    JOIN tblICItem Item 
		ON Item.intItemId = RC.intChargeId
    JOIN tblGRStorageHistory SH 
		ON SH.intInventoryReceiptId = RC.intInventoryReceiptId 
			AND SH.strType='FROM Scale'
	JOIN tblICInventoryReceiptItemAllocatedCharge  RIAC
		ON RIAC.intInventoryReceiptChargeId = RC.intChargeId
    JOIN tblGRSettleStorageTicket SST 
		ON SST.intCustomerStorageId = SH.intCustomerStorageId 
			AND SST.dblUnits > 0
    JOIN tblGRSettleStorage SS 
		ON SS.intSettleStorageId = SST.intSettleStorageId 
    JOIN tblSCTicket SC 
		ON SC.intTicketId = SH.intTicketId
    JOIN tblSCScaleSetup ScaleSetup 
		ON ScaleSetup.intScaleSetupId = SC.intScaleSetupId 
			AND ScaleSetup.intFreightItemId = RC.[intChargeId]
	WHERE SST.intSettleStorageId = @intSettleStorageId	

    UNION

	SELECT
		 intItemId							= IC.intItemId
		,[strItemNo]						= IC.strItemNo		
		,[intEntityVendorId]				= @intEntityVendorId	
		,[intCurrencyId]  					= @intCurrencyId
		,[intCostCurrencyId]  				= @intCurrencyId
		,[intChargeId]						= ContractCost.intItemId
		,[intForexRateTypeId]				= NULL
		,[dblForexRate]						= NULL
		,[ysnInventoryCost]					= CASE 
												WHEN ISNULL(ContractCost.ysnPrice,0) = 1 THEN 0 
												ELSE IC.ysnInventoryCost 
											END
		,[strCostMethod]					= ContractCost.strCostMethod
		,[dblRate]							= ISNULL(ContractCost.dblRate,@dblFreightRate)
		,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
		,[dblAmount]						= ROUND (((RE.dblUnits / SSV.dblOriginalBalance) * ISNULL(ContractCost.dblRate,@dblFreightRate)), 2)
		,[intContractDetailId]				= RE.intContractDetailId
		,[ysnAccrue]						= CASE 
												WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 
												ELSE 0 
											END
		,[ysnPrice]							= CASE 
												WHEN @ysnIsStorage = 0 THEN ContractCost.ysnPrice 
												ELSE 0 
											END
		,[intTicketDiscountId]				= NULL
		,[intContractCostId]				= ContractCost.intContractCostId
		,[dblUnits]							= RE.dblUnits
	FROM tblCTContractCost ContractCost
	JOIN tblGRSettleContract RE 
		ON RE.intContractDetailId = ContractCost.intContractDetailId
	JOIN tblGRSettleStorageTicket SST 
		ON SST.intSettleStorageId = RE.intSettleStorageId
	JOIN vyuGRStorageSearchView SSV 
		ON SSV.intCustomerStorageId = SST.intCustomerStorageId
	JOIN tblICItem IC 
		ON IC.intItemId = ContractCost.intItemId
	WHERE  ContractCost.intItemId != @intFreightItemId 
		AND RE.intContractDetailId IS NOT NULL  
		AND ContractCost.dblRate != 0 
		AND SST.intSettleStorageId = @intSettleStorageId
			
	
	DECLARE @tblItem AS TABLE 
	(
		 intItemId			INT
		,intItemLocationId  INT		
		,intItemType		INT
	)

	DECLARE @InventoryCostCharges AS TABLE
	(
		 dtmDate							DATETIME
		,intItemId							INT
		,[strItemNo]	 				    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
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
		,dblUnits 						DECIMAL(24,10)
	)

	INSERT INTO @InventoryCostCharges
	(
		 dtmDate						
		,intItemId
		,[strItemNo]						
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
	)
	SELECT 
		 dtmDate						 = GETDATE()
		,intItemId						 = @InventoryItemId
		,[strItemNo]					 = CS.[strItemNo]
		,intChargeId					 = CS.intChargeId
		,intItemLocationId				 = @intItemLocationId
		,intChargeItemLocation			 = ChargeItemLocation.intItemLocationId
		,intTransactionId				 = @intSettleStorageId
		,strTransactionId				 = @strTransactionId
		,dblCost						 =  CS.dblRate
		,intTransactionTypeId			 =  44
		,intCurrencyId					 =  CS.intCurrencyId
		,dblExchangeRate				 =  1
		,intInventoryReceiptItemId		 =  @intSettleStorageId
		,strInventoryTransactionTypeName = 'Storage Settlement'
		,strTransactionForm				 = 'Storage Settlement'
		,[ysnAccrue]					 =  CS.ysnAccrue
		,[ysnPrice]						 =  CS.ysnPrice
		,ysnInventoryCost				 =  CS.ysnInventoryCost
		,dblForexRate					 = 1
		,strRateType					 = NULL
		,strCharge						 = Item.strItemNo
		,strItem						 = Item.strItemNo
		,strBundleType					 = ISNULL(Item.strBundleType, '')
		,dblUnits						 = CS.dblUnits
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
	FROM tblGRCustomerStorage CS 
	JOIN tblGRSettleStorageTicket SST 
		ON  SST.intCustomerStorageId = CS.intCustomerStorageId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = CS.intItemId 
			AND ItemLocation.intLocationId = CS.intCompanyLocationId 
	WHERE SST.intSettleStorageId = @intSettleStorageId

	UNION
	--Discounts
	SELECT DISTINCT 
		 intItemId					= Dcode.intItemId
		,intItemLocationId			= ItemLocation.intItemLocationId
		,intItemType				=  2
	FROM tblGRCustomerStorage CS
	JOIN tblGRSettleStorageTicket SST 
		ON SST.intCustomerStorageId = CS.intCustomerStorageId 
			AND SST.intSettleStorageId = @intSettleStorageId 
			AND SST.dblUnits > 0
	JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = CS.intCustomerStorageId 
			AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode Dcode 
		ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	JOIN tblICCommodityUnitMeasure CU 
		ON CU.intCommodityId = CS.intCommodityId 
			AND CU.ysnStockUnit = 1
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Dcode.intItemId 
			AND ItemLocation.intLocationId = @LocationId
	WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0

	UNION
	--Freight
	SELECT 
		 intItemId					= SCSetup.intFreightItemId
		,intItemLocationId			= ItemLocation.intItemLocationId
		,intItemType                =  2
    FROM tblSCScaleSetup SCSetup 
    LEFT JOIN tblSCTicket SCTicket 
		ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
    LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = SCSetup.intFreightItemId 
			AND ItemLocation.intLocationId = SCTicket.intProcessingLocationId
    WHERE SCTicket.intTicketId = @intScaleTicketId

    UNION
	--Contract
	SELECT DISTINCT 
		 intItemId			   = OtherCharges.intItemId
		,intItemLocationId	   = ItemLocation.intItemLocationId
		,intItemType		   =  3
	FROM  tblCTContractCost OtherCharges 
	JOIN  tblGRSettleContract SV 
		ON SV.intContractDetailId = OtherCharges.intContractDetailId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = OtherCharges.intItemId 
			AND ItemLocation.intLocationId = @LocationId
	WHERE SV.intSettleStorageId = @intSettleStorageId
	
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
		,intTransactionTypeId = @intTransactionTypeId
	FROM @tblItem Query 
	WHERE Query.intItemType = 1	
		AND EXISTS(SELECT 1 FROM @tblOtherCharges WHERE ysnInventoryCost = 1)	
	
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
		,intTransactionTypeId  = @intTransactionTypeId
	FROM @tblItem Query 
	WHERE intItemType IN (2,3) 

	-------------------------------------------------------------------------------------------
	-- Cost billed by: None
	-- Add cost to inventory: Yes
	-- 
	-- Dr...... Item's Inventory Account
	-- Cr..................... Freight Expense 
	-------------------------------------------------------------------------------------------
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
							WHEN ABS(t.dblDebit) > 0 THEN ABS(t.dblCost * t.dblUnits) 
							ELSE 0 
						END             
		 ,[dblCredit] = CASE 
							WHEN ABS(t.dblCredit) > 0 THEN ABS(t.dblCost * t.dblUnits) 
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
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode					= @strCode
			,strReference				= 'A'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription	= ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= @intEntityUserSecurityId
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
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @ItemGLAccounts ItemGLAccounts 
			ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebitFunctional(
												CASE 
													WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
													ELSE InventoryCostCharges.dblCost 
												END,
												InventoryCostCharges.intCurrencyId, 
												@intFunctionalCurrencyId, 
												InventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												CASE 
													WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
													ELSE InventoryCostCharges.dblCost 
												END
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(
									CASE 
										WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
										ELSE InventoryCostCharges.dblCost 
									END
								) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
										CASE 
											WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
											ELSE InventoryCostCharges.dblCost 
										END
									) CreditForeign
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
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
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
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= @intEntityUserSecurityId
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
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts 
			ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebitFunctional(
												CASE 
													WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
													ELSE InventoryCostCharges.dblCost 
												END
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											 ) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												CASE 
													WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
													ELSE InventoryCostCharges.dblCost 
												END
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											  ) Credit
		CROSS APPLY dbo.fnGetDebit(
									CASE 
										WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
										ELSE InventoryCostCharges.dblCost 
									END
								) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
										CASE 
											WHEN InventoryCostCharges.ysnPrice = 1 THEN - InventoryCostCharges.dblCost 
											ELSE InventoryCostCharges.dblCost 
										END
									) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType != 'Kit'
		-------------------------------------------------------------------------------------------
		-- Accrue Other Charge to Vendor and Add Cost to Inventory 
		-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
		-- 
		-- (X) Dr...... Item's Inventory Acccount 
		-- Cr.................... AP Clearing	
		-------------------------------------------------------------------------------------------
		
		UNION ALL
		
		SELECT 
			 intItemId				   = InventoryCostCharges.intChargeId
			,[strItemNo]			   = InventoryCostCharges.strItemNo
			,dtmDate				   = InventoryCostCharges.dtmDate
			,strBatchId				   = @strBatchId
			,intAccountId			   = GLAccount.intAccountId
			,dblDebit				   = Debit.Value
			,dblCredit				   = Credit.Value
			,dblDebitUnit			   = 0
			,dblCreditUnit			   = 0
			,strDescription			   = ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode				   = @strCode
			,strReference			   = 'C'
			,intCurrencyId			   = InventoryCostCharges.intCurrencyId
			,dblExchangeRate		   = InventoryCostCharges.dblForexRate
			,dtmDateEntered			   = GETDATE()
			,dtmTransactionDate		   = InventoryCostCharges.dtmDate
			,strJournalLineDescription = ''
			,intJournalLineNo		   = InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted			   = 0
			,intUserId				   = NULL
			,intEntityId			   = @intEntityUserSecurityId
			,strTransactionId		   = InventoryCostCharges.strTransactionId
			,intTransactionId		   = InventoryCostCharges.intTransactionId
			,strTransactionType		   = InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm		   = InventoryCostCharges.strTransactionForm
			,strModuleName			   = @ModuleName
			,intConcurrencyId		   = 1
			,dblDebitForeign		   = CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value 
											ELSE 0 
										END
			,dblDebitReport			   = NULL
			,dblCreditForeign		   = CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value 
											ELSE 0 
										END
			,dblCreditReport		   = NULL
			,dblReportingRate		   = NULL
			,dblForeignRate			   = InventoryCostCharges.dblForexRate
			,strRateType			   = InventoryCostCharges.strRateType
			,dblUnits					= InventoryCostCharges.dblUnits
			,dblCost				    = InventoryCostCharges.dblCost
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @ItemGLAccounts ItemGLAccounts 
			ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebitFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1 
			AND InventoryCostCharges.strBundleType != 'Kit'
		
		UNION ALL
		
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'D'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription	= ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= @intEntityUserSecurityId
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
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts 
			ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
		CROSS APPLY dbo.fnGetDebitFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId 
												,InventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType != 'Kit'
		-------------------------------------------------------------------------------------------
		-- If linked item is a 'Kit' and Inventory Cost = true
		-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
		-- 
		-- Dr...... Item's Other Charge Expense
		-- Cr.................... Item's AP Clearing	
		-------------------------------------------------------------------------------------------
		
		UNION ALL
		
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode					= @strCode
			,strReference				= 'E'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= @intEntityUserSecurityId
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
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @ItemGLAccounts ItemGLAccounts 
			ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebitFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType = 'Kit'
		
		UNION ALL
		
		SELECT 
			 intItemId					= InventoryCostCharges.intChargeId
			,[strItemNo]				= InventoryCostCharges.strItemNo
			,dtmDate					= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'F'
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = ''
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= NULL
			,intEntityId				= @intEntityUserSecurityId
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
		FROM @InventoryCostCharges InventoryCostCharges
		INNER JOIN @ItemGLAccounts ItemGLAccounts 
			ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount 
			ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebitFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												InventoryCostCharges.dblCost
												,InventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,InventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
			AND InventoryCostCharges.strBundleType = 'Kit'


		UNION ALL
		
		-------------------------------------------------------------------------------------------
		-- Cost billed by: None
		-- Add cost to inventory: No
		-- 
		-- Dr...... Freight Expense
		-- Cr..................... Freight Income 
		-------------------------------------------------------------------------------------------
		SELECT	
				 intItemId					= NonInventoryCostCharges.intChargeId
				,[strItemNo]				= NonInventoryCostCharges.strItemNo
				,dtmDate					= NonInventoryCostCharges.dtmDate
				,strBatchId					= @strBatchId
				,intAccountId				= GLAccount.intAccountId
				,dblDebit					= Debit.Value
				,dblCredit					= Credit.Value
				,dblDebitUnit				= 0
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
				,ysnIsUnposted				= 0
				,intUserId					= NULL 
				,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None 
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'H' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None 
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

		-------------------------------------------------------------------------------------------
		-- Accrue Other Charge to Vendor 
		-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
		-- 
		-- Dr...... Freight Expense 
		-- Cr.................... AP Clearing	
		-------------------------------------------------------------------------------------------
		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
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
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
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
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= 'J' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
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
			,dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
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
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1

		UNION ALL 
		
		SELECT	
			 intItemId					= NonInventoryCostCharges.intChargeId
			,[strItemNo]				= NonInventoryCostCharges.strItemNo
			,dtmDate					= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge 
			,strCode					= @strCode
			,strReference				= 'L' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NULL
			,ysnIsUnposted				= 0
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
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
		FROM @InventoryCostCharges NonInventoryCostCharges 
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
			ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount
			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebitFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
												NonInventoryCostCharges.dblCost
												,NonInventoryCostCharges.intCurrencyId
												,@intFunctionalCurrencyId
												,NonInventoryCostCharges.dblForexRate
											) Credit
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1	
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
