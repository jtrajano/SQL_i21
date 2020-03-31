CREATE TABLE [dbo].[tblRKM2MUnrealized]
(
	[intM2MUnrealizedId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL
	, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractTypeId INT
	, intContractHeaderId INT
	, strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFreightTermId INT
	, intTransactionType INT
	, strTransaction NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intContractDetailId INT
	, intCurrencyId INT
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFutureMarketUOMId INT
	, intFutureMarketUnitMeasureId INT
	, strFutureMarketUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intMarketCurrencyId INT
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, intBookId INT
	, strBook NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strSubBook NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodity NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmReceiptDate DATETIME		
	, dtmContractDate DATETIME
	, strContract NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractSeq INT
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInternalCompany NVARCHAR(20) COLLATE Latin1_General_CI_AS
	, dblQuantity NUMERIC(38, 20)
	, intQuantityUOMId INT
	, intQuantityUnitMeasureId INT
	, strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblWeight NUMERIC(38, 20)
	, intWeightUOMId INT
	, intWeightUnitMeasureId INT
	, strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblBasis NUMERIC(38, 20)
	, intBasisUOMId INT
	, intBasisUnitMeasureId INT
	, strBasisUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblFutures NUMERIC(38, 20)
	, dblCashPrice NUMERIC(38, 20)
	, intPriceUOMId INT
	, intPriceUnitMeasureId INT
	, strContractPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intOriginId INT
	, strOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCropYear NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strProductionLine NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strCertification NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS	
	, strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmStartDate DATETIME
	, dtmEndDate DATETIME
	, strBLNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmBLDate DATETIME
	, strAllocationRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAllocationStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPriceTerms NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblContractDifferential NUMERIC(38, 20)
	, strContractDifferentialUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblFuturesPrice NUMERIC(38, 20)
	, strFuturesPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strFixationDetails NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblFixedLots NUMERIC(38, 20)
	, dblUnFixedLots NUMERIC(38, 20)
	, dblContractInvoiceValue NUMERIC(38, 20)
	, dblSecondaryCosts NUMERIC(38, 20)
	, dblCOGSOrNetSaleValue NUMERIC(38, 20)
	, dblInvoicePrice NUMERIC(38, 20)
	, dblInvoicePaymentPrice NUMERIC(38, 20)
	, strInvoicePriceUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblInvoiceValue NUMERIC(38, 20)
	, strInvoiceCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblNetMarketValue NUMERIC(38, 20)
	, dtmRealizedDate DATETIME
	, dblRealizedQty NUMERIC(38, 20)
	, dblProfitOrLossValue NUMERIC(38, 20)
	, dblPAndLinMarketUOM NUMERIC(38, 20)
	, dblPAndLChangeinMarketUOM NUMERIC(38, 20)
	, strMarketCurrencyUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strTrader NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFixedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strWarehouse NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCPAddress NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCPCountry NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCPRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intContractStatusId INT
	, intPricingTypeId INT
	, strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPricingStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblMarketDifferential NUMERIC(38, 20)
	, dblNetM2MPrice NUMERIC(38, 20)
	, dblSettlementPrice NUMERIC(38, 20)
	, intCompanyId INT
	, strCompanyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
    , [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MUnrealized] PRIMARY KEY ([intM2MUnrealizedId]), 
    CONSTRAINT [FK_tblRKM2MUnrealized_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE
)
