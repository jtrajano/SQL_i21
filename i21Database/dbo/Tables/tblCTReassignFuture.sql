CREATE TABLE [dbo].[tblCTReassignFuture]
(
	intReassignFutureId		INT IDENTITY (1, 1) NOT NULL,
    intReassignId			INT NOT NULL,
	intFutOptTransactionId	INT NOT NULL,
    intFutureMarketId		INT,
    intFutureMonthId		INT,
    intPriceUOMId			INT,
    dblPrice				NUMERIC(18,6),
    dblLot					NUMERIC(18,6),
    dblReassign				NUMERIC(18,6),
    strMarketName			NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strMonth				NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strInternalTradeNo		NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strTradeType			NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
    strPriceUOM				NVARCHAR (50)  COLLATE Latin1_General_CI_AS,
	intPriceFixationDetailId INT,
    intConcurrencyId		INT NOT NULL,
	intAssignFuturesToContractSummaryId INT,
    
    PRIMARY KEY CLUSTERED (intReassignFutureId ASC),
    CONSTRAINT [FK_tblCTReassignFuture_tblCTReassign_intReassignId] FOREIGN KEY (intReassignId) REFERENCES tblCTReassign(intReassignId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTReassignFuture_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTReassignFuture_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),    
	CONSTRAINT [FK_tblCTReassignFuture_tblICUnitMeasure_intPriceUOMId_intUnitMeasureId] FOREIGN KEY ([intPriceUOMId]) REFERENCES tblICUnitMeasure(intUnitMeasureId)
)
