CREATE TABLE [dbo].[tblSMReplicationConfiguration]
(
	[intReplicationConfigurationId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intMultiCompanyId] INT NOT NULL, 
    [intModuleId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
    [ysnEnabled] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
	CONSTRAINT [FK_tblSMReplicationConfiguration_tblSMMultiCompany] FOREIGN KEY ([intMultiCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]), 
    CONSTRAINT [FK_tblSMReplicationConfiguration_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [tblSMModule]([intModuleId]), 
    CONSTRAINT [FK_tblSMReplicationConfiguration_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId])
)