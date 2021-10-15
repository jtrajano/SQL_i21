CREATE TABLE [dbo].[tblApiSchemaTransformEffectiveItemPrice] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The effective item price location.
	dblRetailPrice NUMERIC(38, 20) NULL, -- The effective item price.
	dtmEffectiveDate DATETIME NULL -- The item price effetive date
)