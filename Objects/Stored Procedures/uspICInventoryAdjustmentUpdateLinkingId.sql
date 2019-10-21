CREATE PROCEDURE [dbo].[uspICInventoryAdjustmentUpdateLinkingId]	
	@LinkingData as InventoryAdjustmentIntegrationId READONLY,
	@ysnShipment as bit = null,
	@ysnReceipt as bit = null

AS
	--this table does not have fk constraint. please make sure the correct id is being passed as the parameter
	if @ysnShipment = 1 and isnull(@ysnReceipt, 0) = 0
	begin 

		update IA set
				intInventoryShipmentId = ID.intInventoryShipmentId, 
				intInventoryReceiptId = ID.intInventoryReceiptId, 
				intTicketId = ID.intTicketId, 
				intInvoiceId = ID.intInvoiceId			
		from tblICInventoryAdjustment as IA
			join @LinkingData as ID
				on IA.intSourceId = ID.intInventoryShipmentId and IA.intSourceTransactionTypeId = 5
	end


RETURN 0
