CREATE TABLE [dbo].[tblHDOpportunityContract]
(
	[intOpportunityContractId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intContractHeaderId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityContract] PRIMARY KEY CLUSTERED ([intOpportunityContractId] ASC),
	CONSTRAINT [AK_tblHDOpportunityContract_intProjectId_intSalesOrderId] UNIQUE ([intProjectId],[intContractHeaderId]),
    CONSTRAINT [FK_tblHDOpportunityContract_tblHDProject] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]),
    CONSTRAINT [FK_tblHDOpportunityContract_tblCTContractHeader] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityContract',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityContract',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Contract Header Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityContract',
    @level2type = N'COLUMN',
    @level2name = N'intContractHeaderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunityContract',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'