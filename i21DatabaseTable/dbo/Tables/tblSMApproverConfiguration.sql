CREATE TABLE [dbo].[tblSMApproverConfiguration]
(
	[intApproverConfigurationId]	INT	NOT NULL	PRIMARY KEY IDENTITY, 
    [intEntityId]					INT	NOT NULL, 
    [intConcurrencyId]				INT	NOT NULL	DEFAULT 1, 
    CONSTRAINT [AK_tblSMApproverConfiguration_intEntityId] UNIQUE ([intEntityId])
)
