GO
	PRINT N'BEGIN INSERT DEFAULT AGRONOMY UOM'
GO

SET IDENTITY_INSERT [dbo].[tblAGUnitMeasure] ON

INSERT [dbo].[tblAGUnitMeasure] (
        [intAGUnitMeasureId] 
		,[strUnitMeasure] 
		,[strSymbol] 
		,[strUnitType] 
		,[intDecimalPlaces] 
		,[intConcurrencyId] 
)
SELECT  [intAGUnitMeasureId]      = -1
		,[strUnitMeasure]         = N'Pound'
		,[strSymbol]              = N'lb'
		,[strUnitType]            = N'Weight'
		,[intDecimalPlaces]       = 6
		,[intConcurrencyId]       = 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblAGUnitMeasure WHERE strUnitMeasure = N'Pound')

UNION ALL


SELECT  [intAGUnitMeasureId]      = -2
		,[strUnitMeasure]         = N'Acre'
		,[strSymbol]              = N'acre'
		,[strUnitType]            = N'Area'
		,[intDecimalPlaces]       = 6
		,[intConcurrencyId]       = 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblAGUnitMeasure WHERE strUnitMeasure = N'Acre')

SET IDENTITY_INSERT [dbo].[tblAGUnitMeasure] OFF

GO
	PRINT N'END INSERT DEFAULT AGRONOMY UOM'
GO