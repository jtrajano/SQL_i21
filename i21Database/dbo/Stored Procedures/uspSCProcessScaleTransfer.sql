CREATE PROCEDURE [dbo].[uspSCProcessScaleTransfer]
	 @intTicketId AS INT
	,@intMatchTicketId AS INT
	,@strInOutIndicator AS NVARCHAR(1)
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intCustomerStorageId AS INT
DECLARE @ysnAddDiscount BIT
DECLARE @intHoldCustomerStorageId AS INT
DECLARE @strGRStorage AS nvarchar(3)
DECLARE @intTicketUOM AS INT
DECLARE @intTicketItemUOMId AS INT
DECLARE @intMatchTicketUOM AS INT
DECLARE @intMatchTicketItemUOMId AS INT
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
DECLARE @GLEntries AS RecapTableType
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @STARTING_NUMBER_BATCH AS INT = 3
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY_AP AS NVARCHAR(255) = 'AP Clearing'
DECLARE @ACCOUNT_CATEGORY AS NVARCHAR(255) = 'AP Clearing'
DECLARE @dblOriginNetUnits AS DECIMAL (13,3)
DECLARE @dblDestinationNetUnits AS DECIMAL (13,3)
DECLARE @strOriginDestination AS NVARCHAR(1)
DECLARE @differenceUnits AS DECIMAL (13,3)

EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT
BEGIN
    SELECT @strOriginDestination = SMP.strValue
	FROM dbo.tblSMPreferences SMP 
	WHERE SMP.strPreference = 'TransferUpdateOption'
END
BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId
		FROM	dbo.tblICItemUOM UM	
		  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.intUnitMeasureId = @intTicketUOM AND SC.intTicketId = @intTicketId
END
BEGIN 
	SELECT	@intMatchTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intMatchTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intMatchTicketItemUOMId = UM.intItemUOMId
		FROM	dbo.tblICItemUOM UM	
		  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.intUnitMeasureId = @intMatchTicketUOM AND SC.intTicketId = @intMatchTicketId
END

-- Get the items to post  
DECLARE @ItemsForRemovalPost AS ItemCostingTableType
DECLARE @ItemsForTransferPost AS ItemCostingTableType

IF @strInOutIndicator = 'I'
BEGIN  
	BEGIN 
		SELECT	@dblOriginNetUnits = SC.dblNetUnits
		FROM	dbo.tblSCTicket SC	  
		WHERE SC.intTicketId = @intMatchTicketId
	END
		BEGIN 
		SELECT	@dblDestinationNetUnits = SC.dblNetUnits
		FROM	dbo.tblSCTicket SC	  
		WHERE SC.intTicketId = @intTicketId
	END
	SET @differenceUnits = 0
	IF @dblOriginNetUnits != @dblDestinationNetUnits
	BEGIN
		IF @dblOriginNetUnits > @dblDestinationNetUnits
		BEGIN
			SET @differenceUnits = @dblOriginNetUnits - @dblDestinationNetUnits
		END 
		IF @dblDestinationNetUnits > @dblOriginNetUnits
		BEGIN
			SET @differenceUnits = @dblDestinationNetUnits - @dblOriginNetUnits
		END
	END
	IF @strOriginDestination = '1'
		BEGIN
		IF @differenceUnits != 0
		BEGIN
			SET @differenceUnits = @dblOriginNetUnits - @dblDestinationNetUnits
			INSERT INTO @ItemsForRemovalPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		) 
		SELECT Ticket.intItemId  
				,dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
				,@intMatchTicketItemUOMId  
				,Ticket.dtmTicketDateTime
				,@differenceUnits
				,ItemUOM.dblUnitQty
				,0  
				,0
				,NULL
				,1
				,Ticket.intTicketId 
				,Ticket.intTicketNumber
				,@INVENTORY_TRANSFER_TYPE
				,NULL
				,Ticket.intSubLocationId
				,Ticket.intStorageLocationId
		FROM tblSCTicket Ticket
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intMatchTicketItemUOMId
		WHERE intTicketId = @intMatchTicketId

		-- Call the post routine 
		BEGIN 
		SET @ACCOUNT_CATEGORY = CASE WHEN @differenceUnits > 0 THEN @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY_AP ELSE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY END
			-- Call the post routine 
			INSERT INTO @GLEntries (
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
			)
			EXEC	dbo.uspICPostCosting  
					@ItemsForRemovalPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY
					,@intUserId
		END
		END

		-- Get the assembly item to post    
		INSERT INTO @ItemsForTransferPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		) 
		SELECT Ticket.intItemId  
				,dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
				,@intMatchTicketItemUOMId  
				,Ticket.dtmTicketDateTime
				,Ticket.dblNetUnits
				,ItemUOM.dblUnitQty
				,0  
				,0
				,NULL
				,1
				,Ticket.intTicketId 
				,Ticket.intTicketNumber
				,@INVENTORY_TRANSFER_TYPE
				,NULL
				,Ticket.intSubLocationId
				,Ticket.intStorageLocationId
		FROM tblSCTicket Ticket
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intTicketItemUOMId
		WHERE intTicketId = @intTicketId

				-- Call the post routine 
		BEGIN 
			-- Call the post routine 
			INSERT INTO @GLEntries (
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
			)
			EXEC	dbo.uspICPostCosting  
					 @ItemsForTransferPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY_AP
					,@intUserId
		END
	END
	IF @strOriginDestination = '2'
	BEGIN
			-- Get the assembly item to post    
		INSERT INTO @ItemsForTransferPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		) 
		SELECT Ticket.intItemId  
				,dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
				,@intMatchTicketItemUOMId  
				,Ticket.dtmTicketDateTime
				,@dblOriginNetUnits
				,ItemUOM.dblUnitQty
				,0  
				,0
				,NULL
				,1
				,Ticket.intTicketId 
				,Ticket.intTicketNumber
				,@INVENTORY_TRANSFER_TYPE
				,NULL
				,Ticket.intSubLocationId
				,Ticket.intStorageLocationId
		FROM tblSCTicket Ticket
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intTicketItemUOMId
		WHERE intTicketId = @intTicketId

				-- Call the post routine 
		BEGIN 
			-- Call the post routine 
			INSERT INTO @GLEntries (
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
			)
			EXEC	dbo.uspICPostCosting  
					 @ItemsForTransferPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY_AP
					,@intUserId
		END
	END
	IF @strOriginDestination = '3'
	BEGIN
		-- Get the assembly item to post    
		INSERT INTO @ItemsForTransferPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		) 
		SELECT Ticket.intItemId  
				,dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
				,@intMatchTicketItemUOMId  
				,Ticket.dtmTicketDateTime
				,Ticket.dblNetUnits
				,ItemUOM.dblUnitQty
				,0  
				,0
				,NULL
				,1
				,Ticket.intTicketId 
				,Ticket.intTicketNumber
				,@INVENTORY_TRANSFER_TYPE
				,NULL
				,Ticket.intSubLocationId
				,Ticket.intStorageLocationId
		FROM tblSCTicket Ticket
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intTicketItemUOMId
		WHERE intTicketId = @intTicketId

				-- Call the post routine 
		BEGIN 
			-- Call the post routine 
			INSERT INTO @GLEntries (
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
			)
			EXEC	dbo.uspICPostCosting  
					 @ItemsForTransferPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY_AP
					,@intUserId
		END
	END

	UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 
	WHERE intTicketId = @intMatchTicketId

