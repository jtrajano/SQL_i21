CREATE TABLE [dbo].[tblSMShipVia] (
    [intShipViaID]       INT            IDENTITY (1, 1) NOT NULL,
    [strShipVia]         NVARCHAR (100) NOT NULL,
    [strShippingService] NVARCHAR (250) NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    CONSTRAINT [PK_tblSMShipVia] PRIMARY KEY CLUSTERED ([intShipViaID] ASC)
);

