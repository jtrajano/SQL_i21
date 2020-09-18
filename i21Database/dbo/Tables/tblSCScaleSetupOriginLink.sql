CREATE TABLE [dbo].[tblSCScaleSetupOriginLink]
(
	intScaleSetupOriginLinkId int not null identity(1,1) primary key,
	intScaleSetupId int not null,
	strStationShortDescription nvarchar(5) not null,
	strLinkStationShortDescription nvarchar(5) not null,
	intConcurrencyId int default(1) not null,

	CONSTRAINT [FK_ScaleSetupOriginLink_ScaleSetup] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup](intScaleSetupId),	
    CONSTRAINT [UK_ScaleSetupOriginLink_ScaleSetup_LinkStation] UNIQUE (intScaleSetupId, strLinkStationShortDescription),
)

