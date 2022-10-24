CREATE TABLE [dbo].[tblCRMOpportunityRelatedOpportunity]
(
	[intOpportunityRelatedOpportunityId]	INT IDENTITY(1,1) NOT NULL,
	[intOpportunityId]						INT NOT NULL,
    [intRelatedOpportunityId]				INT NOT NULL,
	[intConcurrencyId]						INT CONSTRAINT [DF_tblCRMOpportunityRelatedOpportunity_intConCurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblCRMOpportunityRelatedOpportunity] PRIMARY KEY CLUSTERED ([intOpportunityRelatedOpportunityId] ASC),
	CONSTRAINT [FK_tblCRMOpportunityRelatedOpportunity_tblCRMOpportunity_Opportunity] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]),
	CONSTRAINT [FK_tblCRMOpportunityRelatedOpportunity_tblCRMOpportunity_RelatedOpportunity] FOREIGN KEY ([intRelatedOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]),
)
