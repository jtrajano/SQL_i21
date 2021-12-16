CREATE TABLE [dbo].[tblApiSchemaTRVendorSupplyPointDetail]
(
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
 
	strVendorEntityNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,			-- Vendor Entity Number				| REQUIRED
	strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,			-- Location Name					| REQUIRED
	strGrossOrNet NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,				-- Gross or Net						| REQUIRED
	strFuelDealerId1 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- Fuel Dealer ID1					| OPTIONAL
	strFuelDealerId2 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- Fuel Dealer ID2					| OPTIONAL
	strDefaultOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- Default Origin					| OPTIONAL
	strTerminalNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,					-- Terminal No						| OPTIONAL
	strSupplyPointForRackPrices NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,	-- Supply Point For Rack Prices		| OPTIONAL
	ysnMultipleDueDates BIT NULL,													-- Multiple Due Dates				| OPTIONAL
)