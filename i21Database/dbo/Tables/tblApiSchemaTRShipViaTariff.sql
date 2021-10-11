CREATE TABLE [dbo].[tblApiSchemaTRShipViaTariff]
(
	guiApiUniqueId              UNIQUEIDENTIFIER NOT NULL,
    intRowNumber                INT NULL,
    intKey                      INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	
	strShipViaName				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	-- Ship Via Name			| Required
	strTariffDescription		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		-- Tariff Description		| Required
	strTariffType				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	-- Tariff Type				| Required
	strFreightType				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		-- Freight Type				| Required
	strCategory					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			-- Category					| Optional
	dblSurcharge				NUMERIC(18, 6) NULL,									-- Surcharge Rate			| Optional
	dtmShipViaEffectiveDate		DATETIME NOT NULL,										-- Ship Via Effective Date	| Required
	dtmSurchargeEffectiveDate	DATETIME NULL,											-- Surcharge Effective Date	| Optional
	intFromMile					INT NULL,												-- From Miles				| Optional
	intToMile					INT NULL,												-- To Miles					| Optional
	dblCostRatePerUnit			NUMERIC(18, 6) NULL DEFAULT ((0)),						-- Cost Per Unit			| Optional
	dblInvoiceRatePerUnit		NUMERIC(18, 6) NULL DEFAULT ((0))						-- Invoice Per Unit			| Optional
)