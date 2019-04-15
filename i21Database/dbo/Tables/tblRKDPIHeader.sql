CREATE TABLE [dbo].[tblRKDPIHeader]
(
	[intDPIHeaderId] INT IDENTITY NOT NULL, 
    [imgReportId] UNIQUEIDENTIFIER NOT NULL, 
    [strPositionIncludes] NVARCHAR(50) NULL, 
    [dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [intCommodityId] INT NULL, 
    [intItemId] INT NULL, 
    [intLocationId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPIHeader] PRIMARY KEY ([intDPIHeaderId])
)