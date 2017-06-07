CREATE TABLE [dbo].[tblEMEntityLocation] (
    [intEntityLocationId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strLocationName]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]              NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[strPricingLevel]     NVARCHAR (2)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intShipViaId]        INT            NULL,
    [intTermsId]          INT            NULL,
    [intWarehouseId]      INT            NULL,
	[ysnDefaultLocation]  BIT			 NULL,
	[intFreightTermId]	  INT            NULL,
	[intCountyTaxCodeId]        INT            NULL,
	[intTaxGroupId]			INT				NULL,
	[intTaxClassId]			INT				NULL,
	[ysnActive]				BIT			 NOT NULL DEFAULT(1),
    [dblLongitude]          NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLatitude]          NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,	
    [strTimezone]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strCheckPayeeName]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblEMEntityLocation_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblEMEntityLocation] PRIMARY KEY CLUSTERED ([intEntityLocationId] ASC),
    CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblEMEntityLocation_dbo.tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [dbo].[tblSMFreightTerms] ([intFreightTermId]),
	--CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxCode_taxCode] FOREIGN KEY([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxCode_county] FOREIGN KEY([intCountyTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMShipVia_intShipViaId] FOREIGN KEY([intShipViaId]) REFERENCES [dbo].[tblSMShipVia] ([intEntityId]),
	CONSTRAINT [FK_tblEMEntityLocation_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [UK_tblEMEntityLocation_strLocationName_intEntityId] UNIQUE NONCLUSTERED ([strLocationName] ASC, [intEntityId] ASC)	

);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEMEntityLocation]([intEntityId] ASC);

	
GO
CREATE NONCLUSTERED INDEX [IX_tblEMEntityLocation_intEntityId_ysnDefaultLocation] ON [dbo].[tblEMEntityLocation] ([intEntityId], [ysnDefaultLocation])

