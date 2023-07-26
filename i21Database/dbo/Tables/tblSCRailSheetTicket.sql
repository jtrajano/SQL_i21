CREATE TABLE [dbo].[tblSCRailSheetTicket]
(
	intRailSheetTicketId int not null identity(1,1) primary key
	,intRailSheetId int not null
	,intTicketId int not null
	,intConcurrencyId int default(1)

	,constraint fk_tblSCRailSheetTicket_tblSCRailSheet_intRailSheetId foreign key (intRailSheetId) references tblSCRailSheet(intRailSheetId)  ON DELETE CASCADE
	,constraint fk_tblSCRailSheetTicket_tblSCTicket_intTicketId foreign key (intTicketId) references tblSCTicket(intTicketId)   ON DELETE CASCADE
)
