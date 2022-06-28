CREATE TABLE [dbo].[tblSCRailSheetTicketLog]
(
	intRailSheetTicketLogId int not null identity(1,1) primary key
	,intRailSheetTicketId int not null
	,strLog nvarchar(100)
	,ysnError bit not null default(0)
	,dtmDate datetime default(getdate())
	,intConcurrencyId int default(1)
	
	,constraint fk_tblSCRailSheetTicketLog_tblSCRailSheetTicket_intRailSheetTicketId foreign key (intRailSheetTicketId) references tblSCRailSheetTicket(intRailSheetTicketId)
)
