CREATE TABLE [dbo].[tblGRShrinkCalculationOption]
(
	[intValueFieldId] INT NOT NULL, 
    [strDisplayField] NVARCHAR(50) NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblGRShrinkCalculationOption_intValueFieldId] PRIMARY KEY ([intValueFieldId])
)
