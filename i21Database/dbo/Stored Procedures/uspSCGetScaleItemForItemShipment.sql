CREATE PROCEDURE [dbo].[uspSCGetScaleItemForItemShipment] --uspSCGetScaleItemForItemReceipt 8, 'Direct'
	 @intTicketId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId INT
	,@strDistributionOption AS NVARCHAR(3)
	,@LineItems ScaleTransactionTableType  ReadOnly

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @CurrentServerDate AS DATETIME = GETDATE()

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'SalesOrder'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
DECLARE @ScaleDistributionOption AS NVARCHAR(3) = @strDistributionOption
DECLARE @ErrMsg NVARCHAR(MAX)

DECLARE @intPurchaseOrderType AS INT = 1
DECLARE @intTransferOrderType AS INT = 2
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @strTicketInOutFlag AS NVARCHAR(1) = NULL


BEGIN TRY
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
			WHERE	UM.intUnitMeasureId =@intTicketUOM AND SC.intTicketId = @intTicketId
		END
		IF @strDistributionOption = 'CNT'
		BEGIN
				IF @strSourceType = @SALES_ORDER
			BEGIN 
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = LI.dblUnitsDistributed 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = LI.dblCost
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = NULL
						,intStorageLocationId = NULL
				FROM	@LineItems LI 
				JOIN dbo.tblSCTicket ScaleTicket On ScaleTicket.intTicketId = LI.intTicketId
				JOIN dbo.tblICItemUOM ItemUOM	ON ScaleTicket.intItemId = ItemUOM.intItemId AND @intTicketItemUOMId = ItemUOM.intItemUOMId
				JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	LI.intTicketId = @intTicketId
			END
		END
		Else
		BEGIN
			IF @strSourceType = @SALES_ORDER
			BEGIN 
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = @dblNetUnits 
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = @dblCost
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = NULL
						,intStorageLocationId = NULL
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ScaleTicket.intItemId = ItemUOM.intItemId
							AND @intTicketItemUOMId = ItemUOM.intItemUOMId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ScaleTicket.intItemId = ItemLocation.intItemId
							-- Use "Ship To" because this is where the items in the PO will be delivered by the Vendor. 
							AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							INNER JOIN dbo.tblICCommodityUnitMeasure TicketCommodityUOM On ScaleTicket.intCommodityId  = TicketCommodityUOM.intCommodityId
						AND TicketCommodityUOM.ysnStockUnit = 1
				WHERE	ScaleTicket.intTicketId = @intTicketId
			
			END
		END
END TRY

BEGIN CATCH

       SET @ErrMsg = 'uspSCGetScaleItemForItemShipment - ' + ERROR_MESSAGE()  
       RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
       
END CATCH

-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder
-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder




GO


