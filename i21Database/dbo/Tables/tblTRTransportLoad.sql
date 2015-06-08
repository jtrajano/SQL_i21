CREATE TABLE [dbo].[tblTRTransportLoad]
(
	[intTransportLoadId] INT NOT NULL IDENTITY,
	[strTransaction] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmLoadDateTime]  DATETIME        NOT NULL,
	[intShipViaId] INT NOT NULL,	
	[intSellerId] INT NOT NULL,	
	[intDriverId] INT NOT NULL,	
    [strTractor] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrailer] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRTransportLoad] PRIMARY KEY ([intTransportLoadId]),
	CONSTRAINT [FK_tblTRTransportLoad_tblSMShipVia_intShipViaId] FOREIGN KEY ([intShipViaId]) REFERENCES [dbo].[tblSMShipVia] ([intShipViaID]),
	CONSTRAINT [FK_tblTRTransportLoad_tblSMShipVia_intSellerId] FOREIGN KEY ([intSellerId]) REFERENCES [dbo].[tblSMShipVia] ([intShipViaID]),
	CONSTRAINT [FK_tblTRTransportLoad_tblARSalesperson_intDriverId] FOREIGN KEY ([intDriverId]) REFERENCES [dbo].[tblARSalesperson] ([intEntitySalespersonId])

)
