CREATE TABLE [dbo].[tblCRMOpportunityLob]
(
	[intOpportunityLobId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intLineOfBusinessId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityLob_intOpportunityLobId] PRIMARY KEY CLUSTERED ([intOpportunityLobId] ASC),
	CONSTRAINT [UQ_tblCRMOpportunityLob_intOpportunityId_intLineOfBusinessId] UNIQUE ([intOpportunityId],[intLineOfBusinessId]),
    CONSTRAINT [FK_tblCRMOpportunityLob_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityLob_tblSMLineOfBusiness_intLineOfBusinessId] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblSMLineOfBusiness] ([intLineOfBusinessId]) ON DELETE CASCADE
)
