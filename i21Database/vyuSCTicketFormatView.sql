CREATE VIEW [dbo].[vyuSCTicketFormatView]
	AS SELECT SCFormat.intTicketFormatId
	,SCFormat.strTicketFormat
	,SCFormat.intTicketFormatSelection
	,CASE
		WHEN SCFormat.intTicketFormatSelection = 1 THEN 'Full Sheet'
		WHEN SCFormat.intTicketFormatSelection = 2 THEN 'Half Sheet'
		WHEN SCFormat.intTicketFormatSelection = 3 THEN 'Grades(1)'
		WHEN SCFormat.intTicketFormatSelection = 4 THEN 'Grades/Amounts(2)'
		WHEN SCFormat.intTicketFormatSelection = 5 THEN 'Grades W/O Shrink(3)'
		WHEN SCFormat.intTicketFormatSelection = 6 THEN 'Grades/Amount/Shrink(4)'
		WHEN SCFormat.intTicketFormatSelection = 7 THEN 'Grades w/BOL(B)'
		WHEN SCFormat.intTicketFormatSelection = 8 THEN 'Canadian(C)'
		WHEN SCFormat.intTicketFormatSelection = 9 THEN 'Origin Full Sheet(F)'
		WHEN SCFormat.intTicketFormatSelection = 10 THEN 'No Compression(H)'
		WHEN SCFormat.intTicketFormatSelection = 11 THEN 'Grades and Discounts(U)'
		WHEN SCFormat.intTicketFormatSelection = 12 THEN 'Plant Ticket'
		WHEN SCFormat.intTicketFormatSelection = 13 THEN 'Grading Tag'
		WHEN SCFormat.intTicketFormatSelection = 14 THEN '120mm Kiosk (Standard)'
		WHEN SCFormat.intTicketFormatSelection = 15 THEN 'Full Sheet Kiosk'
		WHEN SCFormat.intTicketFormatSelection = 16 THEN '80mm Kiosk (Narrow)'
	END as strTicketFormatSelection
	,SCFormat.ysnSuppressCompanyName
	,SCFormat.ysnFormFeedEachCopy
	,SCFormat.strTicketHeader
	,SCFormat.strTicketFooter
	FROM tblSCTicketFormat SCFormat