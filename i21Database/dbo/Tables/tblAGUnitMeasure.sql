	CREATE TABLE [dbo].[tblAGUnitMeasure]
	(
		[intAGUnitMeasureId] INT NOT NULL IDENTITY, 
		[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strSymbol] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strUnitType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intDecimalPlaces] INT NULL DEFAULT 6, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblAGUnitMeasure_intAGUnitMeasureId] PRIMARY KEY ([intAGUnitMeasureId]), 
		CONSTRAINT [UK_tblAGUnitMeasure_strUnitMeasure] UNIQUE ([strUnitMeasure]) 
	)