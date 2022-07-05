CREATE TABLE [dbo].[tblSCRailSheetLog]
(
	intRailSheetLogId int not null identity(1,1) primary key
	,intRailSheetId int not null
	,strLog nvarchar(100) COLLATE Latin1_General_CI_AS 
	,ysnError bit not null default(0)
	,dtmDate datetime default(getdate())
	,intConcurrencyId int default(1)
	
	,constraint fk_tblSCRailSheetLog_tblSCRailSheet_intRailSheetId foreign key (intRailSheetId) references tblSCRailSheet(intRailSheetId)
)
