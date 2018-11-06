CREATE PROCEDURE [dbo].[uspRKDPRPreCrushPositionDetail]
	@intCommodityId NVARCHAR(max)
	, @intLocationId NVARCHAR(max) = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(50) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strPositionBy NVARCHAR(100) = NULL
AS

BEGIN
	SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	IF (@intLocationId = 0) SET @intLocationId = NULL
	IF (@intVendorId = 0) SET @intVendorId = NULL
	IF (@intBookId = 0) SET @intBookId = NULL
	IF (@intSubBookId = 0) SET @intSubBookId = NULL

	IF ISNULL(@strPurchaseSales, '') <> ''
	BEGIN
		IF @strPurchaseSales = 'Purchase'
		BEGIN
			SELECT @strPurchaseSales = 'Sale'
		END
		ELSE
		BEGIN
			SELECT @strPurchaseSales = 'Purchase'
		END
	END

	DECLARE @strCommodityCode NVARCHAR(50)
	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodity INT)

	INSERT INTO @Commodity (intCommodity)
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@intCommodityId, ',')

	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(50)
		, strLocationName NVARCHAR(100)
		, strContractEndMonth NVARCHAR(50)
		, strContractEndMonthNearBy NVARCHAR(50)
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50)
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100)
		, strTranType NVARCHAR(50)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50)
		, strEntityName NVARCHAR(100)
		, intOrderId int
		, strInventoryType NVARCHAR(100)
		, intPricingTypeId int
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, dtmDeliveryDate DATETIME
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	DECLARE @FinalList AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(50)
		, strLocationName NVARCHAR(100)
		, strContractEndMonth NVARCHAR(50)
		, strContractEndMonthNearBy NVARCHAR(50)
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50)
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50)
		, strEntityName NVARCHAR(100)
		, intOrderId int
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, dtmDeliveryDate DATETIME
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	DECLARE @InventoryStock AS TABLE (strCommodityCode NVARCHAR(100)
		, strItemNo NVARCHAR(100)
		, dblTotal numeric(24,10)
		, strLocationName nvarchar(100)
		, intCommodityId int
		, intFromCommodityUnitMeasureId int
		, strType nvarchar(100)
		, strInventoryType NVARCHAR(100)
		, intPricingTypeId int)

	DECLARE @tblGetStorageDetailByDate TABLE (intRowNum int
		, intCustomerStorageId int
		, intCompanyLocationId int	
		, [Loc] nvarchar(100)
		, [Delivery Date] datetime
		, [Ticket] nvarchar(100)
		, intEntityId int
		, [Customer] nvarchar(100)
		, [Receipt] nvarchar(100)
		, [Disc Due] numeric(24,10)
		, [Storage Due] numeric(24,10)
		, [Balance] numeric(24,10)
		, intStorageTypeId int
		, [Storage Type] nvarchar(100)
		, intCommodityId int
		, [Commodity Code] nvarchar(100)
		, [Commodity Description] nvarchar(100)
		, strOwnedPhysicalStock nvarchar(100)
		, ysnReceiptedStorage bit
		, ysnDPOwnedType bit
		, ysnGrainBankType bit
		, ysnCustomerStorage bit
		, strCustomerReference  nvarchar(100)
 		, dtmLastStorageAccrueDate  datetime
 		, strScheduleId nvarchar(100)
		, strItemNo nvarchar(100)
		, strLocationName nvarchar(100)
		, intCommodityUnitMeasureId int
		, intItemId int)

	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription NVARCHAR(50)
	DECLARE @intOneCommodityId INT
	DECLARE @intCommodityUnitMeasureId INT

	SELECT @mRowNumber = MIN(intCommodityIdentity)
	FROM @Commodity

	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity
		FROM @Commodity
		WHERE intCommodityIdentity = @mRowNumber

		SELECT @strDescription = strCommodityCode
		FROM tblICCommodity
		WHERE intCommodityId = @intCommodityId

		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		FROM tblICCommodityUnitMeasure
		WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

		IF @intCommodityId > 0
		BEGIN
			DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
				, strCommodityCode NVARCHAR(100)
				, intCommodityId INT
				, intContractHeaderId INT
				, strContractNumber NVARCHAR(100)
				, strLocationName NVARCHAR(100)
				, dtmEndDate DATETIME
				, strFutureMonth NVARCHAR(100)
				, dblBalance DECIMAL(24, 10)
				, intUnitMeasureId INT
				, intPricingTypeId INT
				, intContractTypeId INT
				, intCompanyLocationId INT
				, strContractType NVARCHAR(100)
				, strPricingType NVARCHAR(100)
				, intCommodityUnitMeasureId INT
				, intContractDetailId INT
				, intContractStatusId INT
				, intEntityId INT
				, intCurrencyId INT
				, strType NVARCHAR(100)
				, intItemId INT
				, strItemNo NVARCHAR(100)
				, dtmContractDate DATETIME
				, strEntityName NVARCHAR(100)
				, strCustomerContract NVARCHAR(100)
				, intFutureMarketId INT
				, intFutureMonthId INT
				, intCategoryId INT
				, strCategory NVARCHAR(100)
				, strFutMarketName NVARCHAR(100))

			INSERT INTO @tblGetOpenContractDetail (intRowNum
				, strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strLocationName
				, dtmEndDate
				, strFutureMonth
				, dblBalance
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType
				, intCommodityUnitMeasureId
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, strCustomerContract
				, intFutureMarketId
				, intFutureMonthId
				, intCategoryId
				, strCategory
				, strFutMarketName)
			SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC)
				, strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strLocationName
				, dtmEndDate
				, strFutureMonth
				, dblBalance
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType
				, intCommodityUnitMeasureId
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, strCustomerContract
				, intFutureMarketId
				, intFutureMonthId
				, intCategoryId
				, strCategory
				, strFutMarketName
			FROM vyuRKContractDetail CD
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intCommodityId = @intCommodityId
						AND CD.intContractStatusId <> 6
						
			DECLARE @tblGetOpenFutureByDate TABLE (intFutOptTransactionId INT
				, intOpenContract INT
				, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblContractSize NUMERIC(24,10)
				, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblStrike NUMERIC(24,10)
				, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intFutOptTransactionHeaderId int
				, ysnPreCrush BIT
				, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
				, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
			INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId
				, intOpenContract
				, strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, dblContractSize
				, strFutureMarket
				, strFutureMonth
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, strNewBuySell
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strNotes
				, strBrokerTradeNo)
			EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

			INSERT INTO @List (strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, dtmDeliveryDate)
			SELECT strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, dtmEndDate
			FROM (
				SELECT strCommodityCode
					, CD.intCommodityId
					, CD.intContractHeaderId
					, strContractNumber
					, CD.strType
					, strLocationName
					, strContractEndMonth = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
												ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
					, strContractEndMonthNearBy = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
													ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
					, dblTotal = CASE WHEN intContractTypeId = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) ELSE - dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) END
					, CD.intUnitMeasureId intFromCommodityUnitMeasureId
					, CD.strEntityName
					, CD.intItemId
					, CD.strItemNo
					, CD.intCategoryId
					, CD.strCategory
					, CD.intFutureMarketId
					, CD.strFutMarketName
					, CD.intFutureMonthId
					, CD.strFutureMonth
					, CD.dtmEndDate
				FROM @tblGetOpenContractDetail CD
				JOIN tblCTContractDetail det ON CD.intContractDetailId = det.intContractDetailId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId AND CD.intContractStatusId <> 3
					AND CD.intCompanyLocationId IN (SELECT intCompanyLocationId
													FROM tblSMCompanyLocation
													WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																						ELSE isnull(ysnLicensed, 0) END)
				WHERE intContractTypeId IN (1, 2) AND CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CD.intCompanyLocationId ELSE @intLocationId END
					AND CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END
			) t WHERE dblTotal <> 0
						
			DECLARE @intUnitMeasureId INT
			DECLARE @strUnitMeasure NVARCHAR(50)

			SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId
			FROM tblRKCompanyPreference

			SELECT @strUnitMeasure = strUnitMeasure
			FROM tblICUnitMeasure
			WHERE intUnitMeasureId = @intUnitMeasureId

			INSERT INTO @FinalList (strCommodityCode
				, strContractNumber
				, intContractHeaderId
				, strInternalTradeNo
				, intFutOptTransactionHeaderId
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, strUnitMeasure
				, strAccountNumber
				, strTranType
				, dblNoOfLot
				, dblDelta
				, intBrokerageAccountId
				, strInstrumentType
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, dtmDeliveryDate
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush)
			SELECT strCommodityCode
				, strContractNumber
				, intContractHeaderId
				, strInternalTradeNo
				, intFutOptTransactionHeaderId
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal = CONVERT(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN ISNULL(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
				, strUnitMeasure = ISNULL(@strUnitMeasure, um.strUnitMeasure)
				, strAccountNumber
				, strTranType
				, dblNoOfLot
				, dblDelta
				, intBrokerageAccountId
				, strInstrumentType
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, dtmDeliveryDate
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM @List t
			JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
			JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
			WHERE t.intCommodityId = @intCommodityId

			-- inventory
			INSERT INTO @InventoryStock(strCommodityCode
				, strItemNo
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, strItemNo
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, i.strItemNo
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(s.dblQuantity, 0))
					, strLocationName
					, intCommodityId = @intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Company Titled Inventory'
				FROM vyuICGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId = s.intItemId
				JOIN tblICItemUOM iuom ON s.intItemId = iuom.intItemId AND iuom.ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit = 1 AND ISNULL(s.dblQuantity,0) <> 0 AND ysnInTransit = 0
					AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND s.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																				WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																				ELSE ISNULL(ysnLicensed, 0) END)
			) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, strItemNo
			
			-- inventory basis
			SELECT strCommodityCode
				, strItemNo
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, intCategoryId
				, strCategory
			INTO #tempInvPurBasis
			FROM (
				SELECT strCommodityCode
					, i.strItemNo
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(s.dblQuantity,0))
					, strLocationName
					, intCommodityId = @intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Company Titled Inventory'
					, intPricingTypeId
					, i.intCategoryId
					, strCategory = Category.strCategoryCode
				FROM vyuICGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId = s.intItemId
				JOIN tblICItemUOM iuom ON s.intItemId = iuom.intItemId AND iuom.ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				LEFT JOIN tblICInventoryReceipt ir ON ir.strReceiptNumber = s.strTransactionId
				LEFT JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = ir.intInventoryReceiptId
				LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
				WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit = 1 AND ISNULL(s.dblQuantity, 0) <> 0
					AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND s.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																				WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																				ELSE isnull(ysnLicensed, 0) END)
			) t WHERE intPricingTypeId = 2
			GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, strItemNo
				, intCategoryId
				, strCategory
			
			--Collateral
			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType = 'Collateral'
				FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC)
						, dblTotal = CASE WHEN c.strType = 'Purchase' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((c.dblRemainingQuantity), 0))
										ELSE - ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((c.dblRemainingQuantity), 0))) END
						, intCommodityId = @intCommodityId
						, co.strCommodityCode
						, cl.strLocationName
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					FROM tblRKCollateralHistory c
					JOIN tblICCommodity co ON co.intCommodityId = c.intCommodityId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
					JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
					LEFT JOIN @tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
					LEFT JOIn tblCTContractDetail det ON ch.intContractDetailId = det.intContractDetailId
					WHERE c.intCommodityId = @intCommodityId 
						AND c.intLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN c.intLocationId ELSE @intLocationId END
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				) a WHERE a.intRowNum = 1
			) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			
			-- OFfSite
			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType = 'OffSite'
				FROM (
					SELECT strCommodityCode
						, strLocationName
						, c.intCommodityId
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId,(Balance))
						, CH.intCompanyLocationId
					FROM @tblGetStorageDetailByDate CH
					JOIN tblICCommodity c ON CH.intCommodityId = c.intCommodityId
					WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND CH.intCommodityId = @intCommodityId
						AND CH.intCompanyLocationId = ISNULL(@intLocationId, CH.intCompanyLocationId)
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																						ELSE ISNULL(ysnLicensed, 0) END)
			) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			
			-- OFfSite
			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, dblTotal = sum(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Sls Basis Deliveries'
				FROM (
					SELECT strCommodityCode
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, cd.intCommodityUnitMeasureId, ISNULL(ri.dblQuantity, 0))
						, cl.strLocationName
						, cd.intCommodityId
						, cd.intCompanyLocationId
					FROM vyuICGetInventoryValuation v
					JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2
						AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
					INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
					LEFT JOIN tblCTContractDetail det ON cd.intContractDetailId = det.intContractDetailId
					WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
						AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																					WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																					ELSE ISNULL(ysnLicensed, 0) END
			)) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			
			-- DP
			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'DP'
				FROM (
					SELECT strCommodityCode
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(Balance,0)))
						, strLocationName
						, c.intCommodityId
						, ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId
					WHERE ch.intCommodityId = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
					) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
														WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																							WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																							ELSE ISNULL(ysnLicensed, 0) END
			)) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
		END
		SELECT @mRowNumber = MIN(intCommodityIdentity)
		FROM @Commodity
		WHERE intCommodityIdentity > @mRowNumber
	END
