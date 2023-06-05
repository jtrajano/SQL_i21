CREATE TABLE [dbo].[tblApiSchemaVendorXref]
(
	guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
    intKey INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,

    [strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorName] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblConversionFactor] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
    [strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
)
