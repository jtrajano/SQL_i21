﻿CREATE PROCEDURE [dbo].[uspGRCreateGLEntries]
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
	,@intFunctionalCurrencyId		INT
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
	,@dblGrossUnits					DECIMAL(24,10)
	,@intContractCostId				INT
	,@ysnIsStorage					BIT
	,@IntCommodityId				INT
	,@intStorageChargeItemId		INT
	,@StorageChargeItemDescription  NVARCHAR(100)

	DECLARE 
	@ACCOUNT_CATEGORY_APClearing		   NVARCHAR(30) = 'AP Clearing'
	,@ACCOUNT_CATEGORY_OtherChargeExpense  NVARCHAR(30) = 'Other Charge Expense'
	,@ACCOUNT_CATEGORY_OtherChargeIncome   NVARCHAR(30) = 'Other Charge Income'
	,@ModuleName						   NVARCHAR(50) = 'Grain'
	,@strCode							   NVARCHAR(10) = 'STR'
	,@strTransactionId                     NVARCHAR(30)

	SELECT @strTransactionId = strStorageTicket 
	      ,@IntCommodityId   = intCommodityId	 
	FROM tblGRSettleStorage 
	WHERE intSettleStorageId = @intSettleStorageId

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

	SELECT @StorageChargeItemDescription = strDescription
	FROM tblICItem
	WHERE intItemId = @intStorageChargeItemId
		
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
		 @LocationId			= CS.intCompanyLocationId
		--,@intCustomerStorageId  = CS.intCustomerStorageId
		,@intScaleTicketId		= CS.intTicketId
		,@intEntityVendorId		= CS.intEntityId 
		,@intCurrencyId			= CS.intCurrencyId
		,@InventoryItemId		= CS.intItemId  
		,@dblUnits				= SST.dblUnits
		,@dblGrossUnits			= CS.dblGrossQuantity * (SST.dblUnits / CS.dblOriginalBalance)
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
		,[ysnAccrue]					   BIT
		,[ysnPrice]						   BIT
		,[intTicketDiscountId]			   INT
		,[dblUnits] 					   DECIMAL(24,10)
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
	)
	--Discounts
	SELECT
		 [intItemId]						= IC.intItemId
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
												WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1)
												WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END))
												WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount * -1)
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
		,[ysnAccrue]						= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		,[intTicketDiscountId]				= QM.intTicketDiscountId
		,[dblUnits]							= CASE WHEN QM.strCalcMethod = 3 THEN @dblGrossUnits ELSE @dblUnits END
	FROM tblGRSettleStorageTicket SST
	JOIN tblGRSettleStorage SS 
		ON SS.intSettleStorageId = SST.intSettleStorageId
	LEFT JOIN tblGRSettleContract SC
		ON SC.intSettleStorageId = SS.intSettleStorageId
	LEFT JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractDetailId
	JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = SST.intCustomerStorageId 
			AND QM.strSourceType = 'Storage'
	JOIN tblGRDiscountScheduleCode GR 
		ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
	JOIN tblICItem IC 
		ON IC.intItemId = GR.intItemId
	WHERE SST.intSettleStorageId = @intSettleStorageId 
		  AND ISNULL(QM.dblDiscountDue,0) <> ISNULL(QM.dblDiscountPaid,0)

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
		,[dblRate]							= SS.dblStorageDue / @dblUnits
		,[intOtherChargeEntityVendorId]		= NULL
		,[dblAmount]						= SS.dblStorageDue
		,[ysnAccrue]						= 0
		,[ysnPrice]							= 1
		,[intTicketDiscountId]				= NULL
		,[dblUnits]							= @dblUnits
	FROM tblGRSettleStorage SS
	JOIN tblICItem IC 
		ON 1 = 1
	WHERE SS.intSettleStorageId = @intSettleStorageId 
		AND ISNULL(SS.dblStorageDue,0) > 0 
		AND IC.intItemId = @intStorageChargeItemId 	
	
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
	)
	SELECT 
		 dtmDate						 = GETDATE()
		,intItemId						 = @InventoryItemId
		,strItemNo						 = CS.strItemNo
		,intChargeId					 = CS.intChargeId
		,intItemLocationId				 = @intItemLocationId
		,intChargeItemLocation			 = ChargeItemLocation.intItemLocationId
		,intTransactionId				 = @intSettleStorageId
		,strTransactionId				 = @strTransactionId
		,dblCost						 = CS.dblRate
		,intTransactionTypeId			 = 44
		,intCurrencyId					 = CS.intCurrencyId
		,dblExchangeRate				 = 1
		,intInventoryReceiptItemId		 = @intSettleStorageId
		,strInventoryTransactionTypeName = 'Storage Settlement'
		,strTransactionForm				 = 'Storage Settlement'
		,ysnAccrue						 = CS.ysnAccrue
		,ysnPrice						 = CS.ysnPrice
		,ysnInventoryCost				 = CS.ysnInventoryCost
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
	--Storage Charge
	SELECT  
		 intItemId					= @intStorageChargeItemId
		,intItemLocationId			= ItemLocation.intItemLocationId
		,intItemType				=  2	
	FROM tblGRSettleStorage SS
	JOIN tblICItem IC ON 1 = 1
	LEFT JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemId = IC.intItemId
			AND ItemLocation.intLocationId = @LocationId 
	WHERE SS.intSettleStorageId = @intSettleStorageId 
	AND   ISNULL(SS.dblStorageDue,0) > 0 
	AND   IC.intItemId = @intStorageChargeItemId
	
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
		AND intItemLocationId IS NOT NULL

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
		-------------------------------------------------------------------------------------------
		-- Cost billed by: None
		-- Add cost to inventory: No
		-- 
		-- Dr...... Other Charge Expense
		-- Cr..................... Other Charge Income 
		-------------------------------------------------------------------------------------------
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
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
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
		CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
		CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
		WHERE ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
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