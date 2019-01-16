﻿CREATE PROCEDURE [dbo].[uspRKDPRPreCrushPositionDetail]
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

	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END
	IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		SET @intVendorId = NULL
	END

	DECLARE @strCommodityCode NVARCHAR(50)
	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodity INT)

	INSERT INTO @Commodity (intCommodity)
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@intCommodityId, ',')

	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intOrderId int
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT)
	DECLARE @FinalList AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intOrderId int
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT)
	DECLARE @InventoryStock AS TABLE (strCommodityCode NVARCHAR(100)
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal numeric(24,10)
		, strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intFromCommodityUnitMeasureId int
		, strType nvarchar(100) COLLATE Latin1_General_CI_AS
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId int)

	DECLARE @tblGetStorageDetailByDate TABLE (intRowNum int
		, intCustomerStorageId int
		, intCompanyLocationId int	
		, [Loc] nvarchar(100) COLLATE Latin1_General_CI_AS
		, [Delivery Date] datetime
		, [Ticket] nvarchar(100) COLLATE Latin1_General_CI_AS
		, intEntityId int
		, [Customer] nvarchar(100) COLLATE Latin1_General_CI_AS
		, [Receipt] nvarchar(100) COLLATE Latin1_General_CI_AS
		, [Disc Due] numeric(24,10)
		, [Storage Due] numeric(24,10)
		, [Balance] numeric(24,10)
		, intStorageTypeId int
		, [Storage Type] nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, [Commodity Code] nvarchar(100) COLLATE Latin1_General_CI_AS
		, [Commodity Description] nvarchar(100) COLLATE Latin1_General_CI_AS
		, strOwnedPhysicalStock nvarchar(100) COLLATE Latin1_General_CI_AS
		, ysnReceiptedStorage bit
		, ysnDPOwnedType bit
		, ysnGrainBankType bit
		, ysnCustomerStorage bit
		, strCustomerReference  nvarchar(100) COLLATE Latin1_General_CI_AS
 		, dtmLastStorageAccrueDate  datetime
 		, strScheduleId nvarchar(100) COLLATE Latin1_General_CI_AS
		, strItemNo nvarchar(100) COLLATE Latin1_General_CI_AS
		, strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
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
				, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intCommodityId INT
				, intContractHeaderId INT
				, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmEndDate DATETIME
				, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblBalance DECIMAL(24, 10)
				, intUnitMeasureId INT
				, intPricingTypeId INT
				, intContractTypeId INT
				, intCompanyLocationId INT
				, strContractType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strPricingType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intContractDetailId INT
				, intContractStatusId INT
				, intEntityId INT
				, intCurrencyId INT
				, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intItemId INT
				, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmContractDate DATETIME
				, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intFutureMarketId INT
				, intFutureMonthId INT
				, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS)

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
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName)
			SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC)
				, strCommodityCode = CD.strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber = CD.strContract
				, strLocationName
				, dtmEndDate --= CASE WHEN ISNULL(strFutureMonth,'') <> '' THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) ELSE dtmEndDate END
				, strFutureMonth
				, dblBalance = CD.dblQuantity
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType = (CD.strContractType + ' ' + CD.strPricingType) COLLATE Latin1_General_CI_AS
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName = CD.strCustomer
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName
			FROM dbo.fnCTGetContractBalance(null,null,null,'01-01-1900',@dtmToDate,NULL,NULL,NULL,NULL) CD
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
						
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
			SELECT * FROM  fnRKGetOpenFutureByDate( @intCommodityId, @dtmToDate)

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
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate)
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
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
			FROM (
				SELECT DISTINCT strCommodityCode
					, CD.intCommodityId
					, CD.intContractHeaderId
					, strContractNumber
					, CD.strType
					, strLocationName
					, strContractEndMonth = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
												ELSE (CASE WHEN ISNULL(CD.strFutureMonth, '') = '' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END) END COLLATE Latin1_General_CI_AS
					, strContractEndMonthNearBy = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
													ELSE (CASE WHEN ISNULL(CD.strFutureMonth, '') = '' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END) END COLLATE Latin1_General_CI_AS
					, dblTotal = CASE WHEN intContractTypeId = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) ELSE - dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((CD.dblBalance), 0)) END
					, CD.intUnitMeasureId intFromCommodityUnitMeasureId
					, CD.strEntityName
					, CD.intItemId
					, CD.strItemNo
					, CD.strCategory
					, CD.intFutureMarketId
					, CD.strFutMarketName
					, CD.intFutureMonthId
					, CD.strFutureMonth
					, strDeliveryDate = CASE WHEN ISNULL(CD.dtmEndDate, '') = '' THEN '' ELSE RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) END COLLATE Latin1_General_CI_AS
					, CD.intContractDetailId
				FROM @tblGetOpenContractDetail CD
				JOIN tblCTContractDetail det ON CD.intContractDetailId = det.intContractDetailId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId AND CD.intContractStatusId <> 3
					AND CD.intCompanyLocationId IN (SELECT intCompanyLocationId
													FROM tblSMCompanyLocation
													WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																						ELSE isnull(ysnLicensed, 0) END)
				WHERE intContractTypeId IN (1, 2) AND CD.intCommodityId = @intCommodityId
					AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
					AND CD.intEntityId = ISNULL(@intVendorId, CD.intEntityId)
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
				, strDeliveryDate
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
				, strDeliveryDate
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
				, strCategory
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, strItemNo
				, strCategoryCode
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, i.strItemNo
					, Category.strCategoryCode
					, dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
					, strLocationName
					, intCommodityId = @intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
				FROM vyuRKGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId = s.intItemId
				JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
				JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
				JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity,0) <> 0 AND ysnInTransit = 0
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
				, strCategoryCode
			
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
					, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
					, intPricingTypeId
					, i.intCategoryId
					, strCategory = Category.strCategoryCode
				FROM vyuRKGetInventoryValuation s
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
					, strInventoryType = 'Collateral' COLLATE Latin1_General_CI_AS
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
						AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
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
					, strInventoryType = 'OffSite' COLLATE Latin1_General_CI_AS
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
					, strInventoryType = 'DP' COLLATE Latin1_General_CI_AS
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

			INSERT INTO @FinalList(intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate)
			SELECT intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intSeqId
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
			FROM  (
				SELECT DISTINCT cd.intContractHeaderId
					, cd.strContractNumber
					, cd.intCommodityId
					, cd.strCommodityCode
					, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
					, cd.intCompanyLocationId
					, cd.strLocationName
					, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
					, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))
					, intSeqId = 6
					, um.strUnitMeasure
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, cd.strEntityName
					, intOrderId = 6
					, cd.intItemId
					, cd.strItemNo
					, cd.strCategory
					, cd.intFutureMarketId
					, cd.strFutMarketName
					, cd.intFutureMonthId
					, cd.strFutureMonth
					, strDeliveryDate = dbo.fnRKFormatDate(det.dtmEndDate, 'MMM yyyy')
					--, strDeliveryDate = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
					--						ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(cd.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
					, ri.intSourceId
				FROM vyuRKGetInventoryValuation v
				JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
				INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
				INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
				JOIN (SELECT intContractDetailId, dtmEndDate FROM tblCTContractDetail) det ON cd.intContractDetailId = det.intContractDetailId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
				LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
				LEFT JOIN tblCTPriceFixationDetail pfd ON invD.intInvoiceDetailId = pfd.intInvoiceDetailId
				WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
					AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(inv.dtmDate,DATEADD(DAY,1,getDate())), 110), 110)
					AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(pfd.dtmFixationDate,DATEADD(DAY,1,getDate())), 110), 110)
			) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																					WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																					ELSE ISNULL(ysnLicensed, 0) END)
				
			INSERT INTO @FinalList(intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
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
				, strDeliveryDate)
			SELECT intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal = (SUM(ISNULL(dblTotal, 0)) * -1)
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
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
				, strDeliveryDate
			FROM (
				SELECT cd.intContractHeaderId
					, cd.strContractNumber
					, cd.intCommodityId
					, cd.strCommodityCode
					, strType = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
					, cd.intCompanyLocationId
					, cd.strLocationName
					, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
					, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0))
					, intSeqNo = 5
					, um.strUnitMeasure
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, cd.strEntityName
					, intOrderId = 5
					, v.intItemId
					, v.strItemNo
					, v.intCategoryId
					, v.strCategory
					, cd.intFutureMarketId
					, cd.strFutMarketName
					, cd.intFutureMonthId
					, cd.strFutureMonth
					, strDeliveryDate = dbo.fnRKFormatDate(det.dtmEndDate, 'MMM yyyy')
					--, strDeliveryDate = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
					--						ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(cd.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
				FROM vyuRKGetInventoryValuation v
				JOIN tblICInventoryReceipt r ON r.strReceiptNumber = v.strTransactionId
				INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
				INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') AND ISNULL(ysnInTransit, 0) = 0
				INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
				JOIN (SELECT intContractDetailId, dtmEndDate FROM tblCTContractDetail) det ON cd.intContractDetailId = det.intContractDetailId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
				INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
				WHERE v.strTransactionType = 'Inventory Receipt' AND cd.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate) AND ISNULL(strTicketStatus, '') <> 'V'
			) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																					WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																					ELSE ISNULL(ysnLicensed, 0) END)
			GROUP BY intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
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
				, strDeliveryDate
		END
		SELECT @mRowNumber = MIN(intCommodityIdentity)
		FROM @Commodity
		WHERE intCommodityIdentity > @mRowNumber
	END
