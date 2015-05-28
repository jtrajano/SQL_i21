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
DECLARE @intGRStorageId AS INT
DECLARE @intScaleStationId AS INT
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

IF @strInOutIndicator = 'I'
BEGIN
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT
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

	select @intMatchTicketItemUOMId, @intMatchTicketUOM, @intTicketUOM, @intTicketItemUOMId

	-- Get the items to post  
	DECLARE @ItemsForRemovalPost AS ItemCostingTableType  
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
			,NULL
			,Ticket.intProcessingLocationId
	FROM tblSCTicket Ticket
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intMatchTicketItemUOMId
	WHERE intTicketId = @intMatchTicketId

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

	-- Get the assembly item to post  
	DECLARE @ItemsForTransferPost AS ItemCostingTableType  
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
			,NULL
			,Ticket.intProcessingLocationId
	FROM tblSCTicket Ticket
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = @intTicketItemUOMId
	WHERE intTicketId = @intTicketId

	UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 
	WHERE intTicketId = @intMatchTicketId

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
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
		END
END
IF @strInOutIndicator = 'O'
BEGIN
	BEGIN 
		SELECT @intScaleStationId = SC.intScaleSetupId
		FROM	dbo.tblSCTicket SC	        
		WHERE	SC.intTicketId = @intTicketId		
	END

	IF @intGRStorageId is NULL
	BEGIN
   		SELECT	@intGRStorageId = ST.intDefaultStorageTypeId
		FROM	dbo.tblSCScaleSetup ST	        
		WHERE	ST.intScaleSetupId = @intScaleStationId
	END

	IF @intGRStorageId IS NULL 
	BEGIN 
		-- Raise the error:
		RAISERROR('Invalid Default Storage Setup - uspSCStorageUpdate', 16, 1);
		RETURN;
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
			   ,[dblCurrencyRate])
	SELECT 	[intConcurrencyId]		= 1
			,[intEntityId]			= SC.intEntityId
			,[intCommodityId]		= SC.intCommodityId
			,[intStorageScheduleId]	= NULL -- TODO Storage Schedule
			,[intStorageTypeId]		= @intGRStorageId
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
	FROM	dbo.tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId
END

GO


