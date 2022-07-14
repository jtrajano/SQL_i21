﻿CREATE TABLE [dbo].[tblTRCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intItemForFreightId] INT NULL,
	[intSurchargeItemId] INT NULL,
	[intShipViaId] INT NULL,
	[intSellerId] INT NULL,
	[strRackPriceToUse] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Vendor'),
    [ysnItemizeSurcharge] BIT NULL,		
	[intFreightCostAllocationMethod] INT NULL DEFAULT ((3)),
	[intRackPriceImportMappingId] INT NULL,
    [ysnImportSupplyPoint] BIT NULL default convert(bit,0),
    [ysnImportTrucks] BIT NULL default convert(bit,0),
	[intBolImportFormatId] INT NULL,
	[intRackPriceImportFormatId] INT NULL,
	[strBolImportReceivingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strBolImportProcessingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strBolImportArchiveFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strBolImageImportReceivingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strBolImageImportProcessingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strRackPriceImportReceivingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strRackPriceImportProcessingFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strRackPriceImportArchiveFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	[ysnFreightInRequired] BIT NULL,	
	[ysnComboFreight] BIT NULL,
	[ysnAllowDifferentUnits] BIT NULL,
	[strDtnImportProcessFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strDtnImportArchiveFolder] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblTRCompanyPreference_intCompanyPreferenceId] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC), 
    CONSTRAINT [FK_tblTRCompanyPreference_tblSMImportFileHeader] FOREIGN KEY ([intRackPriceImportMappingId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId]), 
    CONSTRAINT [FK_tblTRCompanyPreference_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia](intEntityId),
	CONSTRAINT [FK_tblTRCompanyPreference_Seller] FOREIGN KEY ([intSellerId]) REFERENCES [tblSMShipVia](intEntityId), 
    CONSTRAINT [FK_tblTRCompanyPreference_FreightItem] FOREIGN KEY ([intItemForFreightId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblTRCompanyPreference_SurchargeItem] FOREIGN KEY ([intSurchargeItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblTRCompanyPreference_tblSMImportFileHeader_BolFormat] FOREIGN KEY ([intBolImportFormatId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId]), 
	CONSTRAINT [FK_tblTRCompanyPreference_tblSMImportFileHeader_RackPriceFormat] FOREIGN KEY ([intRackPriceImportFormatId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)