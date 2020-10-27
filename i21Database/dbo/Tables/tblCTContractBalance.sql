CREATE TABLE [dbo].[tblCTContractBalance]
(
	 intContractBalanceId				INT IDENTITY(1,1) NOT NULL,
	 intContractTypeId					INT	
	,intEntityId						INT
	,intCommodityId						INT
	,dtmEndDate							DATETIME
	,intCompanyLocationId				INT
	,intFutureMarketId					INT
	,intFutureMonthId					INT
	,intContractHeaderId				INT
	,strType							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intContractDetailId				INT	
	,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
	,strContractType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
	,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intItemId							INT
	,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
	,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCustomer						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strContract						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strShipMethod						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strShipmentPeriod					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
	,strDeliveryMonth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblFutures							NUMERIC(38,20)
	,dblBasis							NUMERIC(38,20)
	,strBasisUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblQuantity						NUMERIC(38,20)
	,strQuantityUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblCashPrice						NUMERIC(38,20)
	,strPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strStockUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblAvailableQty					NUMERIC(38,20)
	,dblAmount							NUMERIC(38,20)
	,dblQtyinCommodityStockUOM			NUMERIC(38,20)
	,dblFuturesinCommodityStockUOM		NUMERIC(38,20)
	,dblBasisinCommodityStockUOM		NUMERIC(38,20)
	,dblCashPriceinCommodityStockUOM	NUMERIC(38,20)
	,dblAmountinCommodityStockUOM		NUMERIC(38,20)
	,intPricingTypeId					INT
	,strPricingTypeDesc					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intUnitMeasureId					INT
	,intContractStatusId				INT
	,intCurrencyId						INT
	,strCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dtmContractDate					DATETIME
	,dtmSeqEndDate						DATETIME	
	,strFutMarketName					NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strCategory 						NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strPricingStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
)
GO

CREATE NONCLUSTERED INDEX [IX_tblCTContractBalance_forDPR]
	ON [dbo].[tblCTContractBalance] ([intContractDetailId])
	INCLUDE (dtmContractDate,dtmEndDate)

GO
