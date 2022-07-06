CREATE TABLE [dbo].[tblApiSchemaTransformUnitMeasure] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The unit measure.
	strSymbol NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The unit measure symbol.
	strUnitType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The unit type.
	intDecimalPlaces INT NULL -- The unit measure decimal places.
)