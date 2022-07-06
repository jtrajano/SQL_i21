CREATE TABLE [dbo].[tblApiSchemaTransformEffectiveItemCost] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The effective item cost location.
	dblCost NUMERIC(38, 20) NULL, -- The effective item cost.
	dtmEffectiveDate DATETIME NULL -- The item cost effetive date
)