CREATE TABLE [dbo].[tblRKDPRHeader]
(
	[intDPRHeaderId] INT IDENTITY NOT NULL, 
    [imgReportId] UNIQUEIDENTIFIER NOT NULL, 
    [strPositionIncludes] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strPositionBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmEndDate] DATETIME NULL, 
	[ysnVendorCustomerPosition] BIT NULL DEFAULT((0)),
	[strPurchaseSale] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] INT NULL,
    [intCommodityId] INT NULL, 
    [intItemId] INT NULL, 
    [intLocationId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRHeader] PRIMARY KEY ([intDPRHeaderId])
)