CREATE TABLE [dbo].[tblCTSequenceHistory]
(
	intSequenceHistoryId	  INT IDENTITY(1,1) NOT NULL,
	dtmHistoryCreated		  DATETIME,
    intContractHeaderId		  INT,
    intContractDetailId		  INT,
    intContractTypeId		  INT,
    intCommodityId			  INT,
    intEntityId			      INT,
    intContractStatusId		  INT,
    intCompanyLocationId	  INT,
    intItemId				  INT,
    intPricingTypeId		  INT,
    intFutureMarketId		  INT,
    intFutureMonthId		  INT,
    intCurrencyId			  INT,
    intDtlQtyInCommodityUOMId INT,
    intDtlQtyUnitMeasureId	  INT,
    intCurrencyExchangeRateId INT,
	intBookId				  INT,
	intSubBookId			  INT,	

    dtmStartDate			  DATETIME,
    dtmEndDate				  DATETIME,
    dblQuantity				  NUMERIC(18,6),
    dblBalance				  NUMERIC(18,6),
	dblScheduleQty			  NUMERIC(18,6),
    dblFutures				  NUMERIC(18,6),
    dblBasis				  NUMERIC(18,6),	
	dblCashPrice			  NUMERIC(18,6),
    dblLotsPriced			  NUMERIC(18,6),	 
    dblLotsUnpriced			  NUMERIC(18,6),
    dblQtyPriced			  NUMERIC(18,6),
    dblQtyUnpriced			  NUMERIC(18,6),
    dblFinalPrice			  NUMERIC(18,6),
	dblRatio				  NUMERIC(18,6),

    dtmFXValidFrom			  DATETIME,
    dtmFXValidTo			  DATETIME,
    dblRate					  NUMERIC(18,6),

    strCommodity			  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    strContractNumber		  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    intContractSeq			  INT,
    strLocation				  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    strContractType			  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    strPricingType			  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    strPricingStatus		  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    strCurrencypair			  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strBook					  NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strSubBook			      NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	
	intContractBasisId       INT,
	intGradeId				 INT,
	intItemUOMId			 INT,
	intPositionId			 INT,
	intPriceItemUOMId        INT,
	intTermId				 INT,
	intWeightId				 INT,
	intUserId				 INT,
	strAmendmentComment		 NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
    intConcurrencyId		 INT,

	dblOldQuantity			NUMERIC(18,6),
	dblOldBalance			NUMERIC(18,6),
	intOldStatusId			INT,
	ysnQtyChange			BIT,
	ysnStatusChange			BIT,
	ysnBalanceChange		BIT,

	dblOldFutures			NUMERIC(18,6),
	dblOldBasis				NUMERIC(18,6),
	dblOldCashPrice			NUMERIC(18,6),
	ysnFuturesChange		BIT,
	ysnBasisChange			BIT,
	ysnCashPriceChange		BIT,
	intSequenceUsageHistoryId	INT,
	dtmDateAdded			DATETIME NULL,
    intFreightTermId        INT,
    intGardenMarkId        INT,
    intReasonCodeId        INT,
    ysnSummaryLog			BIT not null default 1,

    CONSTRAINT [PK_tblCTSequenceHistory_intSequenceHistoryId] PRIMARY KEY CLUSTERED (intSequenceHistoryId ASC)--,
    -- CONSTRAINT [FK_tblCTSequenceHistory_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId) ON DELETE CASCADE
)

GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceHistory]
	ON [dbo].[tblCTSequenceHistory]([intContractHeaderId] ASC, intContractDetailId ASC)
	
GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceHistory_intSequenceUsageHistoryId] ON [dbo].[tblCTSequenceHistory] ([intSequenceUsageHistoryId])

GO

CREATE NONCLUSTERED INDEX [IX_tblCTSequenceHistory_intContractDetailId] ON [dbo].[tblCTSequenceHistory] ([intContractDetailId])

GO