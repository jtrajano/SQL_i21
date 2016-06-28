CREATE TABLE [dbo].[tblHDSalesPipeStatus]
(
	[intSalesPipeStatusId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strOrder] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strProjectStatus] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[dblProbability] NUMERIC(18, 6) NULL,
	[intTicketStatusId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblHDSalesPipeStatus] PRIMARY KEY CLUSTERED ([intSalesPipeStatusId] ASC),
 CONSTRAINT [UNQ_tblHDSalesPipeStatus] UNIQUE ([strStatus]),
 CONSTRAINT [FK_tblHDSalesPipeStatus_tblHDTicketStatus] FOREIGN KEY ([intTicketStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'intSalesPipeStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Probability',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'dblProbability'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'