END

UPDATE @FinalList
SET strContractEndMonth = 'Near By'
WHERE CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110))

DELETE FROM @List

INSERT INTO @List (strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal = ISNULL(dblTotal, 0)
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId = CASE WHEN strType = 'Purchase Priced' THEN 1
						WHEN strType = 'Sale Priced' THEN 2
						WHEN strType = 'Purchase HTA' THEN 3
						WHEN strType = 'Sale HTA' THEN 4
						WHEN strType = 'Purchase Basis' THEN 12
						WHEN strType = 'Sale Basis' THEN 13
						WHEN strType = 'Purchase DP (Priced Later)' THEN 14
						WHEN strType = 'Sale DP (Priced Later)' THEN 15 END
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList
WHERE strContractEndMonth = 'Near By' AND strType IN ('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)')

INSERT INTO @List (
	strCommodityCode
	,strContractNumber
	,intContractHeaderId
	,strInternalTradeNo
	,intFutOptTransactionHeaderId
	,strType
	,strLocationName
	,strContractEndMonth
	,strContractEndMonthNearBy
	,dblTotal
	,strUnitMeasure
	,strAccountNumber
	,strTranType
	,dblNoOfLot
	,dblDelta
	,intBrokerageAccountId
	,strInstrumentType
	,strEntityName
	,intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	,strContractNumber
	,intContractHeaderId
	,strInternalTradeNo
	,intFutOptTransactionHeaderId
	,strType
	,strLocationName
	,strContractEndMonth
	,strContractEndMonthNearBy
	,isnull(dblTotal, 0) dblTotal
	,strUnitMeasure
	,strAccountNumber
	,strTranType
	,dblNoOfLot
	,dblDelta
	,intBrokerageAccountId
	,strInstrumentType
	,strEntityName
	,case when strType= 'Purchase Priced' then 1 
		  when strType= 'Sale Priced' then 2 
		  when strType= 'Purchase HTA' then 3
		  when strType= 'Sale HTA'  then 4
		  when strType= 'Purchase Basis'  then 12 
		  when strType= 'Sale Basis'  then 13
		  when strType= 'Purchase DP (Priced Later)'  then 14 
		  when strType= 'Sale DP (Priced Later)'  then 15  end  intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList 
WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)')
ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC


INSERT INTO @List (strCommodityCode
	,dblTotal
	,strContractEndMonth
	,strLocationName
	,intCommodityId
	,intFromCommodityUnitMeasureId
	,intOrderId
	,strType
	,strInventoryType)
SELECT strCommodityCode
	,dblTotal
	,'Near By'
	,strLocationName
	,intCommodityId
	,intFromCommodityUnitMeasureId
	,5 intOrderId
	,'Company Titled Inventory'
	,strInventoryType
FROM @InventoryStock
WHERE strInventoryType = 'Company Titled Inventory'

INSERT INTO @List (strCommodityCode
	,dblTotal
	,strContractEndMonth
	,strLocationName
	,intCommodityId
	,intFromCommodityUnitMeasureId
	,intOrderId
	,strType
	,strInventoryType
	,intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	,dblTotal
	,strContractEndMonth
	,strLocationName
	,intCommodityId
	,intFromCommodityUnitMeasureId
	,6 intOrderId
	,'Net Physical Position' strType
	,strInventoryType
	,intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List WHERE intOrderId in(1,2,3,4,5)

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, 'Net Futures'
	, strLocationName
	, strFutureMonth
	, dtmFutureMonthsDate
	, HedgedQty
	, intUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId = 8
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM (
	SELECT oc.strCommodityCode
		, f.strInternalTradeNo
		, f.intFutOptTransactionHeaderId
		, f.intCommodityId
		, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
									ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END
		, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END * m.dblContractSize)
		, l.strLocationName
		, strFutureMonth = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
								ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END
		, m.intUnitMeasureId
		, e.strName + '-' + ba.strAccountNumber strAccountNumber
		, strTranType = strBuySell
		, f.intBrokerageAccountId
		, strInstrumentType = CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END
		, dblNoOfLot = CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END
		, f.intFutureMarketId
		, oc.strFutureMarket
		, f.intFutureMonthId
		, oc.strBrokerTradeNo
		, oc.strNotes
		, oc.ysnPreCrush
	FROM @tblGetOpenFutureByDate oc
	JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 AND ISNULL(f.ysnPreCrush, 0) = 0
	INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
	JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
	INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
	AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																	WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																	ELSE ISNULL(ysnLicensed, 0) END)
	INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
	WHERE f.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
		AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)) t

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType = 'Net Futures Position'
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal = SUM(dblTotal)
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, 9
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List WHERE intOrderId IN (1,2,3,4,5,7,8)
GROUP BY strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strType
	, strLocationName
	, strContractEndMonth
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strTranType
	, intOrderId
	, strItemNo
	, intCategoryId
	, strCategory)
