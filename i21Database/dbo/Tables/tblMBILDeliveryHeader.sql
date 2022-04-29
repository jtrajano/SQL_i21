CREATE TABLE [dbo].[tblMBILDeliveryHeader]
(
	[intDeliveryHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadHeaderId] [int] NOT NULL,
	[strDeliveryNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[intSalesPersonId] [int] null,
	[dtmDeliveryFrom] [datetime] null,
	[dtmDeliveryTo] [datetime] null,
	[dtmActualDelivery] [datetime] null,
	[intConcurrencyId] [int] DEFAULT(1) NULL,
 CONSTRAINT [PK_tblMBILDeliveryHeader] PRIMARY KEY CLUSTERED([intDeliveryHeaderId]),
 CONSTRAINT [FK_tblMBILDeliveryHeader_tblMBILLoadHeader] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [tblMBILLoadHeader]([intLoadHeaderId])
)