CREATE TABLE [dbo].[tblCTReassignPricing]
(
	intReassignPricingId	INT IDENTITY (1, 1) NOT NULL,
    intReassignId			INT NOT NULL,
   intPriceFixationDetailId INT NOT NULL,
    intFutureMarketId		INT,
    intFutureMonthId		INT,
    intPriceUOMId			INT,
    dblPrice				NUMERIC(18,6),
    dblLot					NUMERIC(18,6),
    dblReassign				NUMERIC(18,6),
    strMarketName			NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strMonth				NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strTradeNo				NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strPriceUOM				NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    intConcurrencyId		INT NOT NULL,
    
    PRIMARY KEY CLUSTERED (intReassignPricingId ASC),
    CONSTRAINT [FK_tblCTReassignPricing_tblCTReassign_intReassignId] FOREIGN KEY (intReassignId) REFERENCES tblCTReassign(intReassignId) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCTReassignPricing_tblCTPriceFixationDetail_intPriceFixationDetailId] FOREIGN KEY (intPriceFixationDetailId) REFERENCES [tblCTPriceFixationDetail](intPriceFixationDetailId),
	CONSTRAINT [FK_tblCTReassignPricing_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTReassignPricing_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),    
	CONSTRAINT [FK_tblCTReassignPricing_tblICItemUOM_intPriceUOMId_intItemUOMId] FOREIGN KEY ([intPriceUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
