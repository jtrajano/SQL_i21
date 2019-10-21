CREATE TABLE [dbo].[tblRKCoverageEntryDetail]
(
	[intCoverageEntryDetailId] INT IDENTITY NOT NULL, 
    [intCoverageEntryId] INT NOT NULL, 
    [intProductTypeId] INT NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
    [dblOpenContract] NUMERIC(18, 6) NULL, 
    [dblInTransit] NUMERIC(18, 6) NULL, 
    [dblStock] NUMERIC(18, 6) NULL, 
    [dblOpenFutures] NUMERIC(18, 6) NULL, 
    [intMonthsCovered] INT NULL, 
    [dblAveragePrice] NUMERIC(18, 6) NULL, 
    [dblOptionsCovered] NUMERIC(18, 6) NULL, 
    [dblFuturesM2M] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblRKCoverageEntryDetail] PRIMARY KEY ([intCoverageEntryDetailId]), 
    CONSTRAINT [FK_tblRKCoverageEntryDetail_tblRKCoverageEntry] FOREIGN KEY ([intCoverageEntryId]) REFERENCES [tblRKCoverageEntry]([intCoverageEntryId]) ON DELETE CASCADE
)
