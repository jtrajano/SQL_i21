CREATE TABLE [dbo].[tblSCRailSheetTicketApply]
(
	intRailSheetTicketApplyId int not null identity(1,1) primary key
	,intRailSheetTicketId int not null
	,intRailSheetApplyId int not null
	,dblUnits numeric(38, 20)
	,intConcurrencyId int default(1)

	,constraint fk_tblSCRailSheetTicketApply_tblSCRailSheetTicket_intRailSheetTicketId foreign key (intRailSheetTicketId) references tblSCRailSheetTicket(intRailSheetTicketId) on delete cascade
	,constraint fk_tblSCRailSheetTicketApply_tblSCRailSheetApply_intintRailSheetApplyId foreign key (intRailSheetApplyId) references tblSCRailSheetApply(intRailSheetApplyId) on delete cascade
)
