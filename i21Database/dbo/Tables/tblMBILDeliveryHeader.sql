CREATE TABLE [dbo].[tblMBILDeliveryHeader]
(
	[intDeliveryHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadId] [int] NOT NULL,
	[strLoadNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDeliveryNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intDriverEntityId] [int] NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[dtmDeliveryFrom] [datetime] null,
	[dtmDeliveryTo] [datetime] null,
	[dtmActualDelivery] [datetime] null,
	[intConcurrencyId] [int] DEFAULT(1) NULL,
 CONSTRAINT [PK_tblMBILDeliveryHeader] PRIMARY KEY CLUSTERED([intDeliveryHeaderId])
)