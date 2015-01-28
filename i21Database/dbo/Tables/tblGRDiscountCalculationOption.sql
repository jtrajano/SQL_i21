CREATE TABLE [dbo].[tblGRDiscountCalculationOption]
(
	[intValueFieldId] INT NOT NULL, 
    [strDisplayField] NVARCHAR(50) NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblGRDiscountCalculationOption_intValueFieldId] PRIMARY KEY ([intValueFieldId])
)
