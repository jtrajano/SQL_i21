CREATE TABLE [dbo].[tblHDOpportunitySource]
(
	[intOpportunitySourceId] [int] IDENTITY(1,1) NOT NULL,
	[strSource] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunitySource] PRIMARY KEY CLUSTERED ([intOpportunitySourceId] ASC),
	CONSTRAINT [AK_tblHDOpportunitySource_strSource] UNIQUE ([strSource])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunitySource',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunitySourceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunitySource',
    @level2type = N'COLUMN',
    @level2name = N'strSource'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOpportunitySource',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'