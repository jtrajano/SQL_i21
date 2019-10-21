CREATE TABLE [dbo].[tblGRDiscountScheduleLine]
(
	[intDiscountScheduleLineId] INT NOT NULL  IDENTITY, 
    [intDiscountScheduleCodeId] INT NOT NULL, 
    [dblRangeStartingValue] NUMERIC(24, 10) NOT NULL, 
    [dblRangeEndingValue] NUMERIC(24, 10) NOT NULL, 
    [dblIncrementValue] NUMERIC(24, 10) NOT NULL, 
    [dblDiscountValue] NUMERIC(24, 10) NOT NULL, 
    [dblShrinkValue] NUMERIC(24, 10) NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblGRDiscountScheduleLine] PRIMARY KEY ([intDiscountScheduleLineId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleLine_tblGRDiscountScheduleCode] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId]) ON DELETE CASCADE  
)