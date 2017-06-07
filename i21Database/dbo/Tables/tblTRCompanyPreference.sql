CREATE TABLE [dbo].[tblTRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intItemForFreightId] INT NULL,
	[intSurchargeItemId] INT NULL,
	[intShipViaId] INT NULL,
	[intSellerId] INT NULL,
	[strRackPriceToUse] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnItemizeSurcharge] BIT NULL,		
	[intFreightCostAllocationMethod] INT NULL DEFAULT ((1)),
	[intRackPriceImportMappingId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC), 
    CONSTRAINT [FK_tblTRCompanyPreference_tblSMImportFileHeader] FOREIGN KEY ([intRackPriceImportMappingId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId]), 
    CONSTRAINT [FK_tblTRCompanyPreference_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia](intEntityId),
	CONSTRAINT [FK_tblTRCompanyPreference_Seller] FOREIGN KEY ([intSellerId]) REFERENCES [tblSMShipVia](intEntityId), 
    CONSTRAINT [FK_tblTRCompanyPreference_FreightItem] FOREIGN KEY ([intItemForFreightId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblTRCompanyPreference_SurchargeItem] FOREIGN KEY ([intSurchargeItemId]) REFERENCES [tblICItem]([intItemId])
)