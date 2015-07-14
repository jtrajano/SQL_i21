CREATE PROCEDURE [dbo].[uspSCGetScaleItemForItemReceipt] --uspSCGetScaleItemForItemReceipt 8, 'Direct'
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

DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'
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
		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
				--IF @strSourceType = @ReceiptType_Direct
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
						,intTransactionDetailId = LI.intContractDetailId
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 0
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
			--IF @strSourceType = @ReceiptType_Direct
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
						,intTransactionDetailId = NULL
						,strTransactionId = ScaleTicket.intTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsCustody = 0
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

       SET @ErrMsg = 'uspSCGetScaleItemForItemReceipt - ' + ERROR_MESSAGE()  
       RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
       
END CATCH

-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder
-- TODO: IF @strSourceType = @@ReceiptType_TransferOrder