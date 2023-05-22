CREATE TABLE [dbo].[tblRKAllocatedContractsTransaction]
(
	  intAllocatedContractsTransactionId INT NOT NULL IDENTITY
    , intAllocatedContractsGainOrLossHeaderId INT NOT NULL 
	, strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strTransactionReferenceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, strPurchaseContract  NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchaseCounterparty NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intPurchaseFutureMarketId INT
	, strPurchaseFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intPurchaseFutureMonthId INT
	, strPurchaseLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchaseOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblPurchaseAllocatedQtyDisplay NUMERIC(24,6)
	, dblPurchaseAllocatedQty NUMERIC(24,6)
	, strPurchaseCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchasePosition NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchasePeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strPurchaseEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmPurchasePlannedAvailabilityDate DATETIME
	, strPurchasePriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strPurchasePricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblPurchaseContractBasis NUMERIC(24,6)
	, strPurchaseInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblPurchaseContractRatio NUMERIC(24,6)
	, dblPurchaseContractFutures NUMERIC(24,6)
	, dblPurchaseContractCash NUMERIC(24,6)
	, dblPurchaseContractCosts NUMERIC(24,6)
	, dblPurchaseValue NUMERIC(24,6)
	, intPurchaseQuantityUnitMeasureId INT
	, intPurchaseContractDetailId INT
	, intPurchaseContractHeaderId INT
	, intPurchaseContractTypeId INT
	, intPurchaseFreightTermId INT
	, intPurchaseCommodityId INT
	, intPurchaseItemId INT
	, intPurchaseCompanyLocationId INT
	, intPurchaseMarketZoneId INT
	, intPurchaseOriginPortId INT
	, intPurchaseDestinationPortId INT
	, intPurchaseCropYearId INT
	, intPurchaseStorageLocationId INT
	, intPurchaseStorageUnitId INT
	, intPurchaseMTMPointId INT
	, strPurchaseMTMPoint NVARCHAR(300) COLLATE Latin1_General_CI_AS
	, strPurchaseCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strSalesContract  NVARCHAR(50)
	, strSalesCounterparty NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSalesFutureMarketId INT
	, strSalesFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intSalesFutureMonthId INT
	, strSalesLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesMarketZoneCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strSalesOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblSalesAllocatedQtyDisplay NUMERIC(24,6)
	, dblSalesAllocatedQty NUMERIC(24,6)
	, strSalesCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesOrigin NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesProductLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesClass NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesSeason NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesRegion NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesGrade NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesPosition NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strSalesEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmSalesPlannedAvailabilityDate DATETIME
	, strSalesPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strSalesPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblSalesContractBasis NUMERIC(24,6)
	, strSalesInvoiceStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblSalesContractRatio NUMERIC(24,6)
	, dblSalesContractFutures NUMERIC(24,6)
	, dblSalesContractCash NUMERIC(24,6)
	, dblSalesContractCosts NUMERIC(24,6)
	, dblSalesValue NUMERIC(24,6)
	, intSalesQuantityUnitMeasureId INT
	, intSalesContractDetailId INT
	, intSalesContractHeaderId INT
	, intSalesContractTypeId INT
	, intSalesFreightTermId INT
	, intSalesCommodityId INT
	, intSalesItemId INT
	, intSalesCompanyLocationId INT
	, intSalesMarketZoneId INT
	, intSalesOriginPortId INT
	, intSalesDestinationPortId INT
	, intSalesCropYearId INT
	, intSalesStorageLocationId INT
	, intSalesStorageUnitId INT
	, intSalesMTMPointId INT
	, strSalesMTMPoint NVARCHAR(300) COLLATE Latin1_General_CI_AS
	, strSalesCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, dblMatchedPnL NUMERIC(24,6)
	, dblContractFXRate NUMERIC(24,6)
	, intTransactionCurrencyId INT NULL
    , intConcurrencyId INT NULL DEFAULT ((1)) 
    CONSTRAINT [PK_tblRKAllocatedContractsTransaction] PRIMARY KEY ([intAllocatedContractsTransactionId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblRKAllocatedContractsGainOrLossHeader] FOREIGN KEY ([intAllocatedContractsGainOrLossHeaderId]) REFERENCES [tblRKAllocatedContractsGainOrLossHeader]([intAllocatedContractsGainOrLossHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblRKFutureMarket_Purchase] FOREIGN KEY ([intPurchaseFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICCommodity_Purchase] FOREIGN KEY ([intPurchaseCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblRKFuturesMonth_Purchase] FOREIGN KEY ([intPurchaseFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCompanyLocation_Purchase] FOREIGN KEY ([intPurchaseCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblARMarketZone_Purchase] FOREIGN KEY ([intPurchaseMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICItem_Purchase] FOREIGN KEY ([intPurchaseItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCity_intOriginPortId_Purchase] FOREIGN KEY (intPurchaseOriginPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCity_intDestinationPortId_Purchase] FOREIGN KEY (intPurchaseDestinationPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblCTCropYear_intCropYearId_Purchase] FOREIGN KEY (intPurchaseCropYearId) REFERENCES [dbo].[tblCTCropYear] (intCropYearId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCompanyLocationSubLocation_intStorageLocationId_Purchase] FOREIGN KEY (intPurchaseStorageLocationId) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] (intCompanyLocationSubLocationId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICStorageLocation_intStorageUnitId_Purchase] FOREIGN KEY (intPurchaseStorageUnitId) REFERENCES [dbo].[tblICStorageLocation] (intStorageLocationId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblCTMTMPoint_intMTMPointId_Purchase] FOREIGN KEY (intPurchaseMTMPointId) REFERENCES [dbo].[tblCTMTMPoint] (intMTMPointId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblRKFutureMarket_Sales] FOREIGN KEY ([intSalesFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICCommodity_Sales] FOREIGN KEY ([intSalesCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblRKFuturesMonth_Sales] FOREIGN KEY ([intSalesFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCompanyLocation_Sales] FOREIGN KEY ([intSalesCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblARMarketZone_Sales] FOREIGN KEY ([intSalesMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]), 
    CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICItem_Sales] FOREIGN KEY ([intSalesItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCity_intOriginPortId_Sales] FOREIGN KEY (intSalesOriginPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCity_intDestinationPortId_Sales] FOREIGN KEY (intSalesDestinationPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblCTCropYear_intCropYearId_Sales] FOREIGN KEY (intSalesCropYearId) REFERENCES [dbo].[tblCTCropYear] (intCropYearId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCompanyLocationSubLocation_intStorageLocationId_Sales] FOREIGN KEY (intSalesStorageLocationId) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] (intCompanyLocationSubLocationId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblICStorageLocation_intStorageUnitId_Sales] FOREIGN KEY (intSalesStorageUnitId) REFERENCES [dbo].[tblICStorageLocation] (intStorageLocationId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblCTMTMPoint_intMTMPointId_Sales] FOREIGN KEY (intSalesMTMPointId) REFERENCES [dbo].[tblCTMTMPoint] (intMTMPointId),
	CONSTRAINT [FK_tblRKAllocatedContractsTransaction_tblSMCurrency_intCurrencyID] FOREIGN KEY (intTransactionCurrencyId) REFERENCES [dbo].[tblSMCurrency] (intCurrencyID)
)