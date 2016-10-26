CREATE TABLE [dbo].[tblCRMContract]
(
	[intContractId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intContractHeaderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMContract_intContractId] PRIMARY KEY CLUSTERED ([intContractId] ASC),
	CONSTRAINT [UQ_tblCRMContract_intOpportunityId_intContractHeaderId] UNIQUE ([intOpportunityId],[intContractHeaderId]),
    CONSTRAINT [FK_tblCRMContract_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]),
	CONSTRAINT [FK_tblCRMContract_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMContract',
    @level2type = N'COLUMN',
    @level2name = N'intContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMContract',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Contract Header Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMContract',
    @level2type = N'COLUMN',
    @level2name = N'intContractHeaderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMContract',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'