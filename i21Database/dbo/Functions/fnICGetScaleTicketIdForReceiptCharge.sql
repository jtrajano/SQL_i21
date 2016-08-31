-- Assuming that there is only one IR per Scale Ticket id, then pick the top ticket id we can retrieve 
-- when joining the IR and Scale Ticket tables. 

CREATE FUNCTION [dbo].[fnICGetScaleTicketIdForReceiptCharge](
	@intInventoryReceiptId INT
	,@strReceiptNumber NVARCHAR(50)
)
RETURNS TABLE
RETURN (
	SELECT	TOP 1 
			intScaleTicketId = st.intTicketId
			,strScaleTicketNumber = st.strTicketNumber
	FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st
				ON st.intTicketId = ri.intSourceId
	WHERE	r.intInventoryReceiptId = @intInventoryReceiptId
			AND r.strReceiptNumber = @strReceiptNumber 
			AND r.intSourceType = 1 -- Scale
			AND st.intTicketId IS NOT NULL 		

)	