CREATE TABLE [dbo].[tblApiSchemaTRProductSearch]
(
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
 
	strVendorEntityNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,			-- Vendor Entity Number				| REQUIRED
	strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,			-- Location Name					| REQUIRED
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,					-- Item Number						| REQUIRED
	strSearchValue NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,				-- Search Value						| REQUIRED
)