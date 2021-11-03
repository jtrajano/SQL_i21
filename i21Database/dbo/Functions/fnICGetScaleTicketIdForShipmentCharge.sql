
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnICGetScaleTicketIdForShipmentCharge](
	@intInventoryShipmentId INT
	,@strShipmentNumber NVARCHAR(50)
)
RETURNS TABLE
RETURN (
	-- Assuming that there is only one Shipment per Scale Ticket id, then pick the top ticket id we can retrieve 
	-- when joining the Shipment and Scale Ticket tables. 
	SELECT	TOP 1 
			intScaleTicketId = st.intTicketId
			,strScaleTicketNumber = st.strTicketNumber
			,l.strLoadNumber
			,l.intLoadId
			,ld.intLoadDetailId
	FROM	tblICInventoryShipment r INNER JOIN tblICInventoryShipmentItem ri
				ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN tblSCTicket st
				ON st.intTicketId = ri.intSourceId
			LEFT JOIN tblLGLoadDetail ld
				ON ld.intLoadDetailId = st.intLoadDetailId 
			LEFT JOIN tblLGLoad l
				ON l.intLoadId = ld.intLoadId

	WHERE	r.intInventoryShipmentId = @intInventoryShipmentId
			AND r.strShipmentNumber = @strShipmentNumber 
			AND r.intSourceType = 1 -- Scale
			AND st.intTicketId IS NOT NULL 		

)	