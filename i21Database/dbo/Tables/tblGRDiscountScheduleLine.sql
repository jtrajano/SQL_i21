CREATE TABLE [dbo].[tblGRDiscountScheduleLine]
(
	[intDiscountScheduleLineId] INT NOT NULL  IDENTITY, 
    [intDiscountScheduleCodeId] INT NOT NULL, 
    [dblRangeStartingValue] NUMERIC(5, 3) NOT NULL, 
    [dblRangeEndingValue] NUMERIC(5, 3) NOT NULL, 
    [dblIncrementValue] NUMERIC(5, 3) NOT NULL, 
    [dblDiscountValue] NUMERIC(8, 6) NOT NULL, 
    [dblShrinkValue] NUMERIC(6, 4) NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblGRDiscountScheduleLine] PRIMARY KEY ([intDiscountScheduleLineId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleLine_tblGRDiscountScheduleCode] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountScheduleLineId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = 'intDiscountScheduleCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Range Starting Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'dblRangeStartingValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Range Ending Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'dblRangeEndingValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Increment Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'dblIncrementValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleLine',
    @level2type = N'COLUMN',
    @level2name = N'dblShrinkValue'