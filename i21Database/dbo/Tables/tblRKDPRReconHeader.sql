CREATE TABLE [dbo].[tblRKDPRReconHeader]
(
	[intDPRReconHeaderId] INT IDENTITY NOT NULL, 
    [dtmFromDate] DATETIME NULL, 
    [dtmToDate] DATETIME NULL, 
    [intCommodityId] INT NULL, 
    [intUserId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRReconHeader] PRIMARY KEY ([intDPRReconHeaderId])
)