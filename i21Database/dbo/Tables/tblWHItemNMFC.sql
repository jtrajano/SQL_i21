CREATE TABLE [dbo].[tblWHItemNMFC]
(
	[intItemNMFCId]	INT,
	[intExternalSystemId] INT,
	[strInternalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDisplayMember] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnDefault] BIT,
	[ysnLocked]	BIT,
	[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastUpdateOn] DATETIME,
	[intSort] INT,
	[intConcurrencyId] INT
)
