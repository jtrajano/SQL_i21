CREATE TABLE [dbo].[tblGRShrinkCalculationOption]
(
	[intValueFieldId] INT NOT NULL, 
    [strDisplayField] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblGRShrinkCalculationOption_intValueFieldId] PRIMARY KEY ([intValueFieldId])
)
