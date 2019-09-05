PRINT 'BEGIN update delivery sheet to latest ticket date'
if EXISTS(select * from tblSCDeliverySheet DS where dtmDeliverySheetDate != (select top 1 dtmTicketDateTime from tblSCTicket sct where sct.intDeliverySheetId = DS.intDeliverySheetId order by dtmTicketDateTime desc))
	BEGIN
		update tblSCDeliverySheet set dtmDeliverySheetDate = (select top 1 dtmTicketDateTime from tblSCTicket sct where sct.intDeliverySheetId = tblSCDeliverySheet.intDeliverySheetId order by dtmTicketDateTime desc) 
		where dtmDeliverySheetDate != (select top 1 dtmTicketDateTime from tblSCTicket sct where sct.intDeliverySheetId = tblSCDeliverySheet.intDeliverySheetId order by dtmTicketDateTime desc)
	END
Print 'END of updating delivery sheet date'