END

UPDATE @FinalList
SET strContractEndMonth = 'Near By'
WHERE strContractEndMonth <> 'Near By'
	AND CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110))

DELETE FROM @List

INSERT INTO @List(intContractHeaderId
	, strContractNumber
	, intCommodityId
	, strCommodityCode
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intSeqNo
	, strUnitMeasure
	, intFromCommodityUnitMeasureId
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
	, strDeliveryDate)
SELECT intContractHeaderId
	, strContractNumber
	, intCommodityId
	, strCommodityCode
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intSeqNo
	, strUnitMeasure
	, intFromCommodityUnitMeasureId
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
	, strDeliveryDate
FROM @FinalList
WHERE strType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')

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
	, strDeliveryDate
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
						WHEN strType = 'Purchase Basis' THEN 19
						WHEN strType = 'Sale Basis' THEN 20
						WHEN strType = 'Purchase DP (Priced Later)' THEN 17
						WHEN strType = 'Sale DP (Priced Later)' THEN 18
						WHEN strType = 'Purchase Unit' THEN 22
						WHEN strType = 'Sale Unit' THEN 21 END
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList
WHERE strContractEndMonth = 'Near By' AND strType IN ('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')

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
	, strDeliveryDate
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
						WHEN strType = 'Purchase Basis' THEN 19
						WHEN strType = 'Sale Basis' THEN 20
						WHEN strType = 'Purchase DP (Priced Later)' THEN 17
						WHEN strType = 'Sale DP (Priced Later)' THEN 18
						WHEN strType = 'Purchase Unit' THEN 22
						WHEN strType = 'Sale Unit' THEN 21 END
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList 
WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')
ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

