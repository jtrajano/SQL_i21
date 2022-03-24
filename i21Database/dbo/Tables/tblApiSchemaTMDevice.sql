CREATE TABLE [dbo].[tblApiSchemaTMDevice]
(
	intDeviceId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,

	strDeviceType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 		-- Device Type
	strDescription NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,			-- Description
	strOwnership NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,			-- Ownership
	strBulkPlant  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Bulk Plant Number
	strInventoryStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		-- Inventory Status
	strComment NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,				-- Comment
	strInstalledOnTank NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		-- Installed on Tank
	strRegulatorType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		-- Regulator Type
	--strLeaseNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Lease Number

	dblCapacity NUMERIC(18, 6) NULL,										-- Tank Capacity
	dblReserve NUMERIC(18, 6) NULL,											-- Tank Reserve
	strTankType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Tank Type
	dblEstGallonInTank NUMERIC(18, 6) NULL,									-- Estimate Gallon in Tank
	ysnUnderground BIT NULL,												-- Underground

	strSerialNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		-- Serial Number
	strManufacturer NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,		-- Manufacturer
	dtmManufacturedDate DATETIME NULL,										-- Manufactured Date
	strModelNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Model Number
	strAssetNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Asset Number
	dblPurchasePrice NUMERIC(18, 6) NULL,									-- Purchase Price
	dtmPurchaseDate DATETIME NULL,											-- Purchase Date

	strMeterType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Meter Type
	intMeterCycle INT NULL,													-- Meter Cycle
	strMeterStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			-- Meter Status
	dblMeterReading	NUMERIC(18, 6) NULL,									-- Meter Reading

	strCustomerEntityNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	-- Customer Entity No
	intSiteNumber INT NULL													-- Site Number
)
