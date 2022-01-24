CREATE TABLE [dbo].[tblGRCalculationType]
(
	[intCalculationTypeId] INT NOT NULL IDENTITY,
	[strCalculationType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
	CONSTRAINT [PK_tblGRCalculationType_intCalculationTypeId] PRIMARY KEY ([intCalculationTypeId]),
)
GO