CREATE TABLE [dbo].[tblMBILDeliveryHeader]
(
	[intDeliveryHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadId] [int] NOT NULL,
	[strLoadNumber] [nvarchar](100) NULL,
	[strDeliveryNumber] [nvarchar](100) NULL,
	[intDriverEntityId] [int] NOT NULL,
	[strType] [nvarchar](100) NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[dtmDeliveryFrom] [datetime] null,
	[dtmDeliveryTo] [datetime] null,
	[dtmActualDelivery] [datetime] null,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblMBILDeliveryHeader] PRIMARY KEY CLUSTERED([intDeliveryHeaderId])
)