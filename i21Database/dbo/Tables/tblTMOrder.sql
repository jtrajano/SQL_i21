CREATE TABLE [dbo].[tblTMOrder]
(
	[intOrderId] INT IDENTITY(1,1) NOT NULL,
	[intDispatchId] INT NOT NULL,
	[intSiteId] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[strOrderNumber] NVARCHAR(100) NOT NULL,
	[strPricingMethod] NVARCHAR(100) NOT NULL,
	[intContractDetailId] INT NULL,
	[dblQuantity] NUMERIC(18,6) NULL,
	[dblPrice] NUMERIC(18,6) NULL,
	[dblTotal] NUMERIC(18,6) NULL,
	[strSource] NVARCHAR(100) NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[ysnOverage] BIT NULL,
	CONSTRAINT [PK_tblTMOrder] PRIMARY KEY CLUSTERED ([intOrderId] ASC),
	CONSTRAINT [FK_tblTMOrder_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
)

