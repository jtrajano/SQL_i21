CREATE TABLE [dbo].[tblCRMSalesPipeStatus]
(
	[intSalesPipeStatusId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strOrder] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strProjectStatus] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[dblProbability] NUMERIC(18, 6) NULL,
	[intStatusId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCRMSalesPipeStatus_intSalesPipeStatusId] PRIMARY KEY CLUSTERED ([intSalesPipeStatusId] ASC),
 CONSTRAINT [UQ_tblCRMSalesPipeStatus_strStatus] UNIQUE ([strStatus]),
 CONSTRAINT [UQ_tblCRMSalesPipeStatus_strOrder] UNIQUE ([strOrder])
 --CONSTRAINT [FK_tblCRMSalesPipeStatus_tblCRMStatus_intStatusId] FOREIGN KEY ([intStatusId]) REFERENCES [dbo].[tblCRMStatus] ([intStatusId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'intSalesPipeStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'strOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Probability',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'dblProbability'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMSalesPipeStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'