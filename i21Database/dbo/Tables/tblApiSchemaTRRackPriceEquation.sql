CREATE TABLE [dbo].[tblApiSchemaTRRackPriceEquation]
(
	intRackPriceEquationId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,

	strVendorEntityNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		-- Vendor Entity Number
	strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Location Name
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,				-- Item Number
	strOperand NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,				-- Operand
	dblFactor NUMERIC(18,6) NULL												-- Factor
)
