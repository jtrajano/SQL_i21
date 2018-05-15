CREATE TABLE [dbo].[tblGRShrinkCalculationOption]
(
	[intShrinkCalculationOptionId] INT NOT NULL, 
    [strShrinkCalculationOption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(MAX) NOT NULL,    
    [intConcurrencyId] INT NOT NULL,
    [intOrderById] INT NOT NULL 
	CONSTRAINT [PK_tblGRShrinkCalculationOption_intShrinkCalculationOptionId] PRIMARY KEY ([intShrinkCalculationOptionId])
)