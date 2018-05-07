CREATE TABLE [dbo].[tblSMReplicationConfiguration]
(
	[intReplicationConfigurationId] INT NOT NULL PRIMARY KEY IDENTITY, 	
    [intModuleId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
	[strType] NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
    [ysnEnabled] BIT NOT NULL DEFAULT 1,
	[ysnCommitted] BIT NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMReplicationConfiguration_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [tblSMModule]([intModuleId]), 
    CONSTRAINT [FK_tblSMReplicationConfiguration_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId])
)