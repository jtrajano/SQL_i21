CREATE TABLE [dbo].[tblSMShipVia] (
    [intShipViaID]       INT            IDENTITY (1, 1) NOT NULL,
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
	[ysnCompanyOwnedCarrier]BIT DEFAULT ((1)) NOT NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipVia] PRIMARY KEY CLUSTERED ([intShipViaID] ASC), 
    CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'intShipViaID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Via Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strShipVia'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shipping Service',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strShippingService'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip or Postal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Federal Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strFederalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transporter License',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strTransporterLicense'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motor Carrier IFTA',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strMotorCarrierIFTA'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Transportation Mode',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'strTransportationMode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Owned Carrier',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'ysnCompanyOwnedCarrier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Via is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMShipVia',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'