CREATE TABLE [dbo].[tblTMDeliveryUpdate]
(
	[intDeliveryUpdateId] INT IDENTITY (1, 1) NOT NULL,
	[intSiteId] INT NOT NULL,
	[intDispatchId] INT NULL,
	[strSource] NVARCHAR(50) NULL,
	[dtmDeliveryDate] DATETIME NULL,
	[dblDeliveryQuantity] DECIMAL(18, 6) NULL,
	[dblDeliveryPrice] DECIMAL(18, 6) NULL,
	[dblDeliveryTotal] DECIMAL(18, 6) NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	CONSTRAINT [PK_tblTMDeliveryUpdate] PRIMARY KEY CLUSTERED ([intDeliveryUpdateId] ASC),
	CONSTRAINT [FK_tblTMDeliveryUpdate_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
)
