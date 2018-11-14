CREATE TABLE [dbo].[tblHDUpgradeEnvironment]
(
	[intUpgradeEnvironmentId] [int] IDENTITY(1,1) NOT NULL,
	[strEnvironment] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL default 1, 
	CONSTRAINT [PK_tblHDUpgradeEnvironment_intUpgradeEnvironmentId] PRIMARY KEY CLUSTERED ([intUpgradeEnvironmentId] ASC)
)
