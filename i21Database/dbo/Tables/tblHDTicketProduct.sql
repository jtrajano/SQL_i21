CREATE TABLE [dbo].[tblHDTicketProduct]
(
	[intTicketProductId] [int] IDENTITY(1,1) NOT NULL,
	[strProduct] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSort] [int] NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketProduct] PRIMARY KEY CLUSTERED ([intTicketProductId] ASC),
 CONSTRAINT [UNQ_tblHDTicketProduct] UNIQUE ([strProduct])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketProduct',
    @level2type = N'COLUMN',
    @level2name = N'intTicketProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Name (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketProduct',
    @level2type = N'COLUMN',
    @level2name = N'strProduct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketProduct',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketProduct',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketProduct',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'