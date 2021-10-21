CREATE TABLE [dbo].[tblApiSchemaTransformRebateProgram] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program vendor.
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate vendor program ID.
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program description.
	ysnActive BIT NULL, -- Check if rebate program is active.
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item number.
	strRebateBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item rebate by.
	strRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item unit of measure.
	dblRebateRate NUMERIC(38, 20) NULL, -- The rebate program item rate.
	dtmBeginDate DATETIME NULL, -- The rebate program item begin date.
	dtmEndDate DATETIME NULL, -- The rebate program item end date.
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program customer.
)