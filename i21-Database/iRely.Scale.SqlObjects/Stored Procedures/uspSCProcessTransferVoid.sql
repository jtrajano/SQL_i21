CREATE PROCEDURE [dbo].[uspSCProcessTransferVoid]
	 @intTicketId AS INT
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intCustomerStorageId AS INT
DECLARE @intTicketUOM AS INT
DECLARE @intTicketItemUOMId AS INT
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
DECLARE @GLEntries AS RecapTableType
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @STARTING_NUMBER_BATCH AS INT = 3
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'

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

-- Get the items to post  
DECLARE @ItemsForRemovalPost AS ItemCostingTableType

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
	SELECT  intItemId = Ticket.intItemId  
			,intItemLocationId = dbo.fnICGetItemLocation(Ticket.intItemId, Ticket.intProcessingLocationId)
			,intItemUOMId = @intTicketItemUOMId  
			,dtmDate = Ticket.dtmTicketDateTime
			,dblQty = Ticket.dblNetUnits
			,dblUOMQty = ItemUOM.dblUnitQty
			,dblCost = 0  
			,dblSalesPrice = 0
			,intCurrencyId = Ticket.intCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = Ticket.intTicketId 
			,strTransactionId = Ticket.strTicketNumber
			,intTransactionTypeId = @INVENTORY_TRANSFER_TYPE
			,intLotId = NULL 
			,intSubLocationId = Ticket.intSubLocationId
			,intStorageLocationId = Ticket.intStorageLocationId
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
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
		)
		EXEC	dbo.uspICPostCosting  
				@ItemsForRemovalPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
	END

	UPDATE tblGRCustomerStorage SET dblOpenBalance = 0 
	WHERE intTicketId = @intTicketId
END

GO


