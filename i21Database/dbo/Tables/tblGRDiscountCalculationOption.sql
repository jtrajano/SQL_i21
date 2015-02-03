CREATE TABLE [dbo].[tblGRDiscountCalculationOption]
(
	[intValueFieldId] INT NOT NULL, 
    [strDisplayField] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblGRDiscountCalculationOption_intValueFieldId] PRIMARY KEY ([intValueFieldId])
)
