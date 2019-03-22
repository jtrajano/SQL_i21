CREATE TABLE [dbo].[tblHDUpgradeType]
(
	[intUpgradeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL default 1, 
	CONSTRAINT [PK_tblHDUpgradeType_intUpgradeTypeId] PRIMARY KEY CLUSTERED ([intUpgradeTypeId] ASC)
)
