CREATE TABLE [dbo].[tblMBILPickupHeader](
	[intPickupHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadId] [int] NOT NULL,
	[strLoadNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intSellerId] [int] NULL,
	[intSalespersonId] [int] NULL,
	[strTerminalRefNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intDriverEntityId] [int] NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[dtmPickupFrom] [datetime] NULL,
	[dtmPickupTo] [datetime] NULL,
	[strPONumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strBOL] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strNote] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[ysnPickup] bit default 0,
	[intConcurrencyId] [int] NULL
 CONSTRAINT [PK_tblMBILPickupHeader] PRIMARY KEY CLUSTERED ([intPickupHeaderId] ASC)
)