INSERT INTO @List (strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, strContractEndMonth
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId
	, strType
	, strInventoryType)
SELECT strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, 'Near By' COLLATE Latin1_General_CI_AS
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId = 7
	, 'Company Titled' COLLATE Latin1_General_CI_AS
	, strInventoryType
FROM @InventoryStock
WHERE strInventoryType IN ('Company Titled', 'Collateral')

INSERT INTO @List (strCommodityCode
	, dblTotal
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId
	, strType
	, strInventoryType
	, intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strContractNumber
	, strContractEndMonth
	, strContractEndMonthNearBy
	, intContractHeaderId)
SELECT strCommodityCode
	, dblTotal
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId = 9
	, strType = 'Net Physical Position' COLLATE Latin1_General_CI_AS
	, strInventoryType
	, intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strContractNumber
	, strContractEndMonth
	, strContractEndMonthNearBy = strContractEndMonth
	, intContractHeaderId
FROM @List WHERE intOrderId in(1, 2, 3, 4, 5, 6, 7)

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
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, 'Net Futures' COLLATE Latin1_General_CI_AS
	, strLocationName
	, strContractEndMonth
	, dtmFutureMonthsDate
	, HedgedQty
	, intUnitMeasureId
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId = 12
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM (
	SELECT oc.strCommodityCode
		, f.strInternalTradeNo
		, f.intFutOptTransactionHeaderId
		, f.intCommodityId
		, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
									ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(intOpenContract, 0) * m.dblContractSize)
		, l.strLocationName
		, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
								ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, m.intUnitMeasureId
		, UOM.strUnitMeasure
		, (e.strName + '-' + ba.strAccountNumber) COLLATE Latin1_General_CI_AS strAccountNumber
		, strTranType = strBuySell
		, f.intBrokerageAccountId
		, strInstrumentType = CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END COLLATE Latin1_General_CI_AS
		, dblNoOfLot = ISNULL(intOpenContract, 0)
		, f.intFutureMarketId
		, oc.strFutureMarket
		, f.intFutureMonthId
		, fm.strFutureMonth
		, oc.strBrokerTradeNo
		, oc.strNotes
		, oc.ysnPreCrush
	FROM @tblGetOpenFutureByDate oc
	JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 AND ISNULL(f.ysnPreCrush, 0) = 0
	INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
	JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = m.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
	INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
	AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																	WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																	ELSE ISNULL(ysnLicensed, 0) END)
	INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
	WHERE f.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
		AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)
		AND ISNULL(oc.ysnPreCrush, 0) = 0) t


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
	, dblDelta
	, intOrderId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, 'Delta Adjusted Options' COLLATE Latin1_General_CI_AS
	, strLocationName
	, strContractEndMonth
	, dtmFutureMonthsDate
	, HedgedQty
	, intUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, dblDelta
	, intOrderId = 15
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM (
	SELECT oc.strCommodityCode
		, f.strInternalTradeNo
		, f.intFutOptTransactionHeaderId
		, f.intCommodityId
		, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + om.strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
									ELSE LEFT(om.strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, HedgedQty = intOpenContract * ISNULL((SELECT TOP 1 dblDelta
												FROM tblRKFuturesSettlementPrice sp
												INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
												WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
													AND oc.dblStrike = mm.dblStrike
												ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize
		, l.strLocationName
		, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + om.strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
								ELSE LEFT(om.strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, m.intUnitMeasureId
		, e.strName + '-' + ba.strAccountNumber COLLATE Latin1_General_CI_AS strAccountNumber
		, strTranType = strBuySell
		, f.intBrokerageAccountId
		, strInstrumentType = CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END COLLATE Latin1_General_CI_AS
		, dblNoOfLot = CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END
		, dblDelta = ISNULL((SELECT TOP 1 dblDelta
							FROM tblRKFuturesSettlementPrice sp
							INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
							WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
								AND oc.dblStrike = mm.dblStrike
							ORDER BY dtmPriceDate DESC), 0)
		, f.intFutureMarketId
		, oc.strFutureMarket
		, f.intFutureMonthId
		, strFutureMonth = om.strOptionMonth
		, oc.strBrokerTradeNo
		, oc.strNotes
		, oc.ysnPreCrush
	FROM @tblGetOpenFutureByDate oc
	JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 AND ISNULL(f.ysnPreCrush, 0) = 0
	INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
	JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
	JOIN tblRKOptionsMonth om ON om.strOptionMonth = oc.strOptionMonth
	INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
	AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
																	WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
																	ELSE ISNULL(ysnLicensed, 0) END)
	INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 2
	WHERE f.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
		AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)
		AND ISNULL(oc.ysnPreCrush, 0) = 0) t

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
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, 'Crush' COLLATE Latin1_General_CI_AS
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
		, 14 intOrderId
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM (
		SELECT oc.strCommodityCode
			, oc.strInternalTradeNo
			, oc.intFutOptTransactionHeaderId
			, f.intCommodityId
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS dtmFutureMonthsDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0)
																															ELSE ISNULL(intOpenContract, 0) END * m.dblContractSize) AS HedgedQty
			, l.strLocationName
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS strFutureMonth
			, m.intUnitMeasureId
			, e.strName + '-' + ba.strAccountNumber COLLATE Latin1_General_CI_AS strAccountNumber
			, strBuySell AS strTranType
			, f.intBrokerageAccountId
			,CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END COLLATE Latin1_General_CI_AS AS strInstrumentType
			,CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END dblNoOfLot
			, f.intFutureMarketId
			, oc.strFutureMarket
			, f.intFutureMonthId
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
			AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)) t

	IF NOT EXISTS (SELECT TOP 1 1 FROM @List WHERE intOrderId = 14)
	BEGIN
		INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
		SELECT 	TOP 1 strCommodityCode,0,'Near By' COLLATE Latin1_General_CI_AS,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,14,'Crush' COLLATE Latin1_General_CI_AS,'Buy' COLLATE Latin1_General_CI_AS FROM @List
	END
