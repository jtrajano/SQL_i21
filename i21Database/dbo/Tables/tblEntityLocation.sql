CREATE TABLE [dbo].[tblEntityLocation] (
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
    [intTaxCodeId]        INT            NULL,
    [intTermsId]          INT            NULL,
    [intWarehouseId]      INT            NULL,
	[ysnDefaultLocation]  BIT			 NULL,
	[intFreightTermId]	  INT            NULL,
	[intCountyTaxCodeId]        INT     NULL,
	[intTaxClassId]				INT		NULL,				
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblEntityLocation_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblEntityLocation] PRIMARY KEY CLUSTERED ([intEntityLocationId] ASC),
    CONSTRAINT [FK_dbo.tblEntityLocation_dbo.tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblEntityLocation_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblEntityLocation_dbo.tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [dbo].[tblSMFreightTerms] ([intFreightTermId]),
	CONSTRAINT [FK_tblEntityLocation_tblSMTaxCode_county] FOREIGN KEY([intCountyTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblEntityLocation_tblSMShipVia_intShipViaId] FOREIGN KEY([intShipViaId]) REFERENCES [dbo].[tblSMShipVia] ([intEntityShipViaId]),
	CONSTRAINT [FK_tblEntityLocation_tblSMTaxClass_intTaxClassId] FOREIGN KEY([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),

);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityLocation]([intEntityId] ASC);

