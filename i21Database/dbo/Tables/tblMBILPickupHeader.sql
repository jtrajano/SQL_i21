CREATE TABLE [dbo].[tblMBILPickupHeader](
	[intPickupHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadHeaderId] [int] NOT NULL,
	[intSellerId] [int] NULL,
	[intSalespersonId] [int] NULL,
	[strTerminalRefNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[dtmPickupFrom] [datetime] NULL,
	[dtmPickupTo] [datetime] NULL,
	[strPONumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strBOL] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strNote] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[ysnPickup] bit default 0 NULL,
	[intConcurrencyId] [int] DEFAULT(1) NULL,
 CONSTRAINT [PK_tblMBILPickupHeader] PRIMARY KEY CLUSTERED ([intPickupHeaderId] ASC),
 CONSTRAINT [FK_tblMBILPickupHeader_tblMBILLoadHeader] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [tblMBILLoadHeader]([intLoadHeaderId])
)



