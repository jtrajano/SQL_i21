CREATE TABLE [dbo].[tblEMEntityLocation] (
    [intEntityLocationId]			INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]					INT            NOT NULL,
    [strLocationName]				NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCounty]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFax]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[strPricingLevel]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strNotes]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[strOregonFacilityNumber]		NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intShipViaId]					INT            NULL,
    [intTermsId]					INT            NULL,
    [intWarehouseId]				INT            NULL,
    [intSalespersonId]				INT            NULL,
	[ysnDefaultLocation]			BIT			   NULL,
	[intFreightTermId]				INT            NULL,
	[intCountyTaxCodeId]			INT            NULL,
	[intTaxGroupId]					INT			   NULL,
	[intTaxClassId]					INT			   NULL,
	[ysnActive]						BIT			   NOT NULL DEFAULT(1),
    [dblLongitude]					NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLatitude]					NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,	
    [strTimezone]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCheckPayeeName]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intDefaultCurrencyId]			INT NULL,
	[intVendorLinkId]				INT NULL,
	[strLocationDescription]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLocationType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL DEFAULT('Location'),

    --Start Farm Fields     
    [strFarmFieldNumber]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [strFarmFieldDescription]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFarmFSANumber]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFarmSplitNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,    
    [strFarmSplitType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblFarmAcres]					NUMERIC(18, 6)  DEFAULT ((0)) NULL,
	[imgFieldMapFile]				VARBINARY (MAX) NULL, 
	[strFieldMapFile]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL, 
    --End Farm Fields

	--Start 1099 Override
    [ysnPrint1099]					BIT             NULL,
    [str1099Name]					NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Form]					NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]					NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxId]				NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
    [dtmW9Signed]					DATETIME        NULL,
	--End 1099 Override

    --This will link the customer to a entity location
    [strOriginLinkCustomer]			NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL DEFAULT(''),
    [intConcurrencyId]				INT            CONSTRAINT [DF_tblEMEntityLocation_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	--New Fields
	[strLocationRoute]				NVARCHAR (1000)   COLLATE Latin1_General_CI_AS NULL,
	[dtmOperatingHoursStartTime]	DATETIME        NULL,
	[dtmOperatingHoursEndTime]      DATETIME        NULL,
	[strVATNo]						NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
	[strSaleUnits]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strOurFiscalRepName]			NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
	[strOurFiscalRepAddress]		NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
	[strRemarks]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,

    [guiApiUniqueId] UNIQUEIDENTIFIER NULL,
    --MCDG
    --Customer Linked Fields
    [strOrderType]                          NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL,
    [intDetailCompanyLocationId]            INT NULL,
    [intSalespersonId2]                     INT NULL,
	[ysnRequireStickReading]			    BIT NULL,
	[ysnRequirePump]			            BIT NULL,
    [ysnPrintPriceOnTicket]			        BIT NULL,
    [ysnRequirePO]			                BIT NULL,
    [ysnRequireSignature]	                BIT NULL,
    --SkyBitz Integration
    [intTicketCopies]						INT NOT NULL DEFAULT(0),
	[strUserDefined1]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined2]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined3]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined4]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[ysnPrintTotalizerOnTicket]				BIT, 
	[ysnDisplayTicketInInsight]				BIT, 
	[ysnDisplayPriceInInsight]				BIT, 
	[intAvgDeliveryTime]					INT NOT NULL DEFAULT(0),
	[intExcludeFromAvg]						INT NOT NULL DEFAULT(0),
	[intNumPrevOrderToAvg]					INT NOT NULL DEFAULT(0),
	-- [intAvgForDayOfWeek]					INT NOT NULL DEFAULT(0),
	[intFuelingRadius]						INT NULL,
    [intTerritoryId]                        INT NULL,
    --End SkyBitz Integration
    --Default Item
    [intItemId]								INT NULL,
	[intEstimatedUnits]						INT NULL,
	[intMonthstoUseForAvg]					INT NULL,
	-- [strOrderToUseForAvg]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strAvgForDayOfWeek]					NVARCHAR(50) COLLATE Latin1_General_CI_AS DEFAULT('All') NOT NULL, 
    --Default Item

    [strRecurringPONumber]                   NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL,


    [intRowNumber] INT NULL,
    CONSTRAINT [PK_dbo.tblEMEntityLocation] PRIMARY KEY CLUSTERED ([intEntityLocationId] ASC),
    CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [dbo].[tblSMFreightTerms] ([intFreightTermId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblARSalesperson_intSalespersonId] FOREIGN KEY ([intSalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxCode_county] FOREIGN KEY([intCountyTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMShipVia_intShipViaId] FOREIGN KEY([intShipViaId]) REFERENCES [dbo].[tblSMShipVia] ([intEntityId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [UK_tblEMEntityLocation_strLocationName_intEntityId] UNIQUE NONCLUSTERED ([strLocationName] ASC, [intEntityId] ASC)	,
	CONSTRAINT [FK_tblEMEntityLocation_intCurrencyId] FOREIGN KEY ([intDefaultCurrencyId]) REFERENCES tblSMCurrency([intCurrencyID]),
    CONSTRAINT [FK_tblEMEntityLocation_tblEMEntity_intVendorLinkId] FOREIGN KEY ([intVendorLinkId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [UK_tblEMEntityLocation_strLocationName_strFieldNumber] UNIQUE NONCLUSTERED ([strLocationName] ASC, [strFarmFieldNumber] ASC,[intEntityId] ASC), 
    CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxGroup] FOREIGN KEY (intTaxGroupId) REFERENCES tblSMTaxGroup(intTaxGroupId),
    
	CONSTRAINT [FK_tblEMEntityLocation_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])

);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEMEntityLocation]([intEntityId] ASC);

	
GO
CREATE NONCLUSTERED INDEX [IX_tblEMEntityLocation_intEntityId_ysnDefaultLocation] ON [dbo].[tblEMEntityLocation] ([intEntityId], [ysnDefaultLocation])

