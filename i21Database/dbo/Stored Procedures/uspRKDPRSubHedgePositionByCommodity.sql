CREATE PROCEDURE [dbo].[uspRKDPRSubHedgePositionByCommodity]
	@intCommodityId nvarchar(max)= null
	,@intLocationId int = null
	,@intVendorId int = null
	,@strPurchaseSales NVARCHAR(200) = null
	,@strPositionIncludes NVARCHAR(200) = NULL
	,@dtmToDate datetime = NULL
	,@strByType NVARCHAR(200) = null
	,@strPositionBy NVARCHAR(50) = NULL

AS

BEGIN

	DECLARE @strCommodityCode NVARCHAR(max)

	IF ISNULL(@strPurchaseSales,'') <> ''
	BEGIN
		IF @strPurchaseSales='Purchase'
		BEGIN
			SELECT @strPurchaseSales='Sale'
		END
		ELSE
		BEGIN
			SELECT @strPurchaseSales='Purchase'
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

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE ISNULL(ysnLicensed, 0) END

	SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	DECLARE @ysnIncludeDPPurchasesInCompanyTitled bit
		, @ysnPreCrush BIT
	SELECT @ysnIncludeDPPurchasesInCompanyTitled = isnull(ysnIncludeDPPurchasesInCompanyTitled,0)
		, @ysnPreCrush = ISNULL(ysnPreCrush, 0)
	FROM tblRKCompanyPreference

	DECLARE @Commodity AS TABLE (intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY
		, intCommodity  INT)

	DECLARE @CrushReport BIT = 0
    IF (ISNULL(@strPositionBy, '') = 'Delivery Month' OR ISNULL(@strPositionBy, '') = 'Futures Month')
    BEGIN
        SET @CrushReport = 1
    END

	IF(@strByType='ByCommodity')
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT intCommodityId from tblICCommodity 
	END
	ELSE
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	END
	
	DECLARE @tempFinal AS TABLE (intRow INT IDENTITY(1,1)
		, intContractHeaderId int
		, strContractNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, intFutOptTransactionHeaderId int
		, strInternalTradeNo NVARCHAR(200) Collate Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(200) Collate Latin1_General_CI_AS
		, strType  NVARCHAR(200) Collate Latin1_General_CI_AS
		, strSubType  NVARCHAR(200) Collate Latin1_General_CI_AS
		, strContractType NVARCHAR(200) Collate Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) Collate Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(200) Collate Latin1_General_CI_AS
		, intInventoryReceiptItemId INT
		, strTicketNumber  NVARCHAR(200) Collate Latin1_General_CI_AS
		, dtmTicketDateTime DATETIME
		, strCustomerReference NVARCHAR(200) Collate Latin1_General_CI_AS
		, strDistributionOption NVARCHAR(200) Collate Latin1_General_CI_AS
		, dblUnitCost NUMERIC(24, 10)
		, dblQtyReceived NUMERIC(24, 10)
		, dblTotal DECIMAL(24,10)
		, intSeqNo int
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, intCommodityId int
		, strAccountNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, strTranType NVARCHAR(20) Collate Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(200) Collate Latin1_General_CI_AS
		, intNoOfContract NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, strCurrency NVARCHAR(200) Collate Latin1_General_CI_AS
		, intCompanyLocationId int
		, intInvoiceId  int
		, strInvoiceNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, intBillId  int
		, strBillId NVARCHAR(200) Collate Latin1_General_CI_AS
		, intInventoryReceiptId int
		, strReceiptNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, intTicketId int
		, strShipmentNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, intInventoryShipmentId int
		, intItemId int
		, intContractTypeId int)

	DECLARE @Final AS TABLE (strType  NVARCHAR(200) Collate Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) Collate Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, strUnitMeasure NVARCHAR(200) Collate Latin1_General_CI_AS
		, intCommodityId int
		, strCurrency NVARCHAR(200) Collate Latin1_General_CI_AS)

	DECLARE @tblGetOpenContractDetail TABLE (intRowNum int
		, strCommodityCode NVARCHAR(200) Collate Latin1_General_CI_AS
		, intCommodityId int
		, intContractHeaderId int
		, strContractNumber NVARCHAR(200) Collate Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) Collate Latin1_General_CI_AS
		, dtmEndDate datetime
		, dblBalance DECIMAL(24,10)
		, intUnitMeasureId int
		, intPricingTypeId int
		, intContractTypeId int
		, intCompanyLocationId int
		, strContractType NVARCHAR(200) Collate Latin1_General_CI_AS
		, strPricingType NVARCHAR(200) Collate Latin1_General_CI_AS
		, intContractDetailId int
		, intContractStatusId int
		, intEntityId int
		, intCurrencyId int
		, strType NVARCHAR(200) Collate Latin1_General_CI_AS
		, intItemId int
		, strItemNo NVARCHAR(200) Collate Latin1_General_CI_AS
		, dtmContractDate datetime
		, strEntityName NVARCHAR(200) Collate Latin1_General_CI_AS
		, intFutureMarketId int
		, intFutureMonthId int
		, strCurrency NVARCHAR(200) Collate Latin1_General_CI_AS)

	INSERT INTO @tblGetOpenContractDetail(intRowNum
		, strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber
		, strLocationName
		, dtmEndDate
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
		, strEntityName
		, intFutureMarketId
		, intFutureMonthId
		, strCurrency)
	SELECT ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC) intRowNum
		, strCommodityCode = CD.strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber = CD.strContract
		, strLocationName
		, dtmEndDate
		, dblBalance = CD.dblQtyinCommodityStockUOM
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCompanyLocationId
		, strContractType
		, strPricingType = CD.strPricingTypeDesc
		, CD.intContractDetailId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) Collate Latin1_General_CI_AS
		, intItemId
		, strItemNo
		, strEntityName = CD.strCustomer
		, NULL intFutureMarketId
		, NULL intFutureMonthId
		, strCurrency 
	FROM tblCTContractBalance CD
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
	AND CD.intCommodityId in (select intCommodity from @Commodity)
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate

	DECLARE @tblGetOpenFutureByDate TABLE (intRowNum INT
		, dtmTransactionDate DATETIME
		, intFutOptTransactionId INT
		, dblOpenContract INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblContractSize NUMERIC(24,10)
		, strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOptionMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblStrike NUMERIC(24,10)
		, strOptionType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strBrokerAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intBrokerageAccountId INT
		, strBroker NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strNewBuySell NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)

	INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId
        , dblOpenContract
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
        , strBrokerTradeNo
		, intBrokerageAccountId)
	SELECT 
		intFutOptTransactionId
		, dblOpenContract
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
		, strBrokerTradeNo 
		, intBrokerageAccountId
	FROM  fnRKGetOpenFutureByDate((SELECT TOP 1 intCommodity FROM @Commodity),'1/1/1900', @dtmToDate, @CrushReport)


	DECLARE @tblGetStorageDetailByDate TABLE (intRowNum int
		, intCustomerStorageId int
		, intCompanyLocationId int
		, [Loc] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, [Delivery Date] datetime
		, [Ticket] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intEntityId int
		, [Customer] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, [Receipt] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, [Disc Due] numeric(24,10)
		, [Storage Due] numeric(24,10)
		, [Balance] numeric(24,10)
		, intStorageTypeId int
		, [Storage Type] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, [Commodity Code] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, [Commodity Description] NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOwnedPhysicalStock NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, ysnReceiptedStorage bit
		, ysnDPOwnedType bit
		, ysnGrainBankType bit
		, ysnCustomerStorage bit
		, strCustomerReference  NVARCHAR(200) COLLATE Latin1_General_CI_AS
 		, dtmLastStorageAccrueDate  datetime
 		, strScheduleId NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityUnitMeasureId int
		, intItemId int
		, intTicketId int
		, strTicketNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	INSERT INTO @tblGetStorageDetailByDate
	SELECT ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum
		, a.intCustomerStorageId
		, a.intCompanyLocationId
		, c.strLocationName [Loc]
		, CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
		, a.strStorageTicketNumber [Ticket]
		, a.intEntityId
		, E.strName [Customer]
		, a.strDPARecieptNumber [Receipt]
		, a.dblDiscountsDue [Disc Due]
		, a.dblStorageDue   [Storage Due]
		, [Balance] = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
		, a.intStorageTypeId
		, b.strStorageTypeDescription [Storage Type]
		, a.intCommodityId
		, CM.strCommodityCode [Commodity Code]
		, CM.strDescription   [Commodity Description]
		, b.strOwnedPhysicalStock
		, b.ysnReceiptedStorage
		, b.ysnDPOwnedType
		, b.ysnGrainBankType
		, b.ysnActive ysnCustomerStorage 
		, a.strCustomerReference  
 		, a.dtmLastStorageAccrueDate  
 		, c1.strScheduleId
		, i.strItemNo
		, c.strLocationName
		, ium.intCommodityUnitMeasureId as intCommodityUnitMeasureId
		, i.intItemId as intItemId  ,t.intTicketId,t.strTicketNumber
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i ON i.intItemId = a.intItemId
	JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
	LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
	LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
	WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
	and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
	and i.intCommodityId in (select intCommodity from @Commodity)

	UNION ALL SELECT ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum
		, a.intCustomerStorageId
		, a.intCompanyLocationId
		, c.strLocationName [Loc]
		, CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
		, a.strStorageTicketNumber [Ticket]
		, a.intEntityId
		, E.strName [Customer]
		, a.strDPARecieptNumber [Receipt]
		, a.dblDiscountsDue [Disc Due]
		, a.dblStorageDue   [Storage Due]
		, [Balance] = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
		, a.intStorageTypeId
		, b.strStorageTypeDescription [Storage Type]
		, a.intCommodityId
		, CM.strCommodityCode [Commodity Code]
		, CM.strDescription   [Commodity Description]
		, b.strOwnedPhysicalStock
		, b.ysnReceiptedStorage
		, b.ysnDPOwnedType
		, b.ysnGrainBankType
		, b.ysnActive ysnCustomerStorage 
		, a.strCustomerReference  
 		, a.dtmLastStorageAccrueDate  
 		, c1.strScheduleId
		, i.strItemNo
		, c.strLocationName
		, ium.intCommodityUnitMeasureId as intCommodityUnitMeasureId
		, i.intItemId as intItemId
		, null intTicketId
		, '' strTicketNumber
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i ON i.intItemId = a.intItemId
	JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
	LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
	WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
	and convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
	and i.intCommodityId in (select intCommodity from @Commodity)


	DECLARE @invQty TABLE (dblTotal numeric(24,10)
		, Ticket NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intFromCommodityUnitMeasureId int
		, intLocationId int
		, strTransactionId  NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strTransactionType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intItemId int
		, strDistributionOption NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strTicketStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	INSERT INTO @invQty
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
		, t.strTicketNumber Ticket
		, s.strLocationName
		, s.strItemNo
		, i.intCommodityId intCommodityId
		, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
		, s.intLocationId intLocationId
		, strTransactionId
		, strTransactionType
		, i.intItemId
		, t.strDistributionOption
		, strTicketStatus
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
	LEFT JOIN tblSCTicket t on s.intSourceId=t.intTicketId
	WHERE i.intCommodityId in (select intCommodity from @Commodity) AND ISNULL(s.dblQuantity,0) <> 0
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
		AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation) 
		AND ysnInTransit = 0
		--AND ISNULL(strDistributionOption,'') <> CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN '@#$%' ELSE 'DP' END 

	DECLARE @tempCollateral TABLE (intRowNum int
		, intCollateralId int
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intContractHeaderId int
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmOpenDate datetime
		, dblOriginalQuantity numeric(24,10)
		, dblRemainingQuantity numeric(24,10)
		, intCommodityId int
		, intUnitMeasureId int
		, intCompanyLocationId int
		, intContractTypeId int
		, intLocationId int
		, intEntityId int)

	INSERT INTO @tempCollateral
	SELECT * FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY c.intCollateralId ORDER BY c.dtmOpenDate DESC) intRowNum
			, c.intCollateralId
			, cl.strLocationName
			, ch.strItemNo
			, ch.strEntityName
			, c.strReceiptNo
			, ch.intContractHeaderId
			, strContractNumber
			, c.dtmOpenDate
			, isnull(c.dblOriginalQuantity,0) dblOriginalQuantity
			, dblRemainingQuantity = isnull(c.dblOriginalQuantity,0) - isnull(ca.dblAdjustmentAmount,0)
			, c.intCommodityId as intCommodityId
			, c.intUnitMeasureId
			, c.intLocationId intCompanyLocationId
			, case when c.strType='Purchase' then 1 else 2 end intContractTypeId
			, c.intLocationId,intEntityId
		FROM tblRKCollateral c
		LEFT JOIN (
			SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			GROUP BY intCollateralId

		) ca on c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId in (select intCommodity from @Commodity)
			AND convert(DATETIME, CONVERT(VARCHAR(10), c.dtmOpenDate, 110), 110) <= convert(datetime,@dtmToDate)
			AND c.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND c.ysnIncludeInPriceRiskAndCompanyTitled = 1		
	) a WHERE a.intRowNum = 1
	
	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription NVARCHAR(200)
	declare @intOneCommodityId int
	declare @intCommodityUnitMeasureId int
			,@intCommodityStockUOMId INT
	DECLARE @ysnExchangeTraded bit
	
	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity

	WHILE @mRowNumber >0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode, @ysnExchangeTraded = ysnExchangeTraded FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId, @intCommodityStockUOMId = intUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
		
		IF  @intCommodityId >0 --AND @ysnExchangeTraded = 1
		BEGIN
			IF ISNULL(@intVendorId,0) = 0
			BEGIN
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId)
				SELECT * FROM (
					SELECT DISTINCT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, cd.strType [strType]
						, 'Physical Contract' COLLATE Latin1_General_CI_AS strContractType
						, strLocationName
						, RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS strContractEndMonth
						, ISNULL(cd.dblBalance, 0) AS dblTotal
						, cd.intUnitMeasureId
						, @intCommodityId as intCommodityId
						, cd.intCompanyLocationId
						, strCurrency
						, intContractTypeId
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId in(1,2) and cd.intCommodityId = @intCommodityId
						AND cd.intContractStatusId <> 3  
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
				) t
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName)
				SELECT DISTINCT @strCommodityCode
					, 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
					, 'Inventory' COLLATE Latin1_General_CI_AS strContractType
					, sum(dblTotal) dblTotal
					, intItemId
					, strItemNo
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
				FROM @invQty where intCommodityId=@intCommodityId
				GROUP BY intItemId, strItemNo, intFromCommodityUnitMeasureId, strLocationName, intCommodityId
				
				--=========================================
				-- Includes DP based on Company Preference
				--========================================
				If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
				BEGIN
					INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intItemId
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency)
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'Inventory'
						, dblTotal = -SUM(dblTotal)
						, intItemId
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency = NULL
					FROM (
						SELECT DISTINCT intTicketId
							, strTicketNumber
							, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL([Balance],0)))
							, ch.intCompanyLocationId
							, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, intItemId
							, strItemNo
						FROM @tblGetStorageDetailByDate ch
						WHERE ch.intCommodityId  = @intCommodityId
							AND ysnDPOwnedType = 1
							AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
						)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					GROUP BY intTicketId
						, strTicketNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intItemId
						, strItemNo
				END
				ELSE
				BEGIN
					INSERT INTO @tempFinal(strCommodityCode
							, strType
							, strContractType
							, dblTotal
							, intItemId
							, intFromCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, strCurrency)
						SELECT @strCommodityCode
							, strType = 'Price Risk'
							, strContractType = 'DP'
							, dblTotal = -SUM(dblTotal)
							, intItemId
							, intFromCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, strCurrency = NULL
						FROM (
							SELECT DISTINCT intTicketId
								, strTicketNumber
								, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL([Balance],0)))
								, ch.intCompanyLocationId
								, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
								, intCommodityId
								, strLocationName
								, intItemId
								, strItemNo
							FROM @tblGetStorageDetailByDate ch
							WHERE ch.intCommodityId  = @intCommodityId
								AND ysnDPOwnedType = 1
								AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
							)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
						GROUP BY intTicketId
							, strTicketNumber
							, intFromCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, intItemId
							, strItemNo
				END

			If ((SELECT TOP 1 ysnIncludeInTransitInCompanyTitled from tblRKCompanyPreference)=1)
			BEGIN	

				IF OBJECT_ID('tempdb..#tblGetSalesIntransitWOPickLot') IS NOT NULL
				DROP TABLE #tblGetSalesIntransitWOPickLot
				--=============================
				-- Sales In Transit w/o Pick Lot
				--=============================
				SELECT strShipmentNumber
					, intInventoryShipmentId
					, strContractNumber
					, intContractHeaderId
					, intCompanyLocationId
					, strLocationName
					, dblBalanceToInvoice 
					, intEntityId
					, strCustomerReference 
					, dtmTicketDateTime
					, intTicketId
					, strTicketNumber
					, intCommodityId
					, intItemId
					, strItemNo
					, strCategory
					, intCategoryId
					, strContractEndMonth
					, strFutureMonth
					, strDeliveryDate
				INTO #tblGetSalesIntransitWOPickLot
				FROM(
					SELECT 
							strShipmentNumber = InTran.strTransactionId
						,intInventoryShipmentId = InTran.intTransactionId
						,strContractNumber = SI.strOrderNumber + '-' + CONVERT(NVARCHAR, SI.intContractSeq) COLLATE Latin1_General_CI_AS 
						,intContractHeaderId = SI.intOrderId 
						,strTicketNumber = SI.strSourceNumber
						,intTicketId = SI.intSourceId
						,dtmTicketDateTime = InTran.dtmDate
						,intCompanyLocationId = Inv.intLocationId
						,strLocationName = Inv.strLocationName
						,strUOM = InTran.strUnitMeasure
						,Inv.intEntityId
						,strCustomerReference = SI.strCustomerName
						,Com.intCommodityId
						,Itm.intItemId
						,Itm.strItemNo
						,strCategory = Cat.strCategoryCode
						,Cat.intCategoryId
						,dblBalanceToInvoice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((InTran.dblInTransitQty),0))
						,strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), InTran.dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
						,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblCTContractDetail cd INNER JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId =  fmnt.intFutureMonthId WHERE intContractHeaderId = SI.intLineNo)
						,strDeliveryDate =  (SELECT TOP 1 dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') FROM tblCTContractDetail WHERE intContractHeaderId = SI.intLineNo)
					FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmToDate) InTran
						INNER JOIN vyuICGetInventoryValuation Inv ON InTran.intInventoryTransactionId = Inv.intInventoryTransactionId
						INNER JOIN tblICItem Itm ON InTran.intItemId = Itm.intItemId
						INNER JOIN tblICCommodity Com ON Itm.intCommodityId = Com.intCommodityId
						INNER JOIN tblICCategory Cat ON Itm.intCategoryId = Cat.intCategoryId
						LEFT JOIN vyuICGetInventoryShipmentItem SI ON InTran.intTransactionDetailId = SI.intInventoryShipmentItemId
						INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InTran.intItemUOMId
						INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
						JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = Com.intCommodityId AND cum.intUnitMeasureId = UOM.intUnitMeasureId
					WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmToDate)
						AND ISNULL(Inv.intEntityId,0) = CASE WHEN ISNULL(@intVendorId,0)=0 THEN ISNULL(Inv.intEntityId,0) ELSE @intVendorId END				
				)t


				INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intItemId
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency)
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'Sales In-Transit'
						, dblTotal = SUM(dblTotal)
						, intItemId
						, intFromCommodityUnitMeasureId = NULL
						, intCommodityId
						, strLocationName
						, strCurrency = NULL
					FROM (
					SELECT  dblTotal = dblBalanceToInvoice
							, i.strLocationName
							, i.intCompanyLocationId
							,c.strCommodityCode
							,c.intCommodityId
							,i.intItemId
					FROM #tblGetSalesIntransitWOPickLot i						
					join tblICCommodity c on i.intCommodityId=c.intCommodityId
					WHERE i.intCommodityId = @intCommodityId
						AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)	
						AND i.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				)t 	
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY intItemId,intCommodityId,strLocationName,intCompanyLocationId


				INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intItemId
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency)
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'Purchase In-Transit'
						, dblTotal = SUM(dblTotal)
						, intItemId
						, intFromCommodityUnitMeasureId = NULL
						, intCommodityId
						, strLocationName
						, strCurrency = NULL
					FROM (
						SELECT i.intUnitMeasureId
							, dblTotal = ISNULL(i.dblPurchaseContractShippedQty, 0)
							, i.strLocationName
							, i.intItemId
							, i.strItemNo
							, i.intCompanyLocationId, 
							c.strCommodityCode,
							c.intCommodityId,
							intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId
						FROM vyuRKPurchaseIntransitView i
						join tblICCommodity c on i.intCommodityId=c.intCommodityId
						WHERE i.intCommodityId = @intCommodityId
							AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
							AND i.intPurchaseSale = 1 -- 1.Purchase 2. Sales
							AND i.intEntityId = ISNULL(@intVendorId, i.intEntityId)			
				)t 	
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY intItemId,intCommodityId,strLocationName,intCompanyLocationId


			END
			


				--Net Hedge Derivative Entry (Futures and Options)
				-- Hedge
				INSERT INTO @tempFinal (strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strAccountNumber
					, strTranType
					, intBrokerageAccountId
					, strInstrumentType
					, dblNoOfLot
					, strCurrency)
				SELECT strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, 'Price Risk' COLLATE Latin1_General_CI_AS
					, 'Future' COLLATE Latin1_General_CI_AS strContractType
					, strLocationName
					, strFutureMonth
					, HedgedQty
					, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId
					, @intCommodityId intCommodityId
					, strAccountNumber
					, strTranType
					, intBrokerageAccountId
					, strInstrumentType
					, dblNoOfLot
					, strCurrency
				FROM (
					SELECT DISTINCT t.strCommodityCode
						, strInternalTradeNo
						, t.intFutOptTransactionHeaderId
						, th.intCommodityId
						, dtmFutureMonthsDate
						, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblOpenContract * t.dblContractSize) AS HedgedQty
						, l.strLocationName
						, (left(t.strFutureMonth, 4) + '20' + convert(nvarchar(2),intYear)) COLLATE Latin1_General_CI_AS strFutureMonth
						, m.intUnitMeasureId
						, (t.strBroker + '-' + t.strBrokerAccount) COLLATE Latin1_General_CI_AS strAccountNumber
						, strNewBuySell as strTranType
						, t.intBrokerageAccountId
						, 'Future' COLLATE Latin1_General_CI_AS strInstrumentType
						, dblOpenContract dblNoOfLot
						, cu.strCurrency
					FROM @tblGetOpenFutureByDate t
					JOIN tblICCommodity th on th.strCommodityCode=t.strCommodityCode
					join tblSMCompanyLocation l on l.strLocationName=t.strLocationName
					join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
					join tblSMCurrency cu on cu.intCurrencyID=m.intCurrencyId
					INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Futures'
					JOIN tblICCommodityUnitMeasure cuc1 on cuc1.intCommodityId=@intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId
					INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
					WHERE th.intCommodityId = @intCommodityId
						AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
						and intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
						AND ISNULL(t.ysnPreCrush, 0) = 0
				) t	
		
				-- Option Net Hedge
				INSERT INTO @tempFinal (strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, strCurrency)
				SELECT DISTINCT t.strCommodityCode
					, t.strInternalTradeNo
					, intFutOptTransactionHeaderId
					, 'Price Risk' COLLATE Latin1_General_CI_AS 
					, 'Option' COLLATE Latin1_General_CI_AS 
					, t.strLocationName
					, (LEFT(t.strFutureMonth,4) + '20' + convert(nvarchar(2),fm.intYear)) COLLATE Latin1_General_CI_AS strFutureMonth
					, dblOpenContract * isnull((SELECT TOP 1 dblDelta
												FROM tblRKFuturesSettlementPrice sp
												INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
												WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId
													AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
													AND t.dblStrike = mm.dblStrike
												ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize AS dblNoOfContract
					, m.intUnitMeasureId
					, th.intCommodityId
					, (e.strName + '-' + t.strBrokerAccount) COLLATE Latin1_General_CI_AS AS strAccountNumber
					, strNewBuySell AS TranType
					, dblOpenContract AS dblNoOfLot
					, isnull((SELECT TOP 1 dblDelta
							FROM tblRKFuturesSettlementPrice sp
							INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
							WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId
								AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
								AND t.dblStrike = mm.dblStrike
							ORDER BY dtmPriceDate DESC), 0) AS dblDelta
					, t.intBrokerageAccountId
					, 'Option' COLLATE Latin1_General_CI_AS as strInstrumentType
					, strCurrency
				FROM @tblGetOpenFutureByDate t
				join tblICCommodity th on th.strCommodityCode=t.strCommodityCode
				join tblSMCompanyLocation l on l.strLocationName=t.strLocationName 
				join tblRKFutureMarket m on m.strFutMarketName=t.strFutureMarket
				join tblSMCurrency cu on cu.intCurrencyID=m.intCurrencyId
				join tblRKOptionsMonth om on om.strOptionMonth=t.strOptionMonth
				INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType= 'Options'
				INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
				WHERE th.intCommodityId = @intCommodityId
					AND intCompanyLocationId = isnull(@intLocationId, intCompanyLocationId)
					AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
					AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
					and intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND ISNULL(t.ysnPreCrush, 0) = 0
		
				IF @ysnPreCrush = 1 AND ISNULL(@strPositionBy,'') <> ''
				BEGIN
					--Crush Records
					INSERT INTO @tempFinal(strCommodityCode
						, strInternalTradeNo
						, intFutOptTransactionHeaderId
						, strType
						, strContractType
						, strLocationName
						, strContractEndMonth
						, dblTotal
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strAccountNumber
						, strTranType
						, intBrokerageAccountId
						, strInstrumentType
						, dblNoOfLot)
					SELECT strCommodityCode
						, strInternalTradeNo
						, intFutOptTransactionHeaderId
						, 'Price Risk' COLLATE Latin1_General_CI_AS 
						, strContractType = 'Crush' COLLATE Latin1_General_CI_AS 
						, strLocationName
						, strFutureMonth
						, HedgedQty
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
						, intCommodityId = @intCommodityId
						, strAccountNumber
						, strTranType
						, intBrokerageAccountId
						, strInstrumentType
						, dblNoOfLot
					FROM (
						SELECT oc.strCommodityCode
							, oc.strInternalTradeNo
							, oc.intFutOptTransactionHeaderId
							, f.intCommodityId
							, cuc1.intCommodityUnitMeasureId
							, (case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
									else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end) COLLATE Latin1_General_CI_AS dtmFutureMonthsDate
							, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0)
																																			ELSE ISNULL(dblOpenContract, 0) END * m.dblContractSize) AS HedgedQty
							, l.strLocationName
							, (case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
									else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end) COLLATE Latin1_General_CI_AS strFutureMonth
							, m.intUnitMeasureId
							, (e.strName + '-' + oc.strBrokerAccount) COLLATE Latin1_General_CI_AS strAccountNumber
							, strBuySell AS strTranType
							, f.intBrokerageAccountId
							, (CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END) COLLATE Latin1_General_CI_AS AS strInstrumentType
							, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END dblNoOfLot
							, f.intFutureMarketId
							, oc.strFutureMarket
							, f.intFutureMonthId
							, oc.strBrokerTradeNo
							, oc.strNotes
							, oc.ysnPreCrush
						FROM @tblGetOpenFutureByDate oc
						JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.dblOpenContract <> 0 and isnull(f.ysnPreCrush,0)=1
						INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
						JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
						INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
						INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
						INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
						WHERE f.intCommodityId = @intCommodityId
							AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)
					) t

				
				END
		
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intInventoryReceiptId
					, strReceiptNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency)
				SELECT @strCommodityCode
					, 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
					, 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS strContractType
					, dblTotal = - BD.dblQuantity
					, intInventoryReceiptId = BD.intTransactionId
					, strReceiptNumber = BD.strTransactionId
					, intCommodityUnitMeasureId = NULL
					, BD.intCommodityId
					, strLocationName = BD.strCompanyLocation
					, cur.strCurrency
				FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
					INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
					INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
					INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
					INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
					INNER JOIN tblSMCurrency cur ON cur.intCurrencyID = BD.intCurrencyId
				WHERE BD.intCommodityId = @intCommodityId
					AND strContractType = 'Purchase'
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND BD.ysnOpenGetBasisDelivery = 1

				INSERT INTO @tempFinal(strCommodityCode
                    , strType
                    , strContractType
                    , dblTotal
                    , intInventoryReceiptId
                    , strReceiptNumber
                    , intFromCommodityUnitMeasureId
                    , intCommodityId
                    , strLocationName
                    , strCurrency)
                SELECT @strCommodityCode
                    , 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
                    , 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS strContractType
                    , dblTotal = BD.dblQuantity
                    , intInventoryShipmentId = BD.intTransactionId
                    , strShipmentNumber = BD.strTransactionId
                    , intCommodityUnitMeasureId = NULL
                    , BD.intCommodityId
                    , strLocationName = BD.strCompanyLocation
                    , cur.strCurrency
                FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
					INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
					INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
					INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
					INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
					INNER JOIN tblSMCurrency cur ON cur.intCurrencyID = BD.intCurrencyId
				WHERE BD.intCommodityId = @intCommodityId
					AND strContractType = 'Sale'
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND BD.ysnOpenGetBasisDelivery = 1

				--INSERT INTO @tempFinal(strCommodityCode
    --                , strType
    --                , strContractType
    --                , dblTotal
    --                , intInventoryReceiptId
    --                , strReceiptNumber
    --                , intFromCommodityUnitMeasureId
    --                , intCommodityId
    --                , strLocationName
    --                , strCurrency)
    --            SELECT @strCommodityCode
    --                , 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
    --                , 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS strContractType
    --                , sum(dblTotal)
    --                , intInventoryShipmentId
    --                , strShipmentNumber
    --                , intCommodityUnitMeasureId
    --                , intCommodityId
    --                , strLocationName
    --                , strCurrency
    --            FROM (
    --                SELECT DISTINCT dblTotal = dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,iuom.intUnitMeasureId,@intCommodityStockUOMId,isnull(ri.dblQuantity, 0))
    --                        , r.intInventoryShipmentId
    --                        , r.strShipmentNumber
    --                        , intCommodityUnitMeasureId = @intCommodityUnitMeasureId
    --                        , i.intCommodityId
    --                        , cl.strLocationName
    --                        , cl.intCompanyLocationId
    --                        , v.strCurrency
    --                        , cd.intItemId
    --                        , i.strItemNo
    --                        , cat.strCategoryCode
    --                        , cd.intFutureMarketId
    --                        , fm.strFutMarketName
    --                        , cd.intFutureMonthId
    --                        , mnt.strFutureMonth
    --                FROM vyuRKGetInventoryValuation v
    --                JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
    --                INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId AND ri.intInventoryShipmentItemId =  v.intTransactionDetailId
    --                INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
    --                INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId  AND ch.intContractTypeId = 2
    --                INNER JOIN tblICItem i on cd.intItemId = i.intItemId
				--	INNER JOIN tblICItemUOM iuom on iuom.intItemId = i.intItemId and iuom.intItemUOMId = ri.intItemUOMId
    --                INNER JOIN tblICCategory cat on i.intCategoryId = cat.intCategoryId
    --                INNER JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
    --                INNER JOIN tblRKFuturesMonth mnt on cd.intFutureMonthId = mnt.intFutureMonthId
    --                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
    --                LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
    --                LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
    --                LEFT JOIN tblCTPriceFixationDetail pfd ON invD.intInvoiceDetailId = pfd.intInvoiceDetailId
    --                WHERE ch.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
    --                    AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
    --                    AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
    --                    AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(inv.dtmDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
    --                    AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(pfd.dtmFixationDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
    --            ) t
    --            WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
    --            GROUP BY intInventoryShipmentId,strShipmentNumber,intCommodityUnitMeasureId,intCommodityId,strLocationName,strCurrency

				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId)
				SELECT strCommodityCode
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Open Contract' COLLATE Latin1_General_CI_AS
					, dblTotal = CASE WHEN intContractTypeId = 1 THEN SUM(dblTotal) ELSE - SUM(dblTotal) END
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
				FROM (
					SELECT strCommodityCode
						, dblTotal = ISNULL(cd.dblTotal, 0)
						, intContractHeaderId
						, strContractNumber
						, cd.intCommodityId
						, strLocationName
						, intCompanyLocationId
						, intContractTypeId
						, strCurrency
						, intItemId
					FROM @tempFinal cd
					WHERE cd.intCommodityId = @intCommodityId and strType IN('Sale Priced', 'Purchase Priced', 'Purchase HTA', 'Sale HTA')
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
				) t	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, intContractTypeId
					, strCurrency
					, intItemId
		
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName)
				SELECT @strCommodityCode
					, 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
					, 'Collateral' COLLATE Latin1_General_CI_AS strContractType
					, sum(isnull(dblRemainingQuantity,0)) dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
				FROM (
					SELECT CASE WHEN isnull(intContractTypeId,1) = 2 then -dblRemainingQuantity else dblRemainingQuantity end dblRemainingQuantity
						, intContractHeaderId
						, strContractNumber
						, intUnitMeasureId intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intCollateralId
					FROM @tempCollateral c1
					WHERE c1.intLocationId = ISNULL(@intLocationId, c1.intLocationId) AND intCommodityId = @intCommodityId
				) t
				GROUP BY intCommodityId,intFromCommodityUnitMeasureId,intCommodityId,strLocationName
		
				If ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference) = 1)
				BEGIN
					INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intTicketId
						, strTicketNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName)
					SELECT @strCommodityCode
						, 'Price Risk' COLLATE Latin1_General_CI_AS [strType]
						, 'OffSite' COLLATE Latin1_General_CI_AS strContractType
						, sum(dblTotal) dblTotal
						, intTicketId
						, strTicketNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName 
					FROM (
						SELECT intTicketId
							, strTicketNumber
							, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
							, CH.intCompanyLocationId
							, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
						FROM @tblGetStorageDetailByDate CH
						WHERE ysnCustomerStorage = 1
							AND strOwnedPhysicalStock = 'Company'
							AND ysnDPOwnedType <> 1
							AND CH.intCommodityId  = @intCommodityId
							AND CH.intCompanyLocationId = ISNULL(@intLocationId, CH.intCompanyLocationId)
					)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					GROUP BY intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName
				END			
		
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName)
				SELECT strCommodityCode
					,'Basis Risk' COLLATE Latin1_General_CI_AS strType
					, strContractType
					, sum(round(dblTotal,2))
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
				FROM @tempFinal
				WHERE strType = 'Price Risk' and strContractType in('Inventory','Collateral','OffSite', 'Sales In-Transit', 'Purchase In-Transit')
				group by strCommodityCode
					, strContractType
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
		
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency)
				select strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, sum(round(dblTotal,2))
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
				FROM (
					SELECT strCommodityCode
						, intContractHeaderId
						, strContractNumber
						, 'Basis Risk' COLLATE Latin1_General_CI_AS strType
						, strContractType
						, strLocationName
						, strContractEndMonth
						, case when intContractTypeId=1 then (dblTotal) else -(dblTotal) end dblTotal
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, intCompanyLocationId
						, strCurrency
						, intContractTypeId
					from @tempFinal
					WHERE strContractType in('Physical Contract') and strType IN ('Purchase Priced', 'Purchase Basis', 'Sale Priced', 'Sale Basis')
				)t GROUP BY strType
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strContractType
					, strLocationName
					, strContractEndMonth
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId
		
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency)
				SELECT strCommodityCode
					, 'Avail for Spot Sale' COLLATE Latin1_General_CI_AS strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
				from @tempFinal  where strType='Basis Risk' and intCommodityId=@intCommodityId
		
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId)
				SELECT * FROM (
					SELECT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, 'Avail for Spot Sale' COLLATE Latin1_General_CI_AS [strType]
						, strContractType
						, strLocationName
						, RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS strContractEndMonth
						, -(cd.dblBalance) AS dblTotal
						, cd.intUnitMeasureId
						, @intCommodityId as intCommodityId
						, cd.intCompanyLocationId
						, strCurrency
						, intContractTypeId
					FROM @tblGetOpenContractDetail cd
					WHERE  intContractTypeId=1 and strType in('Purchase Priced','Purchase Basis') and cd.intCommodityId=@intCommodityId
						and cd.intCompanyLocationId = isnull(@intLocationId, cd.intCompanyLocationId)
				) t
				WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)	
	 
				INSERT INTO @Final (intCommodityId
					, strType
					, dblTotal
					, strUnitMeasure
					, strLocationName)
				SELECT t.intCommodityId
					, strType
					, dblTotal
					, um.strUnitMeasure
					, strLocationName
				FROM  @tempFinal t
				JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
				JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
				WHERE t.intCommodityId= @intCommodityId
		
				INSERT INTO @Final (intCommodityId
					, strUnitMeasure)
				SELECT top 1 t.intCommodityId
					, um.strUnitMeasure
				FROM tblICCommodity t 
				JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
				JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
				WHERE t.intCommodityId= @intCommodityId  and t.intCommodityId not in(select distinct intCommodityId from @tempFinal)
			END
			ELSE
			BEGIN
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strSubType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId)
				SELECT * FROM (
					SELECT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, cd.strType [strType]
						, [strType] strSubType
						, 'Physical' COLLATE Latin1_General_CI_AS strContractType
						, strLocationName
						, (RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)) COLLATE Latin1_General_CI_AS strContractEndMonth
						, isnull((cd.dblBalance),0) AS dblTotal
						, cd.intUnitMeasureId
						, intCommodityId
						, cd.intCompanyLocationId
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId in(1,2)
						and cd.intCommodityId =@intCommodityId
						AND cd.intCompanyLocationId = ISNULL(@intLocationId,cd.intCompanyLocationId)
						AND intEntityId= @intVendorId
				)t
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)		
		
				INSERT INTO @Final (intCommodityId
					, strType
					, dblTotal
					, strUnitMeasure
					, strLocationName)
				SELECT t.intCommodityId,strType
					, dblTotal
					, um.strUnitMeasure
					, strLocationName
				FROM tblICCommodity c
				LEFT JOIN @tempFinal t on c.intCommodityId=t.intCommodityId
				JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
				JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
				WHERE t.intCommodityId= @intCommodityId
		
				INSERT INTO @Final (intCommodityId
					, strUnitMeasure)
				SELECT top 1 t.intCommodityId
					, um.strUnitMeasure
				FROM tblICCommodity t
				JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
				JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
				WHERE t.intCommodityId= @intCommodityId  and t.intCommodityId not in(select distinct intCommodityId from @tempFinal)
			END
		END
		
		SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
	END
	
	IF(@strByType = 'ByCommodity')
	BEGIN
		SELECT distinct c.strCommodityCode
			, strUnitMeasure
			, strType
			, sum(dblTotal) dblTotal
			, c.intCommodityId
		FROM @Final f
		JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId
		GROUP BY c.strCommodityCode,strUnitMeasure,strType,c.intCommodityId
	END
	ELSE IF(@strByType = 'ByLocation')
	BEGIN
		SELECT DISTINCT c.strCommodityCode
			, strUnitMeasure
			, strType
			, sum(dblTotal) dblTotal
			, c.intCommodityId
			, strLocationName
		FROM tblICCommodity c
		JOIN @Final f on c.intCommodityId= f.intCommodityId
		GROUP BY c.strCommodityCode,strUnitMeasure,strType,c.intCommodityId,strLocationName
	END
END
