CREATE TABLE [dbo].[tblApiSchemaTransformRebateProgram] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program vendor.
	strVendorProgram NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate vendor program ID.
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program description.
	ysnActive BIT NULL, -- Check if rebate program is active.
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item number.
	strItemName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item name.
	strVendorItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item number vendor custom name.
	strRebateBy NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item rebate by.
	strRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item unit of measure.
	strVendorRebateUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item unit of measure vendor custom name.
	dblRebateRate NUMERIC(38, 20) NULL, -- The rebate program item rate.
	dtmBeginDate DATETIME NULL, -- The rebate program item begin date.
	dtmEndDate DATETIME NULL, -- The rebate program item end date.
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item category.
	strVendorCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program item category vendor custom name.
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program customer.
	strCustomerName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program customer name.
	strVendorCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The rebate program customer vendor custom name.
)