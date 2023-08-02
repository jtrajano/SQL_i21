CREATE TABLE [dbo].[tblSCRailSheet]
(
	intRailSheetId int not null identity(1,1) primary key
	,strRailSheetNo nvarchar(50)  COLLATE Latin1_General_CI_AS not null	
	,intTicketTypeId int not null		
    ,intEntityId int not null
	,intCurrencyId int not null
    ,dtmDate datetime not null default(getdate())
    --,dtmDateUTC datetime not null default(getdate())
	,intScaleSetupId int not null

	,intEntityScaleOperatorId int not null
    ,intItemId int not null    
	,intStorageScheduleRuleId int null
	,intDiscountId int not null


	,strLeadCarNo nvarchar(100) COLLATE Latin1_General_CI_AS null  
	,strBOLNo nvarchar(100) COLLATE Latin1_General_CI_AS null
	,dtmBOLDate datetime null
	,intCityLoadingPortId int null
	,intCityDestinationPortId int null
	,intCityDestinationCityId int null
	,intEntityTerminalId int null

	,ysnPosted bit null default(0)

	,intConcurrencyId int default(1)

	,constraint UQ_tblSCRailSheet_strRailSheetNo unique (strRailSheetNo)
)

GO

CREATE TRIGGER [dbo].[trg_tblSCRailSheet] ON [dbo].[tblSCRailSheet]
INSTEAD OF DELETE  
AS
BEGIN

	DELETE A
	FROM [tblSCRailSheetTicket] A
	INNER JOIN DELETED B ON A.intRailSheetId = B.intRailSheetId

	DELETE A
	FROM [tblSCRailSheetApply] A
	INNER JOIN DELETED B ON A.intRailSheetId = B.intRailSheetId

	DELETE A
	FROM [tblSCRailSheet] A
	INNER JOIN DELETED B ON A.intRailSheetId = B.intRailSheetId
	
END
GO