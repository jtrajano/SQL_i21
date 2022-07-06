	CREATE TABLE [dbo].[tblAGUnitMeasureConversion]
	(
		[intAGUnitMeasureConversionId] INT NOT NULL IDENTITY, 
		[intAGUnitMeasureId] INT NOT NULL, 
		[intStockUnitMeasureId] INT NOT NULL, 
		[dblConversionToStock] NUMERIC(38, 20) NULL DEFAULT ((0)), 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		CONSTRAINT [PK_tblAGUnitMeasureConversion_intAGUnitMeasureConversionId] PRIMARY KEY ([intAGUnitMeasureConversionId]), 
		CONSTRAINT [FK_tblAGUnitMeasureConversion_tblAGUnitMeasure] FOREIGN KEY ([intAGUnitMeasureId]) REFERENCES [tblAGUnitMeasure]([intAGUnitMeasureId]) ON DELETE CASCADE,
		CONSTRAINT [FK_tblAGUnitMeasureConversion_StockUnitMeasure] FOREIGN KEY ([intStockUnitMeasureId]) REFERENCES [tblAGUnitMeasure]([intAGUnitMeasureId]) 
	)