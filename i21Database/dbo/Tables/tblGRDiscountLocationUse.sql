CREATE TABLE [dbo].[tblGRDiscountLocationUse]
(
	[intDiscountLocationUseId] INT NOT NULL  IDENTITY, 
    [intDiscountId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [ysnDiscountLocationActive] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountLocationUse_intDiscountLocationUseId] PRIMARY KEY ([intDiscountLocationUseId]), 
    CONSTRAINT [FK_tblGRDiscountLocationUse_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblGRDiscountLocationUse_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountLocationUse',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountLocationUseId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountLocationUse',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountLocationUse',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Location Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountLocationUse',
    @level2type = N'COLUMN',
    @level2name = N'ysnDiscountLocationActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountLocationUse',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'