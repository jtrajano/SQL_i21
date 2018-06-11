CREATE TABLE [dbo].[tblSMShipVia] (
    [intEntityId]       INT            NOT NULL,
	[strShipViaOriginKey]      NVARCHAR (10) COLLATE Latin1_General_CI_AS  NULL,
    [strShipVia]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strShippingService] NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strName]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strAddress]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
	[strCity]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strState]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strFederalId]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strTransporterLicense] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strMotorCarrierIFTA]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strTransportationMode] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[ysnCompanyOwnedCarrier] BIT DEFAULT ((1)) NOT NULL,
	[strFreightBilledBy] NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipVia] PRIMARY KEY CLUSTERED ([intEntityId] ASC), 
    CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia]),
	CONSTRAINT [FK_dbo_tblSMShipVia_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,

);


GO