END

----------------

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
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType = 'Net Hedge' COLLATE Latin1_General_CI_AS
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
	, 16
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List WHERE intOrderId IN (12, 14, 15)
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
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,23 intOrderId,'Net Unpriced Position' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @List where intOrderId in(19, 20, 21, 22)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,25 intOrderId,'Basis Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @List where intOrderId in(1, 2, 5, 6, 7, 19, 20)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,26 intOrderId,'Price Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @List where intOrderId in(9, 16)

DECLARE @ListFinal AS TABLE (intRowNumber1 INT IDENTITY
	, intRowNumber INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId INT
	, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblTotal DECIMAL(24, 10)
	, intSeqNo INT
	, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFromCommodityUnitMeasureId INT
	, intToCommodityUnitMeasureId INT
	, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTranType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblNoOfLot NUMERIC(24, 10)
	, dblDelta NUMERIC(24, 10)
	, intBrokerageAccountId INT
	, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOrderId int
	, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnPreCrush BIT)

DECLARE @MonthOrderList AS TABLE (		
		strContractEndMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS)

insert into @MonthOrderList
SELECT distinct  strContractEndMonth FROM @List where strContractEndMonth <> 'Near By' 

DECLARE @MonthOrderListFinal AS TABLE (		
		strContractEndMonth NVARCHAR(100))

