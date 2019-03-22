
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnICGetScaleTicketIdForShipmentCharge](
	@intInventoryShipmentId INT
	,@strShipmentNumber NVARCHAR(50)
)
RETURNS TABLE
RETURN (
	-- Assuming that there is only one IR per Scale Ticket id, then pick the top ticket id we can retrieve 
	-- when joining the IR and Scale Ticket tables. 
	SELECT	TOP 1 
			intScaleTicketId = st.intTicketId
			,strScaleTicketNumber = st.strTicketNumber
	FROM	tblICInventoryShipment r INNER JOIN tblICInventoryShipmentItem ri
				ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN tblSCTicket st
				ON st.intTicketId = ri.intSourceId
	WHERE	r.intInventoryShipmentId = @intInventoryShipmentId
			AND r.strShipmentNumber = @strShipmentNumber 
			AND r.intSourceType = 1 -- Scale
			AND st.intTicketId IS NOT NULL 		

)	