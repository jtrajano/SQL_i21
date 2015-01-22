CREATE TABLE [dbo].[tblGRDiscountCrossReference]
(
	[intDiscountCrossReferenceId] INT NOT NULL IDENTITY, 
    [intDiscountId] INT NOT NULL, 
    [intDiscountScheduleId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountCrossReference_intDiscountCrossReferenceId] PRIMARY KEY ([intDiscountCrossReferenceId]), 
    CONSTRAINT [FK_tblGRDiscountCrossReference_tblGRDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]), 
    CONSTRAINT [FK_tblGRDiscountCrossReference_tblGRDiscountSchedule] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [tblGRDiscountSchedule]([intDiscountScheduleId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountCrossReference',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountCrossReferenceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountCrossReference',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountCrossReference',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountScheduleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountCrossReference',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'