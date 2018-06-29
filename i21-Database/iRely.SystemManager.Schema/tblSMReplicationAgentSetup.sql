CREATE TABLE [dbo].[tblSMReplicationAgentSetup]
(
	[intAgentId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 	
	[strUserName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)