CREATE TABLE [dbo].[tblTRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intItemForFreightId]   int NULL,
	[intShipViaId]   int NULL,
	[intSellerId]   int NULL,
	[intTerminalId]   int NULL,
	[intBulkPlantTypeId] int NULL,
	[intXferAcctStatusId] int NULL,
	[intCongsinmentId] int NULL,
	[strRackPriceToUse] int NULL,
    [ysnTaxesInXfer] BIT NULL, 
    [ysnAverageCostForNonBulkPlant] BIT NULL,
	[ysnAutoAssignInvoiceNumber] BIT NULL,
	[ysnSellerAsBillTo] BIT NULL,	
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblTRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
)