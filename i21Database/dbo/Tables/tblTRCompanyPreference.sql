CREATE TABLE [dbo].[tblTRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intItemForFreightId]   INT NULL,
	[intShipViaId]   INT NULL,
	[intSellerId]   INT NULL,
	[intTerminalId]   INT NULL,
	[intBulkPlantTypeId] INT NULL,
	[intXferAcctStatusId] INT NULL,
	[intCongsinmentId] INT NULL,
	[strRackPriceToUse] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnTaxesInXfer] BIT NULL, 
    [ysnAverageCostForNonBulkPlant] BIT NULL,
	[ysnAutoAssignInvoiceNumber] BIT NULL,
	[ysnSellerAsBillTo] BIT NULL,	
	[ysnItemizeSurcharge] BIT NULL,	
	[intSurchargeItemId] INT NULL,
	[intFreightCostAllocationMethod] INT NULL DEFAULT ((1)),
	[intRackPriceImportMappingId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC), 
    CONSTRAINT [FK_tblTRCompanyPreference_tblSMImportFileHeader] FOREIGN KEY ([intRackPriceImportMappingId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)