INSERT INTO @MonthOrderListFinal 
SELECT 'Near By' COLLATE Latin1_General_CI_AS
INSERT INTO @MonthOrderListFinal 
SELECT  strContractEndMonth FROM @MonthOrderList ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) 

DECLARE @TopRowRec AS TABLE (		
		strType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS)
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
	, strDeliveryDate
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
	, strDeliveryDate
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
	, strDeliveryDate
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
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List 
WHERE (ISNULL(dblTotal,0) <> 0 OR strType = 'Crush') and strContractEndMonth not in ( 'Near By') order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

UPDATE @ListFinal SET strFutureMonth = CASE 
	WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
	WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
	WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
END COLLATE Latin1_General_CI_AS
	, strDeliveryDate = CT.strDeliveryDate
FROM @ListFinal F
LEFT JOIN (
	SELECT intFutOptTransactionHeaderId
		,strInternalTradeNo
		,strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
	FROM vyuRKFutOptTransaction
)FOT ON FOT.intFutOptTransactionHeaderId = F.intFutOptTransactionHeaderId AND FOT.strInternalTradeNo COLLATE Latin1_General_CI_AS = F.strInternalTradeNo COLLATE Latin1_General_CI_AS
LEFT JOIN (
	SELECT intContractHeaderId
	,REPLACE(strSequenceNumber,' ','') COLLATE Latin1_General_CI_AS AS strContractNumber
	,dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') COLLATE Latin1_General_CI_AS AS strDeliveryDate
	,ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS AS strFutureMonth
	,strContractType
	FROM vyuCTContractDetailView
)CT ON CT.intContractHeaderId = F.intContractHeaderId
	AND CT.strContractNumber = (CASE WHEN PATINDEX('%,%', F.strContractNumber) = 0 THEN F.strContractNumber ELSE LEFT(F.strContractNumber, PATINDEX('%,%', F.strContractNumber) - 1)END)
	
UPDATE @ListFinal SET strContractEndMonthNearBy = CASE 
		WHEN @strPositionBy = 'Futures Month'  THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
		WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
		WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
	END

UPDATE @ListFinal SET strContractEndMonthNearBy = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''

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
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @ListFinal WHERE (ISNULL(dblTotal, 0) <> 0 OR strType = 'Crush')
ORDER BY intSeqNo
	, CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME, '01 ' + strContractEndMonth) END
	, strType