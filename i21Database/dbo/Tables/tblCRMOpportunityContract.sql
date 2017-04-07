CREATE TABLE [dbo].[tblCRMOpportunityContract]
(
	[intOpportunityContractId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intContractHeaderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityContract_intOpportunityQuoteId] PRIMARY KEY CLUSTERED ([intOpportunityContractId] ASC),
	CONSTRAINT [AK_tblCRMOpportunityContract_intOpportunityId_intContractHeaderId] UNIQUE ([intOpportunityId],[intContractHeaderId]),
    CONSTRAINT [FK_tblCRMOpportunityContract_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityContract_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]) ON DELETE CASCADE
)
