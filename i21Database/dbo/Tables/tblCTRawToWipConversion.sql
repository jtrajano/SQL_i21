CREATE TABLE [dbo].[tblCTRawToWipConversion]
(
	[intRawToWipConversionId] INT NOT NULL IDENTITY, 
    [intBookId] INT NOT NULL, 
    [intSubBookId] INT NULL, 
    [intFuturesMarketId] INT NOT NULL, 
    [dblQuantityPerLot] NUMERIC(38, 20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
	
	CONSTRAINT [PK_tblCTRawToWipConversion_intRawToWipConversionId] PRIMARY KEY CLUSTERED (intRawToWipConversionId ASC), 
    CONSTRAINT [FK_tblCTRawToWipConversion_tblCTBook] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]), 
    CONSTRAINT [FK_tblCTRawToWipConversion_tblCTSubBook] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]), 
    CONSTRAINT [FK_tblCTRawToWipConversion_tblRKFutureMarket] FOREIGN KEY ([intFuturesMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])
)