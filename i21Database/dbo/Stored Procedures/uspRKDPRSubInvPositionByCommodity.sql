CREATE PROCEDURE [dbo].[uspRKDPRSubInvPositionByCommodity]
	@intCommodityId nvarchar(max)
	,@intLocationId int = NULL
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(250) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
	,@dtmToDate datetime=null
	,@strByType nvarchar(50) = null

AS

BEGIN
	SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	DECLARE @ysnDisplayAllStorage bit
	DECLARE @ysnIncludeDPPurchasesInCompanyTitled bit
	
	SELECT @ysnDisplayAllStorage = ISNULL(ysnDisplayAllStorage, 0)
		, @ysnIncludeDPPurchasesInCompanyTitled = ISNULL(ysnIncludeDPPurchasesInCompanyTitled, 0)
	FROM tblRKCompanyPreference
	
	DECLARE @Commodity AS TABLE (intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY
		, intCommodity INT)
	
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
	
	IF ISNULL(@strPurchaseSales,'') <> ''
	BEGIN
		IF @strPurchaseSales='Purchase'
		BEGIN
			SELECT @strPurchaseSales='Sales'
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
	
	DECLARE @Final AS TABLE (intRow int IDENTITY(1,1) PRIMARY KEY
		, intSeqId int
		, strSeqHeader nvarchar(100) COLLATE Latin1_General_CI_AS
		, strCommodityCode nvarchar(100) COLLATE Latin1_General_CI_AS
		, strType nvarchar(100) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intCollateralId int
		, strLocationName nvarchar(250) COLLATE Latin1_General_CI_AS
		, strCustomer nvarchar(250) COLLATE Latin1_General_CI_AS
		, intReceiptNo nvarchar(250) COLLATE Latin1_General_CI_AS
		, intContractHeaderId int
		, strContractNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, strCustomerReference nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDistributionOption nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDPAReceiptNo nvarchar(100) COLLATE Latin1_General_CI_AS
		, dblDiscDue DECIMAL(24,10)
		, [Storage Due] DECIMAL(24,10)
		, dtmLastStorageAccrueDate datetime
		, strScheduleId nvarchar(100) COLLATE Latin1_General_CI_AS
		, strTicket nvarchar(100) COLLATE Latin1_General_CI_AS
		, dtmOpenDate datetime
		, dtmDeliveryDate datetime
		, dtmTicketDateTime datetime
		, dblOriginalQuantity  DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId int
		, strItemNo nvarchar(100) COLLATE Latin1_General_CI_AS
		, strUnitMeasure nvarchar(100) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strTruckName  nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDriverName  nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCompanyLocationId int
		, intStorageScheduleTypeId int
		, intItemId int
		, intTicketId int
		, strTicketNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, strShipmentNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId int
		, intInventoryReceiptId int
		, strReceiptNumber  nvarchar(100) COLLATE Latin1_General_CI_AS)
	
	DECLARE @FinalTable AS TABLE (intRow int IDENTITY(1,1) PRIMARY KEY
		, intSeqId int
		, strSeqHeader nvarchar(100) COLLATE Latin1_General_CI_AS
		, strCommodityCode nvarchar(100) COLLATE Latin1_General_CI_AS
		, strType nvarchar(100) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intCollateralId int
		, strLocationName nvarchar(250) COLLATE Latin1_General_CI_AS
		, strCustomer nvarchar(250) COLLATE Latin1_General_CI_AS
		, intReceiptNo nvarchar(250) COLLATE Latin1_General_CI_AS
		, intContractHeaderId int
		, strContractNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, strCustomerReference nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDistributionOption nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDPAReceiptNo nvarchar(100) COLLATE Latin1_General_CI_AS
		, dblDiscDue DECIMAL(24,10)
		, [Storage Due] DECIMAL(24,10)
		, dtmLastStorageAccrueDate datetime
		, strScheduleId nvarchar(100) COLLATE Latin1_General_CI_AS
		, strTicket nvarchar(100) COLLATE Latin1_General_CI_AS
		, dtmOpenDate datetime
		, dtmDeliveryDate datetime
		, dtmTicketDateTime datetime
		, dblOriginalQuantity  DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId int
		, strItemNo nvarchar(100) COLLATE Latin1_General_CI_AS
		, strUnitMeasure nvarchar(100) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strTruckName  nvarchar(100) COLLATE Latin1_General_CI_AS
		, strDriverName  nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCompanyLocationId int
		, intItemId int
		, intTicketId int
		, strTicketNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, strShipmentNumber nvarchar(100) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId int
		, intInventoryReceiptId int
		, strReceiptNumber  nvarchar(100) COLLATE Latin1_General_CI_AS)
		
	--===============================
	-- CONTRACTS
	--================================
	DECLARE @tblGetOpenContractDetail TABLE (intRowNum int
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intContractHeaderId int
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmEndDate datetime
		, dblBalance DECIMAL(24,10)
		, intUnitMeasureId int
		, intPricingTypeId int
		, intContractTypeId int
		, intCompanyLocationId int
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityUnitMeasureId int
		, intContractDetailId int
		, intContractStatusId int
		, intEntityId int
		, intCurrencyId int
		, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intItemId int
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmContractDate datetime
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCustomerContract NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutureMarketId int
		, intFutureMonthId int
		, strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS)

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
		, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) COLLATE Latin1_General_CI_AS
		, intItemId
		, strItemNo
		, strEntityName = CD.strCustomer
		, NULL intFutureMarketId
		, NULL intFutureMonthId
		, strCurrency 
	FROM tblCTContractBalance CD
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate 
		AND CD.intCommodityId in (select intCommodity from @Commodity)
		AND CD.dtmStartDate = '01-01-1900' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate

	--=============================================================
	-- STORAGE
	--=============================================================
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
		, (case when gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' then -gh.dblUnits else gh.dblUnits   end) [Balance]
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
		, t.intTicketId
		, t.strTicketNumber
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId AND ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
	LEFT JOIN tblSCTicket t on t.intTicketId=gh.intTicketId
	WHERE ISNULL(a.strStorageType,'') <> 'ITR'  
		AND ISNULL(a.intDeliverySheetId, 0) = 0 
		AND ISNULL(strTicketStatus,'') <> 'V' 
		AND gh.intTransactionTypeId IN (1,3,4,5,9)
		AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
		AND i.intCommodityId in (select intCommodity from @Commodity)

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
		, (case when gh.strType ='Reduced By Inventory Shipment'  OR gh.strType = 'Settlement' then -gh.dblUnits else gh.dblUnits   end) [Balance]
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
		, '' COLLATE Latin1_General_CI_AS strTicketNumber
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId AND ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
	WHERE ISNULL(a.strStorageType,'') <> 'ITR'  
		AND ISNULL(a.intDeliverySheetId, 0) <>0 
		AND gh.intTransactionTypeId IN (1,3,4,5,9)
		AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate) 
		AND i.intCommodityId in (select intCommodity from @Commodity)


	--========================================
	-- COLLATERAL
	--=========================================
	DECLARE @tempCollateral TABLE (intRowNum int
		, intCollateralId int
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		, intEntityId int
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS)

	INSERT INTO @tempCollateral
	SELECT * 
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmOpenDate DESC) intRowNum
			, c.intCollateralId
			, cl.strLocationName
			, ch.strItemNo
			, ch.strEntityName
			, c.intReceiptNo
			, ch.intContractHeaderId
			, strContractNumber
			,  c.dtmOpenDate
			, ISNULL(c.dblOriginalQuantity, 0) dblOriginalQuantity
			, ISNULL(c.dblRemainingQuantity, 0) dblRemainingQuantity
			, c.intCommodityId as intCommodityId
			, c.intUnitMeasureId
			, c.intLocationId intCompanyLocationId
			, case when c.strType='Purchase' then 1 else 2 end	intContractTypeId
			, c.intLocationId,intEntityId,co.strCommodityCode
		FROM tblRKCollateral c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId AND ch.intContractStatusId <> 3
		WHERE c.intCommodityId in (select intCommodity from @Commodity)
			AND convert(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= convert(datetime,@dtmToDate) 
			AND  c.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)						
	) a WHERE a.intRowNum =1


	--========================
	-- INVENTORY VALUATION
	--========================
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
		, strTicketStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intEntityId INT)

	INSERT INTO @invQty
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))
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
		, s.intEntityId
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
	LEFT JOIN tblSCTicket t on s.intSourceId = t.intTicketId
	WHERE i.intCommodityId in (select intCommodity from @Commodity) AND ISNULL(s.dblQuantity, 0) <>0 
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) AND ISNULL(strTicketStatus,'') <> 'V'
		AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
		AND ysnInTransit = 0
		AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--========================
	-- ON HOLD
	--========================

	DECLARE @tempOnHold TABLE (dblTotal numeric(24,10)
		, strCustomer NVARCHAR(200)	COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intCommodityUnitMeasureId int
		, intLocationId int
		, intEntityId int)

	INSERT INTO @tempOnHold(dblTotal
		, strCustomer
		, strLocationName
		, intCommodityId
		, intCommodityUnitMeasureId
		, intLocationId
		, intEntityId)
	SELECT dblTotal
		, strCustomer
		, strLocationName
		, intCommodityId
		, intCommodityUnitMeasureId
		, intLocationId
		, intEntityId
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY st.intTicketId ORDER BY st.dtmTicketDateTime DESC) intSeqId
			, case when st.strInOutFlag = 'I' then  st.dblNetUnits else abs(st.dblNetUnits) * -1 end  AS dblTotal
			, strName strCustomer
			, cl.strLocationName
			, st.intCommodityId
			, intCommodityUnitMeasureId
			, st.intProcessingLocationId intLocationId
			, e.intEntityId
		FROM tblSCTicket st
		JOIN tblEMEntity e on e.intEntityId= st.intEntityId
		JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId AND st.strDistributionOption='HLD'
		JOIN tblICItem i1 on i1.intItemId=st.intItemId
		JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId AND ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
		WHERE i1.intCommodityId  in(select intCommodity from @Commodity)
			AND ISNULL(st.intDeliverySheetId, 0) =0
			AND st.intProcessingLocationId  = ISNULL(@intLocationId, st.intProcessingLocationId)
			AND convert(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
			AND ISNULL(strTicketStatus,'') = 'H'
	)t 	
	WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		AND t.intSeqId =1 

	--========================
	-- Building of data
	--========================

	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription nvarchar(250)
	DECLARE @intCommodityUnitMeasureId int

	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity where intCommodity>0

	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId=@intCommodityId AND ysnDefault=1

		IF ISNULL(@intCommodityId, 0) > 0
		BEGIN
			IF ISNULL(@intVendorId, 0) = 0
			BEGIN
				--Inventory
				INSERT INTO @Final(intSeqId
					, strSeqHeader
					, strType
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId
					, strDistributionOption)
				SELECT intSeqId
					, strSeqHeader
					, strType
					, (dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(dblTotal , 0))) dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId 
					, strDistributionOption
				FROM(
					SELECT 1 AS intSeqId
						, 'In-House' COLLATE Latin1_General_CI_AS strSeqHeader
						, 'Receipt' COLLATE Latin1_General_CI_AS as [strType]
						, ISNULL(dblTotal, 0) dblTotal
						, strLocationName
						, intItemId
						, strItemNo
						, intCommodityId
						, intFromCommodityUnitMeasureId
						, intLocationId intCompanyLocationId
						, strDistributionOption
					FROM @invQty 
					WHERE intCommodityId = @intCommodityId 
						AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
				)t
			END

			--Contracts
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT 1 intSeqId
				, strSeqHeader
				, strType,dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId 
			FROM(
				SELECT 'In-House' COLLATE Latin1_General_CI_AS strSeqHeader
					, [Storage Type] AS [strType]
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,Balance)  dblTotal
					, strName strCustomer
					, intTicketId
					, strTicketNumber
					, [Delivery Date] dtmDeliveryDate
					, strLocationName
					, strItemNo
					, intCommodityId
					, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
					, intCompanyLocationId
				FROM @tblGetStorageDetailByDate s
				JOIN tblEMEntity e on e.intEntityId= s.intEntityId
				WHERE intCommodityId = @intCommodityId 
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
					AND ysnDPOwnedType <> 1 
					AND strOwnedPhysicalStock <> 'Company' --Remove DP type storage in in-house. Stock already increases in IR.
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			)t 

			--On Hold
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType
				, sum(dblTotal) dblTotal
				, strLocationName
				, intCommodityId
				, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
				, intCompanyLocationId 
			FROM(
				SELECT DISTINCT 1 intSeqId
					, 'In-House' COLLATE Latin1_General_CI_AS strSeqHeader
					, 'On-Hold' COLLATE Latin1_General_CI_AS strType
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,dblTotal) dblTotal
					, strCustomer
					, strLocationName
					, intCommodityId
					, intCommodityUnitMeasureId
					, intLocationId intCompanyLocationId
				from @tempOnHold
				where intCommodityId = @intCommodityId
					AND ISNULL(intEntityId, 0) = case when ISNULL(@intVendorId, 0)=0 then ISNULL(intEntityId, 0) else @intVendorId end
			)t
			GROUP BY intSeqId,strSeqHeader,strType,strCustomer,strLocationName,intCommodityId,intCommodityUnitMeasureId,intCompanyLocationId
	
			--Collatral Sale
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intUnitMeasureId intFromCommodityUnitMeasureId
				, intCompanyLocationId 
			FROM (
				select 8 intSeqId
					, 'Collateral Receipts - Sales' COLLATE Latin1_General_CI_AS strSeqHeader
					, strCommodityCode
					, 'Collateral Receipts - Sales' COLLATE Latin1_General_CI_AS strType
					, dblRemainingQuantity dblTotal
					, intCollateralId
					, strLocationName
					, strItemNo
					, strEntityName
					, intReceiptNo
					, intContractHeaderId
					, strContractNumber
					, dtmOpenDate
					, dblOriginalQuantity
					, dblRemainingQuantity 
					, intCommodityId
					, intUnitMeasureId
					, intCompanyLocationId
				from @tempCollateral
				where intContractTypeId = 2 
					AND intCommodityId = @intCommodityId
					AND intLocationId = ISNULL(@intLocationId, intLocationId)
					AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
			)t 
			WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
			-- Collatral Purchase
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intUnitMeasureId
				, intCompanyLocationId 
			FROM (
				select 9 intSeqId
					, 'Collateral Receipts - Purchase' COLLATE Latin1_General_CI_AS strSeqHeader
					, strCommodityCode
					, 'Collateral Receipts - Purchase' COLLATE Latin1_General_CI_AS strType
					, dblRemainingQuantity  dblTotal
					, intCollateralId
					, strLocationName
					, strItemNo
					, strEntityName
					, intReceiptNo
					, intContractHeaderId
					, strContractNumber
					, dtmOpenDate
					, dblOriginalQuantity
					, dblRemainingQuantity
					, intCommodityId
					, intUnitMeasureId
					, intCompanyLocationId
				from @tempCollateral 
				where intContractTypeId = 1 
					AND intCommodityId = @intCommodityId
					AND intLocationId = ISNULL(@intLocationId, intLocationId)
					AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
			)t
			WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			-- Sales Basis Deliveries
			INSERT INTO @Final (intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intUnitMeasureId intFromCommodityUnitMeasureId
				, intCompanyLocationId 
			FROM (
				select distinct 14 intSeqId
					, 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS strSeqHeader
					, @strDescription strCommodityCode
					, 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS strType
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ri.dblQuantity, 0)) AS dblTotal
					, cd.intCommodityId
					, cl.strLocationName
					, cd.strItemNo
					, strContractNumber strTicketNumber
					, cd.dtmContractDate as dtmTicketDateTime
					, cd.strCustomerContract as strCustomerReference
					, 'CNT' COLLATE Latin1_General_CI_AS as strDistributionOption
					, cd.intUnitMeasureId
					, cl.intCompanyLocationId
					, r.strShipmentNumber
					, cd.strContractNumber
					, r.intInventoryShipmentId
					, r.strShipmentNumber strShipmentNumber1
				from vyuRKGetInventoryValuation v
				join tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
				inner join tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
				inner join @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
				join tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId
				inner join tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
				left join tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				left join tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
				where cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
					AND cl.intCompanyLocationId  = ISNULL(@intLocationId, cl.intCompanyLocationId)
					AND convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
					AND inv.intInvoiceId IS NULL
			)t
			WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--Company Title
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType
				, sum(dblTotal) dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId 
			FROM (
				select 15 intSeqId
					, 'Company Titled Stock' COLLATE Latin1_General_CI_AS strSeqHeader
					, strCommodityCode
					, 'Receipt' COLLATE Latin1_General_CI_AS strType
					, dblTotal 
					, strLocationName
					, intItemId
					, strItemNo
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId 
				from @Final 
				where strSeqHeader='In-House' 
					AND strType='Receipt' 
					AND intCommodityId =@intCommodityId
					--AND ISNULL(strDistributionOption,'') <> 'DP' Will going to include DP here but subtract in the bottom using the company pref
			)t
			GROUP BY intSeqId,strSeqHeader,strType,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId

			-- Company Title with Collateral
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strLocationName)
			SELECT * 
			FROM (
				select distinct intSeqId
					, strSeqHeader
					, strCommodityCode
					, strType
					, sum(dblTotal) dblTotal 
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strLocationName 
				from(
					SELECT 15 AS intSeqId
						, 'Company Titled Stock' COLLATE Latin1_General_CI_AS strSeqHeader 
						, strCommodityCode
						, [strType]
						, case when strType = 'Collateral Receipts - Purchase' then ISNULL(dblTotal, 0) else -ISNULL(dblTotal, 0) end dblTotal
						, intCommodityId
						, intFromCommodityUnitMeasureId
						, strLocationName strLocationName
					FROM @Final 
					WHERE intSeqId in (9,8) 
						AND strType in('Collateral Receipts - Purchase','Collateral Receipts - Sales') 
						AND intCommodityId =@intCommodityId 
				)t
				group by intSeqId,strSeqHeader,strCommodityCode,strType,intCommodityId,intFromCommodityUnitMeasureId,strLocationName
			) t 
			WHERE dblTotal<>0
		 		

			IF ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1)
			BEGIN
				INSERT INTO @Final (intSeqId
					, strSeqHeader
					, strType,dblTotal
					, intCommodityId
					, strLocationName
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId)
				SELECT 15 intSeqId
					, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
					, 'Off-Site' COLLATE Latin1_General_CI_AS
					, dblTotal
					, intCommodityId
					, strLocation
					, intCommodityUnitMeasureId intFromCommodityUnitMeasureId 
					, intCompanyLocationId 
				FROM (
					select dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal
						, CH.intCommodityId
						, Loc AS strLocation
						, i.strItemNo 
						, [Delivery Date] AS dtmDeliveryDate 
						, ium.intCommodityUnitMeasureId
						, Ticket strTicket 
						, Customer as strCustomerReference 
						, Receipt AS strDPAReceiptNo 
						, [Disc Due] AS dblDiscDue 
						, [Storage Due] AS [Storage Due] 
						, dtmLastStorageAccrueDate 
						, strScheduleId
						, intCompanyLocationId
						, intTicketId
						, strTicketNumber
					from @tblGetStorageDetailByDate CH
					join tblICItem i on CH.intItemId=i.intItemId
					join tblICItemUOM iuom on i.intItemId=iuom.intItemId AND ysnStockUnit=1
					join tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
					where ysnCustomerStorage = 1	
						AND strOwnedPhysicalStock = 'Company' 
						AND ysnDPOwnedType <> 1
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId = ISNULL(@intLocationId, CH.intCompanyLocationId)
						AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
				)t 
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			END

			If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
			BEGIN		
				INSERT INTO @Final(intSeqId
					, strSeqHeader
					, strType
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId)
				SELECT 15 intSeqId
					, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
					, 'DP' COLLATE Latin1_General_CI_AS
					, -sum(dblTotal) dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, intCompanyLocationId  
				FROM(
					select intTicketId
						, strTicketNumber
						, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(ISNULL(Balance, 0))) dblTotal
						, ch.intCompanyLocationId
						, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
					from @tblGetStorageDetailByDate ch
					where ch.intCommodityId = @intCommodityId	
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
						AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
				)t 	
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY intTicketId,strTicketNumber,intFromCommodityUnitMeasureId,intCommodityId,strLocationName,intCompanyLocationId

			END
			
			DECLARE @intUnitMeasureId int
			DECLARE @strUnitMeasure nvarchar(250)
			SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
			select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId

			INSERT INTO @FinalTable (intSeqId
				, strSeqHeader
				, strType
				, dblTotal
				, strUnitMeasure
				, strLocationName
				, intCommodityId
				, intCompanyLocationId)
			SELECT intSeqId
				, strSeqHeader
				, strType 
				, Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when ISNULL(@intUnitMeasureId, 0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal
				, case when ISNULL(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure
				, strLocationName
				, t.intCommodityId
				, intCompanyLocationId
			FROM @Final  t
			LEFT JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId AND cuc.ysnDefault=1
			LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId AND @intUnitMeasureId=cuc1.intUnitMeasureId
			WHERE t.intCommodityId = @intCommodityId
		END

		SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
	END
END --End Begin

DROP TABLE #LicensedLocation

IF (@strByType = 'ByLocation')
BEGIN
	SELECT c.strCommodityCode
		, strUnitMeasure
		, strSeqHeader
		, sum(dblTotal) dblTotal
		, f.intCommodityId
		, strLocationName
	FROM @FinalTable f
	JOIN tblICCommodity c on c.intCommodityId= f.intCommodityId
	GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId,strLocationName
END
ELSE
IF (@strByType = 'ByCommodity')
BEGIN
	SELECT c.strCommodityCode
		, strUnitMeasure
		, strSeqHeader
		, SUM(dblTotal) dblTotal
		, f.intCommodityId
	FROM @FinalTable f
	JOIN tblICCommodity c on c.intCommodityId = f.intCommodityId
	GROUP BY c.strCommodityCode,strUnitMeasure,strSeqHeader,f.intCommodityId 
END