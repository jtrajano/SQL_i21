CREATE TABLE [dbo].[tblApiSchemaTMConsumptionSite]
(
	intConsumptionSiteId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strCustomerEntityNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, 	-- Customer Entity Number
	strBillingBy NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Billing By
	strSiteNumber NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,			-- Site Number
	ysnActive BIT NULL,														-- Active
	strSiteDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,		-- Site Description
	strAddress NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,				-- Address 
	strZipCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,				-- Zip Code
	strCity NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- City
	strState NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- State
	strCountry NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,				-- Country
	dblLatitude NUMERIC(18,6) NULL,											-- Latitude
	dblLongitude NUMERIC(18,6) NULL,										-- Longitude
	strDriverId NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,		-- Driver ID
	strRoute NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,			-- Route
	strSequence NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Sequence
	strFacilityNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Facility No
	
	strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,	-- Location Name
	dblCapacity NUMERIC(18,6) NULL,											-- Capacity
	strClock NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,			-- Clock Number
	dblReserve NUMERIC(18,6) NULL,											-- Reserve
	strAccountStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,	-- Account Status Cocde
	strDeliveryTerm NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,		-- Delivery Term
	dblPriceAdj NUMERIC(18,6) NULL,											-- Price Adjustment
	strPriceLevel NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Pricing Level
	ysnSaleTax BIT NULL,													-- Sale Tax
	strRecurringPONo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,		-- Recurring PO Number
	strTaxGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,			-- Tax Group
	strClassFill NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Class Fill
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,			-- Item No

	ysnHold BIT NULL,														-- On Hold
	ysnHoldDDCalc BIT NULL,													-- Hold Degree Day Calculate
	strHoldReason NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,			-- Hold Reason
	dtmHoldStartDate DATETIME NULL,											-- Hold Start Date
	dtmHoldEndDate DATETIME NULL,											-- Hold End Date
	ysnLost BIT NULL,														-- Lost
	dtmLostDate DATETIME NULL,												-- Lost Date
	strLostReason NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,			-- Lost Reason

	strFillMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Fill Method
	strFillGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,			-- Fill Group Code
	strJulianCalendar NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,		-- Julian Calendar
	dtmNextJulianDate DATETIME NULL,										-- Next Julian Delivery Date
	dblSummerDailyRate NUMERIC(18,6) NULL,									-- Summer Daily Rate
	dblWinterDailyRate NUMERIC(18,6) NULL,									-- Winter Daily Rate
	dblBurnRate NUMERIC(18,6) NULL,											-- Burn Rate
	dblPreviousBurnRate NUMERIC(18,6) NULL,									-- Previous Burn Rate
	dblDDBetweenDelivery NUMERIC(18,6) NULL,								-- Degree Day Between Delivery
	ysnAdjBurnRate BIT NULL,												-- Adjust Burn Rate
	ysnPromptFull BIT NULL,													-- Prompt for % Full

	-- DEVICE
	--strDeviceType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Device Type
	--strDeviceOwnership NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Device Ownership
	
	--strDeviceLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	-- Device Location

	-- Tank Type
	--strTankType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,		-- Tank Type
	
	-- Asset Info
	--strDeviceSerialNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,-- Device Serial Number



	--strDeviceDesc NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,			-- Device Description
	--strDeviceInventoryStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--strDeviceComment NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	--strDeviceSerialInstalledTank NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--strDeviceRegulator NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--strDeviceLeaseNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--strDeviceOwnership NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--strManufacturerName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	--strModelNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	--ysnAppliance BIT NULL, 

)
