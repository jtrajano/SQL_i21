CREATE TABLE [dbo].[tblTRLoadHeader]
(
	[intLoadHeaderId] INT NOT NULL IDENTITY,
	[intLoadId] INT NULL,
	[strTransaction] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmLoadDateTime]  DATETIME        NOT NULL,
	[intShipViaId] INT NOT NULL,	
	[intSellerId] INT NOT NULL,	
	[intDriverId] INT NOT NULL,	
    [strTractor] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrailer] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnPosted]  BIT  DEFAULT ((0)) NOT NULL,
	[ysnDiversion]  BIT  NULL,
	[strDiversionNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intStateId] INT NULL,	
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRLoadHeader] PRIMARY KEY ([intLoadHeaderId]),
	CONSTRAINT [FK_tblTRLoadHeader_tblSMShipVia_intShipViaId] FOREIGN KEY ([intShipViaId]) REFERENCES [dbo].[tblSMShipVia] (intEntityId),
	CONSTRAINT [FK_tblTRLoadHeader_tblSMShipVia_intSellerId] FOREIGN KEY ([intSellerId]) REFERENCES [dbo].[tblSMShipVia] (intEntityId),
	CONSTRAINT [FK_tblTRLoadHeader_tblARSalesperson_intDriverId] FOREIGN KEY ([intDriverId]) REFERENCES [dbo].[tblARSalesperson] (intEntityId),
	CONSTRAINT [FK_tblTRLoadHeader_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [dbo].[tblLGLoad] ([intLoadId]),
	CONSTRAINT [FK_tblTRLoadHeader_tblTRState_intStateId] FOREIGN KEY ([intStateId]) REFERENCES [dbo].[tblTRState] ([intStateId])

)
