﻿CREATE TABLE [dbo].[tblCTSequenceHistory]
(
	intSequenceHistoryId	  INT IDENTITY(1,1) NOT NULL,
    intContractHeaderId		  INT,
    intContractDetailId		  INT,
    intContractTypeId		  INT,
    intCommodityId			  INT,
    intEntityId			      INT,
    intContractStatusId		  INT,
    intCompanyLocationId	  INT,
    inItemId				  INT,
    intPricingTypeId		  INT,
    intFutureMarketId		  INT,
    intFutureMonthId		  INT,
    intCurrencyId			  INT,
    intDtlQtyInCommodityUOMId INT,
    intDtlQtyUnitMeasureId	  INT,
    intCurrencyExchangeRateId INT,

    dtmStartDate			  DATETIME,
    dtmEndDate				  DATETIME,
    dblQuantity				  NUMERIC(18,6),
    dblBalance				  NUMERIC(18,6),
    dblFutures				  NUMERIC(18,6),
    dblBasis				  NUMERIC(18,6),	
    dblLotsPriced			  NUMERIC(18,6),	 
    dblLotsUnpriced			  NUMERIC(18,6),
    dblQtyPriced			  NUMERIC(18,6),
    dblQtyUnpriced			  NUMERIC(18,6),
    dblFinalPrice			  NUMERIC(18,6),

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

    intConcurrencyId		  INT,

    CONSTRAINT [PK_tblCTSequenceHistory_intSequenceHistoryId] PRIMARY KEY CLUSTERED (intSequenceHistoryId ASC),
    CONSTRAINT [FK_tblCTSequenceHistory_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId) ON DELETE CASCADE
)