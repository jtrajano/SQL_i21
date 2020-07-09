CREATE TABLE [dbo].[tblSCScaleSetupOriginLink]
(
	intScaleSetupOriginLinkId int not null identity(1,1) primary key,
	intScaleSetupId int not null,
	strStationShortDescription nvarchar(5) COLLATE Latin1_General_CI_AS not null,
	strLinkStationShortDescription nvarchar(5) COLLATE Latin1_General_CI_AS not null,
	intConcurrencyId int default(1) not null,

	CONSTRAINT [FK_ScaleSetupOriginLink_ScaleSetup] FOREIGN KEY ([intScaleSetupId]) REFERENCES [tblSCScaleSetup](intScaleSetupId),	
    CONSTRAINT [UK_ScaleSetupOriginLink_ScaleSetup_LinkStation] UNIQUE (intScaleSetupId, strLinkStationShortDescription),
)

