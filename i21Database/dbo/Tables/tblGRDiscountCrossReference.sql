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