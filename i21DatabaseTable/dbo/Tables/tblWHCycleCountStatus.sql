CREATE TABLE [dbo].[tblWHCycleCountStatus]
(
	[intCycleCountStatusId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strInternalCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS  NULL,
	[strCycleCountStatus] NVARCHAR(32) COLLATE Latin1_General_CI_AS  NULL,
	[ysnIsDefault] BIT,
	[ysnLocked] BIT,
	[intLastUpdateId] INT,
	[dtmLastUpdateOn] DATETIME,

	CONSTRAINT [PK_tblWHCycleCountStatus_intCycleCountStatusId]  PRIMARY KEY ([intCycleCountStatusId]),	

)
