CREATE VIEW [dbo].[vyuSCRailSheetTicketGet]
	AS
select 
	SheetTicket.intRailSheetTicketId
	
	
	,RailSheet.intRailSheetId	
	,RailSheet.strRailSheetNo

	,Ticket.intTicketId
	,Ticket.dblGrossWeight
	,Ticket.dblTareWeight
	,Ticket.dblNetUnits
	,Ticket.dblGrossUnits
	,Ticket.dblShrink
	,Ticket.intItemId
	,Ticket.intCommodityId
	,Ticket.strInOutFlag
	,Ticket.strTicketStatus
	,Ticket.strTicketNumber
	,Ticket.intEntityId
	,Ticket.dtmTicketDateTime
	,Ticket.strDistributionOption
	,(CASE
			
			WHEN Ticket.strTicketStatus = 'O' THEN 'OPEN'
			WHEN Ticket.strTicketStatus = 'A' THEN 'PRINTED'
			WHEN Ticket.strTicketStatus = 'C' THEN 'COMPLETED'
			WHEN Ticket.strTicketStatus = 'V' THEN 'VOID'
			WHEN Ticket.strTicketStatus = 'R' THEN 'REOPENED'
			WHEN Ticket.strTicketStatus = 'S' THEN 'STARTED' 
			WHEN Ticket.strTicketStatus = 'I' THEN 'IN TRANSIT'
			WHEN Ticket.strTicketStatus = 'D' THEN 'DELIVERED'  
			WHEN Ticket.strTicketStatus = 'H'  THEN 'HOLD'
			--CASE
			--	wHEN SCT.ysnDeliverySheetPost = 1 THEN 'COMPLETED' 
			--	ELSE 'HOLD'
			--END
		END) COLLATE Latin1_General_CI_AS AS strTicketStatusDescription
	,dbo.fnSCGetTicketDiscount(SheetTicket.intTicketId) as strGradesReading
	from tblSCRailSheetTicket SheetTicket
		join tblSCRailSheet RailSheet
			on SheetTicket.intRailSheetId = RailSheet.intRailSheetId
		join tblSCTicket  Ticket
			on SheetTicket.intTicketId =  Ticket.intTicketId

go