CREATE TABLE [dbo].[tblSMShipVia] (
    [intShipViaID]       INT            IDENTITY (1, 1) NOT NULL,
    [strShipVia]         NVARCHAR (100) NOT NULL,
    [strShippingService] NVARCHAR (250) NOT NULL,
	[strName]			NVARCHAR (100) NULL,
	[strAddress]        NVARCHAR (250) NULL,
	[strCity]			NVARCHAR (100) NULL,
	[strState]			NVARCHAR (100) NULL,
	[strZipCode]        NVARCHAR (100) NULL,
	[strFederalId]			NVARCHAR (100) NULL,
	[strTransporterLicense] NVARCHAR (100) NULL,
	[strMotorCarrierIFTA]   NVARCHAR (100) NULL,
	[strTransportationMode] NVARCHAR (100) NULL,
	[ysnCompanyOwnedCarrier]BIT DEFAULT ((1)) NOT NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipVia] PRIMARY KEY CLUSTERED ([intShipViaID] ASC), 
    CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia])
);

