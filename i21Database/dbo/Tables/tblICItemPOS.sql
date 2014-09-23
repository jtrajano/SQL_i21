CREATE TABLE [dbo].[tblICItemPOS]
(
	[intItemId] INT NOT NULL, 
    [strUPCNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCaseUOM] INT NULL, 
    [strNACSCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strWICCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intAGCategory] INT NULL, 
    [ysnReceiptCommentRequired] BIT NULL DEFAULT ((0)), 
    [strCountCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnLandedCost] BIT NOT NULL DEFAULT ((0)), 
    [strLeadTime] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTaxable] BIT NOT NULL DEFAULT ((0)), 
    [strKeywords] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblCaseQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dtmDateShip] DATETIME NULL, 
    [dblTaxExempt] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnDropShip] BIT NOT NULL DEFAULT ((0)), 
    [ysnCommisionable] BIT NOT NULL DEFAULT ((0)), 
    [strSpecialCommission] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemPOS] PRIMARY KEY ([intItemId]), 
    CONSTRAINT [FK_tblICItemPOS_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UPC Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strUPCNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Case Unit of Measure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = 'intCaseUOM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NACS Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strNACSCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'WIC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strWICCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AG Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'intAGCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Comment Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'ysnReceiptCommentRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Count Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strCountCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Landed Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'ysnLandedCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lead Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strLeadTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Keywords',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strKeywords'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Case Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'dblCaseQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Ship',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateShip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Exempt',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxExempt'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Drop Ship',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'ysnDropShip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commisionable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'ysnCommisionable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Special Commission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'strSpecialCommission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOS',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'