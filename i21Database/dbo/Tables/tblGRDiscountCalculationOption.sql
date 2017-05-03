CREATE TABLE [dbo].[tblGRDiscountCalculationOption]
(
	[intDiscountCalculationOptionId] INT NOT NULL, 
    [strDiscountCalculationOption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblGRDiscountCalculationOption_intDiscountCalculationOptionId] PRIMARY KEY ([intDiscountCalculationOptionId])
)
