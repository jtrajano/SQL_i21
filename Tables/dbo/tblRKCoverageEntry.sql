CREATE TABLE [dbo].[tblRKCoverageEntry]
(
	[intCoverageEntryId] INT IDENTITY NOT NULL, 
    [strBatchName] NVARCHAR(50) NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intUOMId] INT NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
    [intCommodityId] INT NULL, 
    [strUOMType] NVARCHAR(50) NULL, 
    [intDecimal] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT ((0)),
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblRKCoverageEntry] PRIMARY KEY ([intCoverageEntryId]) 
)