SELECT strCommodityCode
	, intCommodityId
	, strType = 'Net Futures Position'
	, strLocationName
	, strContractEndMonth = 'Near By'
	, dblTotal = CONVERT(NUMERIC(24,6), - SUM(dblTotal))
	, intFromCommodityUnitMeasureId
	, strTranType = 'Purchase Basis Delivery'
	, intOrderId = 9
	, strItemNo
	, intCategoryId
	, strCategory
FROM #tempInvPurBasis
GROUP BY strCommodityCode
	, intCommodityId
	, strLocationName
	, intFromCommodityUnitMeasureId
	, strItemNo
	, intCategoryId
	, strCategory

-- Crush records
IF ((SELECT TOP 1 ysnPreCrush FROM tblRKCompanyPreference) = 1)
BEGIN
	INSERT INTO @List (strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, intFromCommodityUnitMeasureId
		, strAccountNumber
		, strTranType
		, intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot
		, intOrderId
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, 'Crush'
		, strLocationName
		, strFutureMonth
		, dtmFutureMonthsDate
		, HedgedQty
		, intUnitMeasureId
		, strAccountNumber
		, strTranType
		, intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot
		, 7 intOrderId
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM (
		SELECT oc.strCommodityCode
			, oc.strInternalTradeNo
			, oc.intFutOptTransactionHeaderId
			, f.intCommodityId
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end dtmFutureMonthsDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0)
																															ELSE ISNULL(intOpenContract, 0) END * m.dblContractSize) AS HedgedQty
			, l.strLocationName
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end strFutureMonth
			, m.intUnitMeasureId
			, e.strName + '-' + ba.strAccountNumber strAccountNumber
			, strBuySell AS strTranType
			, f.intBrokerageAccountId
			,CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END AS strInstrumentType
			,CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END dblNoOfLot
			, oc.strBrokerTradeNo
			, oc.strNotes
			, oc.ysnPreCrush
		FROM @tblGetOpenFutureByDate oc
		JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 and isnull(f.ysnPreCrush,0)=1
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
		AND intCompanyLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END)
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.intCommodityId IN (select distinct intCommodity from @Commodity c)
			AND f.intLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN f.intLocationId ELSE @intLocationId END) t

	IF NOT EXISTS (SELECT TOP 1 1 FROM @List WHERE intOrderId = 7)
	BEGIN
		INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
		SELECT 	TOP 1 strCommodityCode,0,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,7,'Crush','Buy' FROM @List
	END

	INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
	SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,11 intOrderId,'Overall Position' strType,strInventoryType from @List where intOrderId in(7, 9)
