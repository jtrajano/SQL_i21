CREATE FUNCTION [dbo].[fnRKGetInHouseAndCompanyTitle] (
	@dtmToDate date
	, @strPositionIncludes nvarchar(50)
	, @intVendorId int)

RETURNS TABLE AS RETURN

WITH InHouse AS (
	SELECT SUM(dblQuantity) as 'InHouse'
		, strCommodity
		, strStockUOM 
		, intCommodityId
	FROM vyuRKGetICStockMovement 
	WHERE intCommodityId IS NOT NULL 
		and strUOM IS NOT NULL
		and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
		and isnull(intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(intEntityId,0) else @intVendorId end 
		AND intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
							WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
																WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
																ELSE isnull(ysnLicensed, 0) END)
	GROUP BY strCommodity,strStockUOM,intCommodityId)
	
, Inventory AS (
	SELECT SUM((dbo.fnCTConvertQuantityToTargetCommodityUOM(intFromCommodityUnitMeasureId,intDefaultCommodityUnitMeasureId,isnull(dblTotal ,0)))) dblTotal
		, intCommodityId
		, strCommodityCode
		, intDefaultUOMId
		, (SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure UM WHERE intUnitMeasureId = intDefaultUOMId) AS strDefaultUOM
		, intLocationId
		, strLocationName
	FROM (
		SELECT sum(isnull(s.dblQuantity ,0)) as dblTotal
			, i.intCommodityId intCommodityId
			, c.strCommodityCode
			, ium.intCommodityUnitMeasureId intFromCommodityUnitMeasureId
			, s.strUOM
			, (SELECT intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = i.intCommodityId AND ysnDefault = 1) AS intDefaultCommodityUnitMeasureId
			, (SELECT intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = i.intCommodityId AND ysnDefault = 1) AS intDefaultUOMId
			, s.intLocationId 
			, s.strLocationName
		FROM vyuRKGetInventoryValuation s  		
		JOIN tblICItem i on i.intItemId=s.intItemId
		JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId  
		JOIN tblICCommodity c on i.intCommodityId = c.intCommodityId 
		WHERE s.dblQuantity <> 0
			AND iuom.ysnStockUnit = 1
			AND s.ysnInTransit = 0
			AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			and isnull(s.intEntityId,0) = case when isnull(@intVendorId,0)=0 then isnull(s.intEntityId,0) else @intVendorId end
			AND s.intLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
																		WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
																		ELSE isnull(ysnLicensed, 0) END)
		GROUP BY i.intCommodityId
			, c.strCommodityCode
			, ium.intCommodityUnitMeasureId
			, s.strUOM
			, iuom.intUnitMeasureId
			, s.strLocationName
			, s.intLocationId
	) invData
	WHERE dblTotal <> 0
	GROUP BY intCommodityId
		, strCommodityCode
		, intDefaultCommodityUnitMeasureId
		, intDefaultUOMId
		, strLocationName
		, intLocationId)
		
, Storage AS (
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
		, CM.strCommodityCode
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
		, strUnitMeasure
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	JOIN tblICUnitMeasure um on ium.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
	left join tblSCTicket t on t.intTicketId=gh.intTicketId
	WHERE ISNULL(a.strStorageType,'') <> 'ITR'  and isnull(a.intDeliverySheetId,0) =0 and isnull(strTicketStatus,'') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
		AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)<=convert(datetime,@dtmToDate)

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
		, CM.strCommodityCode
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
		, i.intItemId as intItemId  ,null intTicketId,'' strTicketNumber
		, strUnitMeasure
	FROM tblGRStorageHistory gh
	JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
	JOIN tblICItem i on i.intItemId=a.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	JOIN tblICUnitMeasure um on ium.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
	JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
	JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
	WHERE ISNULL(a.strStorageType,'') <> 'ITR'  and isnull(a.intDeliverySheetId,0) <>0 and gh.intTransactionTypeId IN (1,3,4,5,9)
		AND convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)<=convert(datetime,@dtmToDate))
		
, OpenContract AS (
	SELECT strCommodityCode
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
		, intCommodityUnitMeasureId
		, intContractDetailId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strType
		, intItemId
		, strItemNo
		, strEntityName
		, strCustomerContract
		, NULL intFutureMarketId
		, NULL intFutureMonthId
		, strCurrency
	FROM vyuRKContractDetail CD
	WHERE CD.intContractStatusId <> 6 AND convert(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate)

, Collateral AS (
	SELECT c.intCollateralId
		, cl.strLocationName
		, ch.strItemNo
		, ch.strEntityName
		, c.intReceiptNo
		, ch.intContractHeaderId
		, strContractNumber
		, c.dtmOpenDate
		, isnull(c.dblOriginalQuantity,0) dblOriginalQuantity
		, isnull(c.dblRemainingQuantity,0) dblRemainingQuantity
		, c.intCommodityId as intCommodityId
		, c.intUnitMeasureId
		, c.intLocationId intCompanyLocationId
		, case when c.strType='Purchase' then 1 else 2 end intContractTypeId
		, c.intLocationId,intEntityId
	FROM tblRKCollateral c
	JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
	LEFT JOIN OpenContract ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= convert(datetime,@dtmToDate)
		AND c.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
																	WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
																	ELSE isnull(ysnLicensed, 0) END))

--In-House
SELECT strCommodity as strCommodityCode
	, strStockUOM as strUnitMeasure
	, 'In-House' COLLATE Latin1_General_CI_AS as strSeqHeader
	, InHouse as dblTotal 
	, intCommodityId
FROM InHouse A
WHERE InHouse <> 0

--Company Titled
UNION ALL SELECT strCommodityCode 
	, strUnitMeasure
	, 'Company Titled Stock' COLLATE Latin1_General_CI_AS as strSeqHeader
	, sum(dblTotal) as dblTotal 
	, intCommodityId
FROM (
	SELECT strCommodityCode
		, strUnitMeasure
		, CASE WHEN (SELECT ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference) = 0 THEN -SUM(Balance) ELSE 0 END as dblTotal
		, intCommodityId
	FROM Storage
	WHERE ysnDPOwnedType = 1
	group by strCommodityCode, strUnitMeasure, intCommodityId
	
	UNION ALL SELECT strCommodityCode
		, strDefaultUOM
		, sum(dblTotal) as dblTotal
		, intCommodityId
	FROM Inventory
	group by strCommodityCode,strDefaultUOM,intCommodityId
) t 
WHERE intCommodityId = CASE WHEN ISNULL(@intVendorId,0) = 0 THEN intCommodityId ELSE 0 END
GROUP BY strCommodityCode, strUnitMeasure, intCommodityId