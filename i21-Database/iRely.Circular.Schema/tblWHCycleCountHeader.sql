CREATE TABLE [dbo].[tblWHCycleCountHeader]
(
	[intCycleCountHeaderId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strTitle] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[intAddressId] INT,
	[intStatusId] INT,
	[strStorageLocationMask] NVARCHAR(16) COLLATE Latin1_General_CI_AS  NULL,
	[dtmStartDate] DATETIME,
	[dtmStopDate] DATETIME,
	[strNote] NVARCHAR(1024) COLLATE Latin1_General_CI_AS  NULL,
	[ysnLocked] BIT,
	[intLastUpdateId] INT,
	[dtmLastUpdateOn] DATETIME,
	[intCycleCountTypeId] INT,
	[intItemId] INT,
	[ysnPosted] BIT,

	CONSTRAINT [PK_tblWHCycleCountHeader_intCycleCountHeaderId]  PRIMARY KEY ([intCycleCountHeaderId]),	
)