END

----------------

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,16 intOrderId,'Net Unpriced Position' strType,strInventoryType from @List where intOrderId in(12,13,14,15)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,17 intOrderId,'Owned Quantity Position' strType,strInventoryType from @List where intOrderId in(6,16)


DECLARE @ListFinal AS TABLE (intRowNumber1 INT IDENTITY
	, intRowNumber INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(200)
	, intFutOptTransactionHeaderId INT
	, strInternalTradeNo NVARCHAR(200)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(200)
	, strType NVARCHAR(50)
	, strLocationName NVARCHAR(100)
	, strContractEndMonth NVARCHAR(50)
	, strContractEndMonthNearBy NVARCHAR(50)
	, dblTotal DECIMAL(24, 10)
	, intSeqNo INT
	, strUnitMeasure NVARCHAR(50)
	, intFromCommodityUnitMeasureId INT
	, intToCommodityUnitMeasureId INT
	, strAccountNumber NVARCHAR(100)
	, strTranType NVARCHAR(100)
	, dblNoOfLot NUMERIC(24, 10)
	, dblDelta NUMERIC(24, 10)
	, intBrokerageAccountId INT
	, strInstrumentType NVARCHAR(50)
	, strEntityName NVARCHAR(100)
	, intOrderId int
	, strInventoryType NVARCHAR(100)
	, intItemId INT
	, strItemNo NVARCHAR(100)
	, intCategoryId INT
	, strCategory NVARCHAR(100)
	, intFutureMarketId INT
	, strFutMarketName NVARCHAR(100)
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100)
	, dtmDeliveryDate DATETIME
	, strBrokerTradeNo NVARCHAR(100)
	, strNotes NVARCHAR(100)
	, ysnPreCrush BIT)


