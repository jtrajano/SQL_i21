CREATE TABLE [dbo].[tblSMReplicationConfigurationTable]
(
	[intReplicationConfigurationTableId] INT NOT NULL PRIMARY KEY IDENTITY, 	
	[intReplicationConfigurationId] INT NOT NULL, 	
	[intReplicationTableId] INT NOT NULL, 	
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    [ysnInitOnly] BIT NULL DEFAULT 0, 

	CONSTRAINT [FK_tblSMReplicationConfigurationTable_tblSMReplicationConfiguration] FOREIGN KEY ([intReplicationConfigurationId]) REFERENCES [tblSMReplicationConfiguration]([intReplicationConfigurationId]), 
    CONSTRAINT [FK_tblSMReplicationConfigurationTable_tblSMReplicationTable] FOREIGN KEY ([intReplicationTableId]) REFERENCES [tblSMReplicationTable]([intReplicationTableId])
)