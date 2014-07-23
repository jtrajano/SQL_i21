CREATE TABLE [dbo].[tblSMShipVia] (
    [intShipViaID]       INT            IDENTITY (1, 1) NOT NULL,
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
	[ysnCompanyOwnedCarrier]BIT DEFAULT ((1)) NOT NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipVia] PRIMARY KEY CLUSTERED ([intShipViaID] ASC), 
    CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia])
);