DECLARE @MonthOrderList AS TABLE (		
		strContractEndMonth NVARCHAR(100))

insert into @MonthOrderList
SELECT distinct  strContractEndMonth FROM @List where strContractEndMonth <> 'Near By' 

DECLARE @MonthOrderListFinal AS TABLE (		
		strContractEndMonth NVARCHAR(100))

INSERT INTO @MonthOrderListFinal 
SELECT 'Near By' 
INSERT INTO @MonthOrderListFinal 
SELECT  strContractEndMonth FROM @MonthOrderList ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) 

DECLARE @TopRowRec AS TABLE (		
		strType NVARCHAR(100),
		strCommodityCode NVARCHAR(100))
INSERT INTO @TopRowRec 
SELECT TOP 1 strType,strCommodityCode from @List 

INSERT INTO @ListFinal(
		 strCommodityCode		
		,strType		
		,strContractEndMonth
		,dblTotal)
SELECT   strCommodityCode		
		,strType		
		,strContractEndMonth		
		,0.0 dblTotal
	FROM @TopRowRec t
	CROSS JOIN @MonthOrderListFinal t1
	
INSERT INTO @ListFinal(intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List
WHERE (ISNULL(dblTotal,0) <> 0 OR strType = 'Crush') AND strContractEndMonth = 'Near By'

INSERT INTO @ListFinal(intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List 
WHERE (ISNULL(dblTotal,0) <> 0 OR strType = 'Crush') and strContractEndMonth not in ( 'Near By') order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

SELECT intSeqNo = intOrderId
	, intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY intSeqNo)) 
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, dtmDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @ListFinal WHERE (ISNULL(dblTotal, 0) <> 0 OR strType = 'Crush')
ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME, '01 ' + strContractEndMonth) END
	, intSeqNo
	, strType