END
IF @strInOutIndicator = 'O'
BEGIN
	INSERT INTO @ItemsForRemovalPost (  
			intItemId  
			,intItemLocationId 
			,intItemUOMId  
			,dtmDate  
			,dblQty  
			,dblUOMQty  
			,dblCost  
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	) 
	SELECT Ticket.intItemId  
			,dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
			,@intTicketItemUOMId  
			,Ticket.dtmTicketDateTime
			,Ticket.dblNetUnits * -1
			,ItemUOM.dblUnitQty
			,0  
			,0
			,NULL
			,1
			,Ticket.intTicketId 
			,Ticket.intTicketNumber
			,@INVENTORY_TRANSFER_TYPE
			,NULL 
			,Ticket.intSubLocationId
			,Ticket.intStorageLocationId
	FROM tblSCTicket Ticket
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intTicketItemUOMId
	WHERE intTicketId = @intTicketId

	-- Call the post routine 
	BEGIN 
		-- Call the post routine 
		INSERT INTO @GLEntries (
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
		)
		EXEC	dbo.uspICPostCosting  
				@ItemsForRemovalPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
	END

	-- Insert the Customer Storage Record 
	INSERT INTO [dbo].[tblGRCustomerStorage]
			   ([intConcurrencyId]
			   ,[intEntityId]
			   ,[intCommodityId]
			   ,[intStorageScheduleId]
			   ,[intStorageTypeId]
			   ,[intCompanyLocationId]
			   ,[intTicketId]
			   ,[intDiscountScheduleId]
			   ,[dblTotalPriceShrink]
			   ,[dblTotalWeightShrink]
			   ,[dblOriginalBalance]
			   ,[dblOpenBalance]
			   ,[dtmDeliveryDate]
			   ,[dtmZeroBalanceDate]
			   ,[strDPARecieptNumber]
			   ,[dtmLastStorageAccrueDate]
			   ,[dblStorageDue]
			   ,[dblStoragePaid]
			   ,[dblInsuranceRate]
			   ,[strOriginState]
			   ,[strInsuranceState]
			   ,[dblFeesDue]
			   ,[dblFeesPaid]
			   ,[dblFreightDueRate]
			   ,[ysnPrinted]
			   ,[dblCurrencyRate]
			   ,[strStorageType])
	SELECT 	[intConcurrencyId]		= 1
			,[intEntityId]			= SC.intEntityId
			,[intCommodityId]		= SC.intCommodityId
			,[intStorageScheduleId]	= NULL -- TODO Storage Schedule
			,[intStorageTypeId]		= NULL
			,[intCompanyLocationId]= SC.intProcessingLocationId
			,[intTicketId]= SC.intTicketId
			,[intDiscountScheduleId]= SC.intDiscountSchedule
			,[dblTotalPriceShrink]= 0
			,[dblTotalWeightShrink]= 0 
			,[dblOriginalBalance]= SC.dblNetUnits 
			,[dblOpenBalance]= SC.dblNetUnits
			,[dtmDeliveryDate]= NULL
			,[dtmZeroBalanceDate]= NULL
			,[strDPARecieptNumber]= NULL
			,[dtmLastStorageAccrueDate]= NULL 
			,[dblStorageDue]= NULL 
			,[dblStoragePaid]= 0
			,[dblInsuranceRate]= 0 
			,[strOriginState]= NULL 
			,[strInsuranceState]= NULL
			,[dblFeesDue]= 0 
			,[dblFeesPaid]= 0 
			,[dblFreightDueRate]= 0 
			,[ysnPrinted]= 0 
			,[dblCurrencyRate]= 1
			,'ITR' 
	FROM	dbo.tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId
END

GO


