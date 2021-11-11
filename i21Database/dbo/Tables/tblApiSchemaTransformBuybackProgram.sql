CREATE TABLE [dbo].[tblApiSchemaTransformBuybackProgram] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The buyback program vendor.
	strProgramName NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The buyback program name.
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor program ID.
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program description.
	strCharge NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The buyback program charges.
	strCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate customer location.
	strVendorCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate customer location vendor custom name.
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate item number.
	strVendorItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate item vendor custom name.
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate unit of measure.
	strVendorUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback program rate unit of measure vendor custom name.
	dtmBeginDate DATETIME NOT NULL, -- The buyback program rate begin date.
	dtmEndDate DATETIME NULL, -- The buyback program rate end date.
	dblRatePerUnit NUMERIC(38, 20) NOT NULL -- The buyback program rate per unit.
)