CREATE TABLE [dbo].[tblApiSchemaTRCustomerFreight]
(
	[intCustomerFreightId] INT NOT NULL IDENTITY,
	[guiApiUniqueId] UNIQUEIDENTIFIER NOT NULL,
	[intRowNumber] INT NULL,
	--[strCustomerName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,				-- Customer Name
	[strCustomerEntityNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,		-- Customer Entity No
	[strTariffType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,			-- Tariff Type
	[strCustomerLocation] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,		-- Customer Location
	[strSupplierZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			-- Supplier Zip Code
	[strCategory] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,				-- Category
	[ysnFreightOnly] BIT NULL,														-- Freight Only [1 or 0]
	[strFreightType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,			-- Freight Type
	[strShipViaName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,				-- Ship Via Name
	[dblFreightAmount] NUMERIC(18,6) NULL,											-- Freight Amount [Format: #,##0.##]
	[dblFreightRate] NUMERIC(18,6) NULL,											-- Freight Rate [Format: #,##0.######]
	[dblFreightMile] NUMERIC(18,6) NULL,											-- Freight Mile [Format: #,##0.######]
	[ysnFreightInPrice] BIT NULL,													-- Freight In Price [1 or 0]
	[dblMinimumUnit] NUMERIC(18,6) NULL,											-- Minimum Unit [Format: #,##0.######]
	CONSTRAINT [PK_tblApiSchemaTRCustomerFreight] PRIMARY KEY ([intCustomerFreightId])
)
