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


	,strLeadCarNo nvarchar(100) null
	,strBOLNo nvarchar(100) null
	,dtmBOLDate datetime null
	,intCityLoadingPortId int null
	,intCityDestinationPortId int null
	,intCityDestinationCityId int null
	,intEntityTerminalId int null

	,ysnPosted bit null default(0)

	,intConcurrencyId int default(1)

	,constraint UQ_tblSCRailSheet_strRailSheetNo unique (strRailSheetNo)
)
