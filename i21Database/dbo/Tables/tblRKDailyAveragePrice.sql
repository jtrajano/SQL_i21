CREATE TABLE [dbo].[tblRKDailyAveragePrice]
(
	[intDailyAveragePriceId] INT NOT NULL IDENTITY, 
    [strAverageNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmDate] DATETIME NOT NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT((0)),
    [intConcurrencyId] INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblRKDailyAveragePrice] PRIMARY KEY ([intDailyAveragePriceId]), 
    CONSTRAINT [FK_tblRKDailyAveragePrice_tblCTBook] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]), 
    CONSTRAINT [FK_tblRKDailyAveragePrice_tblCTSubBook] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId])
)
