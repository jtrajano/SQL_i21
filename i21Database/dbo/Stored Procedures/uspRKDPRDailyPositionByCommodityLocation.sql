CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation]
	 @intCommodityId NVARCHAR(max) = ''
	,@intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate datetime = NULL

AS

BEGIN
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
DECLARE @ysnDisplayAllStorage bit
select @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) from tblRKCompanyPreference

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  


DECLARE @Final AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250)  COLLATE Latin1_General_CI_AS,
					strCustomer nvarchar(250),
					intReceiptNo nvarchar(250),
					intContractHeaderId int,
					strContractNumber nvarchar(100),
					strCustomerReference nvarchar(100),
					strDistributionOption nvarchar(100),
					strDPAReceiptNo nvarchar(100),
					dblDiscDue DECIMAL(24,10),
					[Storage Due] DECIMAL(24,10),	
					dtmLastStorageAccrueDate datetime,
					strScheduleId nvarchar(100),
					strTicket nvarchar(100),
					dtmOpenDate datetime,
					dtmDeliveryDate datetime,
					dtmTicketDateTime datetime,
					dblOriginalQuantity  DECIMAL(24,10),
					dblRemainingQuantity DECIMAL(24,10),
					intCommodityId int,
					strItemNo nvarchar(100),
					strUnitMeasure nvarchar(100)
					,intFromCommodityUnitMeasureId int
					,intToCommodityUnitMeasureId int
					,strTruckName  nvarchar(100)
					,strDriverName  nvarchar(100)
					,intCompanyLocationId int
					,intStorageScheduleTypeId int
					,intEntityId int
)

DECLARE @FinalTable AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250)  COLLATE Latin1_General_CI_AS,
					strCustomer nvarchar(250),
					intReceiptNo nvarchar(250),
					intContractHeaderId int,
					strContractNumber nvarchar(100),
					strCustomerReference nvarchar(100),
					strDistributionOption nvarchar(100),
					strDPAReceiptNo nvarchar(100),
					dblDiscDue DECIMAL(24,10),
					[Storage Due] DECIMAL(24,10),	
					dtmLastStorageAccrueDate datetime,
					strScheduleId nvarchar(100),
					strTicket nvarchar(100),
					dtmOpenDate datetime,
					dtmDeliveryDate datetime,
					dtmTicketDateTime datetime,
					dblOriginalQuantity  DECIMAL(24,10),
					dblRemainingQuantity DECIMAL(24,10),
					intCommodityId int,
					strItemNo nvarchar(100),
					strUnitMeasure nvarchar(100)
					,intFromCommodityUnitMeasureId int
					,intToCommodityUnitMeasureId int
					,strTruckName  nvarchar(100)
					,strDriverName  nvarchar(100)
					,intCompanyLocationId int
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription nvarchar(250)
declare @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity where intCommodity>0

WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strDescription = strCommodityCode	FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and ysnDefault=1

if isnull(@intCommodityId,0) > 0
BEGIN

IF OBJECT_ID('tempdb..#invQty') IS NOT NULL
    DROP TABLE #invQty
IF OBJECT_ID('tempdb..#tempCollateral') IS NOT NULL
    DROP TABLE #tempCollateral

IF OBJECT_ID('tempdb..#tempCollateral') IS NOT NULL
    DROP TABLE #tempCollateral
IF OBJECT_ID('tempdb..#tempOnHold') IS NOT NULL
    DROP TABLE #tempOnHold

IF OBJECT_ID('tempdb..#invPurBasisDelivary') IS NOT NULL
    DROP TABLE #invPurBasisDelivary

IF OBJECT_ID('tempdb..#invQty1') IS NOT NULL
    DROP TABLE #invQty1

DECLARE @tblGetOpenFutureByDate TABLE (
		intFutOptTransactionId int, 
		intOpenContract  int)
INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId,intOpenContract)
EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  nvarchar(100),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  nvarchar(100),
		strLocationName  nvarchar(100)  COLLATE Latin1_General_CI_AS,
		dtmEndDate datetime,
		dblBalance DECIMAL(24,10),
		intUnitMeasureId int, 	
		intPricingTypeId int,
		intContractTypeId int,
		intCompanyLocationId int,
		strContractType  nvarchar(100), 
		strPricingType  nvarchar(100),
		intCommodityUnitMeasureId int,
		intContractDetailId int,
		intContractStatusId int,
		intEntityId int,
		intCurrencyId int,
		strType	  nvarchar(100),
		intItemId int,
		strItemNo  nvarchar(100),
		dtmContractDate datetime,
		strEntityName  nvarchar(100),
		strCustomerContract  nvarchar(100)
				,intFutureMarketId int
		,intFutureMonthId int)

DECLARE @tblGetStorageDetailByDate TABLE (
		intRowNum int, 
		intCustomerStorageId int,
		intCompanyLocationId int	
		,[Loc] nvarchar(100)
		,[Delivery Date] datetime
		,[Ticket] nvarchar(100)
		,intEntityId int
		,[Customer] nvarchar(100)
		,[Receipt] nvarchar(100)
		,[Disc Due] numeric(24,10)
		,[Storage Due] numeric(24,10)
		,[Balance] numeric(24,10)
		,intStorageTypeId int
		,[Storage Type] nvarchar(100)
		,intCommodityId int
		,[Commodity Code] nvarchar(100)
		,[Commodity Description] nvarchar(100)
		,strOwnedPhysicalStock nvarchar(100)
		,ysnReceiptedStorage bit
		,ysnDPOwnedType bit
		,ysnGrainBankType bit
		,ysnCustomerStorage bit
		,strCustomerReference  nvarchar(100)
 		,dtmLastStorageAccrueDate  datetime
 		,strScheduleId nvarchar(100)
		,strItemNo nvarchar(100)
		,strLocationName nvarchar(100)  COLLATE Latin1_General_CI_AS
		,intCommodityUnitMeasureId int
		,intItemId int)

DECLARE @tblGetStorageOffSiteDetail TABLE (
intRowNum int,
intCustomerStorageId int
,intCompanyLocationId	int
,[Loc] nvarchar(100)
,[Delivery Date] datetime
,[Ticket] nvarchar(100)
,intEntityId int
,[Customer] nvarchar(100)
,[Receipt] nvarchar(100)
,[Disc Due] numeric(24,10)
,[Storage Due] numeric(24,10)
,[Balance] numeric(24,10)
,intStorageTypeId int
,[Storage Type] nvarchar(100)
,intCommodityId int
,[Commodity Code] nvarchar(100)
,[Commodity Description] nvarchar(100)
,strOwnedPhysicalStock nvarchar(100)
,ysnReceiptedStorage bit
,ysnDPOwnedType bit
,ysnGrainBankType bit
,ysnCustomerStorage bit
,strCustomerReference  nvarchar(100)
,dtmLastStorageAccrueDate  datetime
,strScheduleId nvarchar(100)
,ysnExternal bit
,intItemId  int	 
,dtmDistributionDate datetime)

DECLARE @tblGetSalesIntransitWOPickLot TABLE (
 strTicket nvarchar(100),
 strContractNumber nvarchar(100)
,dblShipmentQty	numeric(24,10)
,intCompanyLocationId int
,strLocationName nvarchar(100)
,intContractDetailId int
,dblInvoiceQty numeric(24,10)
,dblBalanceToInvoice numeric(24,10)
,intCommodityId int
,strItemName nvarchar(100)
,intUnitMeasureId int
,intEntityId int
,strCustomerReference nvarchar(100)
)
declare @strName nvarchar(50) = null
select @strName=strName from  tblEMEntity where intEntityId=@intVendorId

INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
	   	   ,intFutureMarketId,intFutureMonthId)
EXEC uspRKDPRContractDetail @intCommodityId, @dtmToDate

INSERT INTO @tblGetStorageDetailByDate
EXEC uspRKGetStorageDetailByDate @intCommodityId, @dtmToDate

INSERT INTO @tblGetStorageOffSiteDetail
EXEC uspRKGetStorageOffSiteDetail @intCommodityId, @dtmToDate

INSERT INTO @tblGetSalesIntransitWOPickLot
EXEC uspRKDPRSalesIntransitWOPickLot @intCommodityId, @dtmToDate


IF OBJECT_ID('tempdb..#tempDeliverySheet') IS NOT NULL
DROP TABLE #tempDeliverySheet

SELECT [Storage Type] as [Storage Type], strCommodityCode,strType,
	 sum(dblTotal) dblTotal,	
	intCommodityId,strLocationName,strItemNo,dtmDelivarydate,
	 strTicket,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intEntityId,strOwnedPhysicalStock,ysnReceiptedStorage,intStorageScheduleTypeId 
	 INTO #tempDeliverySheet from(
SELECT * FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY   GR1.intCustomerStorageId ORDER BY dtmDistributionDate DESC) intRowNum,  GR1.intCustomerStorageId,GR.strStorageTypeDescription [Storage Type],@strDescription strCommodityCode,GR.strStorageTypeDescription strType,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,GR1.dblUnits) dblTotal,	
	strName strCustomerReference,strDeliverySheetNumber strTicket,CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDeliverySheetDate ,110),110) dtmDelivarydate,
	l.strLocationName strLocationName,i.strItemNo,
	SCT.intCommodityId intCommodityId, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,null [Storage Due],l.intCompanyLocationId  intCompanyLocationId	
	, E.intEntityId , strOwnedPhysicalStock,ysnReceiptedStorage,GR.intStorageScheduleTypeId
	FROM tblSCDeliverySheet SCD 
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
	INNER JOIN tblGRStorageHistory GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId	
	JOIN tblGRCustomerStorage SCDS on SCDS.intCustomerStorageId = GR1.intCustomerStorageId
	INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	LEFT  JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0   and isnull(SCD.ysnPost,0) =1
	AND SCT.intCommodityId = @intCommodityId  --AND isnull(GR.intStorageScheduleTypeId,0) > 0	
	and  convert(DATETIME, CONVERT(VARCHAR(10), dtmDistributionDate, 110), 110) <= convert(datetime,@dtmToDate)
)a WHERE a.intRowNum =1 	
	UNION
SELECT * FROM (
	SELECT ROW_NUMBER() OVER (PARTITION BY SCDS.intDeliverySheetSplitId ORDER BY dtmDeliverySheetHistoryDate DESC) intRowNum, 
		SCDS.intDeliverySheetSplitId, GR.strStorageTypeDescription [Storage Type],@strDescription strCommodityCode,GR.strStorageTypeDescription strType,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal,
	strName strCustomerReference,strDeliverySheetNumber+('*') strTicket,convert(datetime,CONVERT(VARCHAR(10),dtmDeliverySheetDate ,110),110) dtmDelivarydate,l.strLocationName strLocationName,i.strItemNo,
	SCT.intCommodityId intCommodityId, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,null [Storage Due],l.intCompanyLocationId  intCompanyLocationId
	, E.intEntityId , strOwnedPhysicalStock,ysnReceiptedStorage,GR.intStorageScheduleTypeId
	FROM tblSCDeliverySheet SCD
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
	INNER JOIN tblICItem i on i.intItemId=SCD.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0 and isnull(SCD.ysnPost,0) = 0
	AND SCT.intCommodityId = @intCommodityId  --AND GR.intStorageScheduleTypeId > 0		
		)a where a.intRowNum =1 	
	)t  
	WHERE dblTotal >0 AND intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END)
	GROUP BY  [Storage Type], strCommodityCode,strType,strOwnedPhysicalStock, intEntityId,	 intCommodityId,strLocationName,strItemNo,dtmDelivarydate,ysnReceiptedStorage, strTicket,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intStorageScheduleTypeId 

	
SELECT * into #tempCollateral FROM (
		SELECT  ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC) intRowNum,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblTotal,
		c.intCollateralId,cl.strLocationName,ch.strItemNo,ch.strEntityName,c.intReceiptNo,ch.intContractHeaderId,	strContractNumber, c.dtmOpenDate,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0)) dblOriginalQuantity,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0)) dblRemainingQuantity,
	    @intCommodityId as intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId,
		case when c.strType='Purchase' then 1 else 2 end	intContractTypeId,c.intLocationId,intEntityId
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId 
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		
		) a where   a.intRowNum =1 


SELECT * into #tempOnHold  FROM (
	SELECT  ROW_NUMBER() OVER (PARTITION BY t.intTicketId ORDER BY t.dtmTicketHistoryDate DESC) intSeqId,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(st.dblNetUnits, 0))  AS dblTotal,
	strName strCustomer,st.strTicketNumber Ticket,dtmTicketDateTime dtmDeliveryDate,
	cl.strLocationName,i1.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due], st.intProcessingLocationId intLocationId
	,strCustomerReference,strDistributionOption,e.intEntityId,intDeliverySheetId
	FROM tblSCTicketHistory t
	JOIN tblSCTicket st on t.intTicketId=st.intTicketId
	JOIN tblEMEntity e on e.intEntityId= st.intEntityId
	JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
	JOIN tblICItem i1 on i1.intItemId=st.intItemId
	JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	WHERE st.intCommodityId  = @intCommodityId and isnull(st.intDeliverySheetId,0) =0			
			AND convert(DATETIME, CONVERT(VARCHAR(10), t.dtmTicketHistoryDate, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
	)t 	WHERE intLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END)
	AND t.intSeqId =1 


--- transactions 	
if (isnull(@intVendorId,0)=0)

BEGIN
SELECT 	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblQuantity ,0)))  dblTotal,
	s.strLocationName,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,s.intLocationId intLocationId into #invQty
	FROM vyuICGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1 and  isnull(ysnInTransit,0)=0 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 	  
	WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit=1			
			and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
)

select sum(dblTotal) dblTotal,intCompanyLocationId,intCommodityId into #invPurBasisDelivary from(
select dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,intCompanyLocationId,cd.intCommodityId

FROM vyuICGetInventoryValuation v
join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') and  isnull(ysnInTransit,0)=0 
INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 			
WHERE v.strTransactionType ='Inventory Receipt' and cd.intCommodityId = @intCommodityId 
and cd.intCompanyLocationId=2 
and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
)t group by intCompanyLocationId,intCommodityId

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
SELECT 1 intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal),@intCommodityId,@intCommodityUnitMeasureId,intLocationId,strLocationName
FROM(	
SELECT  1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,	sum(dblTotal) dblTotal,intLocationId intLocationId,strLocationName	FROM #invQty
	group by intLocationId,strLocationName
	UNION 
		SELECT  1 AS intSeqId,'In-House' strSeqHeader,@strDescription,
		sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0))) dblTotal,intCompanyLocationId intLocationId
		,strLocationName
		FROM @tblGetStorageDetailByDate s
		JOIN tblEMEntity e on e.intEntityId= s.intEntityId
		WHERE intCommodityId = @intCommodityId 
		group by intCompanyLocationId,strLocationName

	UNION all
	SELECT  1intSeqId,'In-House' intInHouse,@strDescription strDescription, sum(dblTotal) dblTotal, intLocationId,strLocationName
	FROM #tempOnHold  group by intLocationId,strLocationName
)t1 group by strSeqHeader,strCommodityCode,intLocationId,strLocationName 
			
	-- Delivary sheet
INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId ,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
SELECT distinct   1,'In-House', strCommodityCode, sum(dblTotal)  dblTotal,@intCommodityId, intFromCommodityUnitMeasureId,intCompanyLocationId ,strLocationName 
FROM #tempDeliverySheet group by strCommodityCode,intCompanyLocationId,intFromCommodityUnitMeasureId,strLocationName

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
SELECT * FROM (
SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,sum(dblTotal) dblTotal,intCommodityId,intUnitMeasureId,intCompanyLocationId,strLocationName
FROM #tempCollateral
WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId
	group by intCommodityId,intUnitMeasureId,intCompanyLocationId,strLocationName
)t	WHERE intCompanyLocationId  IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
		) 
-- Collatral Purchase
INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
	SELECT * FROM (
	SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,sum(dblTotal) dblTotal,intCommodityId,intUnitMeasureId,intCompanyLocationId,strLocationName
	FROM #tempCollateral 
	WHERE intContractTypeId = 1 AND intCommodityId = @intCommodityId 	group by intCommodityId,intUnitMeasureId,intCompanyLocationId,strLocationName)t
							WHERE intCompanyLocationId  IN (
			SELECT intCompanyLocationId FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
							WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
							ELSE isnull(ysnLicensed, 0) END
			) 

INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
			select intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal) dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName from (
			SELECT distinct  14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cd.intUnitMeasureId intFromCommodityUnitMeasureId,cl.intCompanyLocationId,cl.strLocationName
			FROM vyuICGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId and  isnull(ysnInTransit,0)=0 
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			join tblICInventoryTransaction it on it.intInventoryTransactionId=v.intInventoryTransactionId
			WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
			and convert(DATETIME, CONVERT(VARCHAR(10), it.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
			)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)  group by intSeqId,strSeqHeader,strCommodityCode,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName
	
INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)

select intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal)  dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName from(
SELECT 30 AS intSeqId,'Company Titled Stock' strSeqHeader,@strDescription strCommodityCode
		 ,(ISNULL(invQty, 0) +
		  (isnull(CollateralPurchases, 0) - isnull(CollateralSale, 0)) +
		 CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
		CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0 then 0 else isnull(DP,0) end  
		 +isnull(SlsBasisDeliveries ,0)) AS dblTotal,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName
	FROM (
		SELECT distinct
		isnull((select sum(dblUnitOnHand) from (SELECT dblTotal dblUnitOnHand,s.intLocationId FROM #invQty s WHERE s.intCommodityId=@intCommodityId 
													and intLocationId = cl.intCompanyLocationId)t ), 0) AS invQty
			
			,(SELECT sum(dblTotal) CollateralSale FROM @Final s where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales' 
								and intCompanyLocationId= cl.intCompanyLocationId and s.intCommodityId=@intCommodityId) AS CollateralSale
			,(SELECT sum(dblTotal) CollateralPurchases FROM @Final s where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase' 
								and intCompanyLocationId= cl.intCompanyLocationId and s.intCommodityId=@intCommodityId)   AS CollateralPurchases
			,(SELECT SUM(dblTotal) dblTotal from (SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,CH.intCompanyLocationId
					FROM @tblGetStorageDetailByDate CH WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company' AND CH.intCommodityId  = @intCommodityId and CH.intCompanyLocationId=cl.intCompanyLocationId
				 )t ) AS OffSite

				,(select sum(dblTotal) from @Final s where intSeqId = 14 and intCommodityId=@intCommodityId and intCompanyLocationId= cl.intCompanyLocationId
														and s.intCommodityId=@intCommodityId) as SlsBasisDeliveries
				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= cl.intCompanyLocationId
					)t ) AS DP
			 ,cl.intCompanyLocationId,cl.strLocationName
	 FROM tblSMCompanyLocation cl
			JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId AND lo.intLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	JOIN tblICItem i ON lo.intItemId = i.intItemId and i.intCommodityId=@intCommodityId
	JOIN tblICCommodity c ON c.intCommodityId = @intCommodityId 			
	) t )t1	where isnull(dblTotal,0) <>0 group by intSeqId,strSeqHeader,strCommodityCode,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName
			

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)

select intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal) dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName from(
	SELECT 40 intSeqId, 'Price Risk' strSeqHeader,@strDescription strCommodityCode,
		isnull(invQty, 0)-
		isnull(PurBasisDelivary,0) 
		 + (isnull(OpenPurQty, 0) -isnull(OpenSalQty, 0))
		 + isnull(dblCollatralSales,0) 
		+ isnull(SlsBasisDeliveries,0)
		 + CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then  isnull(DP ,0) ELSE 0 end 
		 AS dblTotal,@intCommodityId intCommodityId,
		@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName
	FROM (
		SELECT 	distinct		
			isnull((SELECT sum(dblTotal) dblTotal  from #invQty i where intCommodityId=@intCommodityId and i.intLocationId=cl.intCompanyLocationId),0) AS invQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
				FROM @tblGetOpenContractDetail cd
				WHERE intContractTypeId = 1 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= cl.intCompanyLocationId
				)t	WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)
			) AS OpenPurQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
				FROM @tblGetOpenContractDetail cd
				WHERE cd.intContractStatusId <> 3 AND intContractTypeId = 2 AND cd.intPricingTypeId IN (1, 3)
				 AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= cl.intCompanyLocationId
				)t	WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
						)) AS OpenSalQty,				
			(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= cl.intCompanyLocationId
					)t 	WHERE intCompanyLocationId  IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) AS DP
	
			,(SELECT TOP 1 dblTotal dblTotal from #invPurBasisDelivary t where t.intCommodityId=@intCommodityId 
							AND t.intCompanyLocationId=cl.intCompanyLocationId) as PurBasisDelivary ,

			isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
			FROM ( 
			SELECT 
				-dblRemainingQuantity  dblRemainingQuantity,
					intContractHeaderId					
					FROM #tempCollateral c1									
					WHERE c1.intLocationId= cl.intCompanyLocationId and intContractTypeId = 2
					AND c1.intCommodityId  = @intCommodityId 
					 ) t 	
			), 0) AS dblCollatralSales			

		,(SELECT sum(SlsBasisDeliveries) FROM
			( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
										isnull((SELECT TOP 1 dblQty FROM tblICInventoryShipment sh
										 WHERE sh.strShipmentNumber=it.strTransactionId),0)) AS SlsBasisDeliveries  
		  FROM tblICInventoryTransaction it
		  join tblICInventoryShipment r on r.strShipmentNumber=it.strTransactionId  
		  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
		  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 
		  		  					AND  cd.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		  WHERE cd.intCommodityId = @intCommodityId AND 
		  cd.intCompanyLocationId= cl.intCompanyLocationId
		  		and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
		  )t) as SlsBasisDeliveries,cl.intCompanyLocationId,strLocationName 			
FROM tblSMCompanyLocation cl
	JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId and intLocationId is not null AND lo.intLocationId IN (
	SELECT intCompanyLocationId
	FROM tblSMCompanyLocation
	WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
	)
JOIN tblICItem i ON lo.intItemId = i.intItemId and i.intCommodityId=@intCommodityId
JOIN tblICCommodity c ON c.intCommodityId = @intCommodityId 
) t )t2 
GROUP BY intSeqId,strSeqHeader,strCommodityCode,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName
				

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strLocationName)
	SELECT 40 ,'Price Risk' ,@strDescription
		,intOpenContract AS dblTotal,@intCommodityId,
		@intCommodityUnitMeasureId,intLocationId,strLocationName
	FROM (select sum(intOpenContract)intOpenContract,intLocationId,strLocationName
			 from(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId, intOpenContract*dblContractSize) as intOpenContract 
			 ,intLocationId,strLocationName
		from @tblGetOpenFutureByDate otr  
		JOIN tblRKFutOptTransaction t on otr.intFutOptTransactionId=t.intFutOptTransactionId
				  		  			AND  intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
		JOIN tblRKFutureMarket m on t.intFutureMarketId=m.intFutureMarketId
		JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId
		join tblSMCompanyLocation cl on cl.intCompanyLocationId=t.intLocationId
		WHERE t.intCommodityId=@intCommodityId		
		 )t group by intLocationId,strLocationName) intOpenContract   
		
----	-- Option NetHedge
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strLocationName)
	select intSeqId,strSeqHeader,strCommodityCode,sum(dblTotal) dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strLocationName from(
		SELECT 40 intSeqId,'Price Risk' strSeqHeader,@strDescription strCommodityCode,	
				intOpenContract * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblTotal,ft.intCommodityId, m.intUnitMeasureId intFromCommodityUnitMeasureId,intLocationId intCompanyLocationId,l.strLocationName
	FROM @tblGetOpenFutureByDate oc
	JOIN tblRKFutOptTransaction ft on oc.intFutOptTransactionId=ft.intFutOptTransactionId
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
					  		  			AND  intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
									ELSE isnull(ysnLicensed, 0) END
									)
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND ft.intFutOptTransactionId NOT IN (
	SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND ft.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)	
	)t group by intSeqId,strSeqHeader,strCommodityCode,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId, strLocationName
----		-- Net Hedge option end
	
INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)	
SELECT 33 ,'Basis Risk',@strDescription,isnull(CompanyTitled, 0) AS dblTotal,@intCommodityId,@intCommodityUnitMeasureId	,intCompanyLocationId,strLocationName	
	FROM (
              SELECT intCompanyLocationId,
			   isnull(invQty, 0) 
			   + CASE WHEN ( SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
                                  SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN 0 ELSE -isnull(DP ,0) END 
								   + isnull(dblCollatralSales, 0) 
								   + isnull(SlsBasisDeliveries, 0)
								   +(isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))
								    AS CompanyTitled, strLocationName
		FROM (
				SELECT distinct (SELECT sum(dblTotal) Qty from #invQty s where s.intCommodityId=@intCommodityId and s.intLocationId=cl.intCompanyLocationId ) AS invQty
				, ( SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal,
								  intCompanyLocationId
                                  FROM @tblGetStorageDetailByDate s
                                  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = @intCommodityId 
								  AND s.intCompanyLocationId =  cl.intCompanyLocationId
                                  ) t WHERE intCompanyLocationId =cl.intCompanyLocationId)  AS OffSite
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,
					intCompanyLocationId
					FROM @tblGetOpenContractDetail cd
					WHERE intContractTypeId = 1 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= cl.intCompanyLocationId
					)t 	)  AS OpenPurchasesQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
					FROM @tblGetOpenContractDetail cd
					WHERE intContractTypeId = 2 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId=  cl.intCompanyLocationId	
					)t )  AS OpenSalesQty
				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId	AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= cl.intCompanyLocationId
					)t  ) AS DP
				,(SELECT sum(SlsBasisDeliveries) FROM
						( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
					  FROM tblICInventoryShipment r  
					  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
					  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 		  		  							
					  WHERE cd.intCommodityId = c.intCommodityId AND 
					  cd.intCompanyLocationId=  cl.intCompanyLocationId 
					  )t) as SlsBasisDeliveries 
		,          isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
                     FROM ( 
                     SELECT 
                     case when strType = 'Purchase' then 
						 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) else
                     -dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) end dblRemainingQuantity,
                                  intContractHeaderId,c1.intLocationId                             
                                  FROM tblRKCollateral c1                                                            
                                  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
                                  WHERE c1.intCommodityId = c.intCommodityId 
                                  AND c1.intLocationId= cl.intCompanyLocationId) t  								    
                     ), 0) AS dblCollatralSales 
             ,cl.intCompanyLocationId,strLocationName
		from tblSMCompanyLocation cl
			JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId 
			AND lo.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' 
									THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	JOIN tblICItem i ON lo.intItemId = i.intItemId and i.intCommodityId=@intCommodityId
	JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId) t
		) t1

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)	
  
	  SELECT 45,'Avail for Spot Sale' ,@strDescription
		,sum(dblTotal)-sum(dblPurQty),@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId,strLocationName FROM (
			select distinct
					(SELECT sum(dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0))) as Qty               
					FROM @tblGetOpenContractDetail  CD  
					WHERE  intContractTypeId=1 and intPricingTypeId in(1,2) and CD.intCommodityId=@intCommodityId
						 and CD.intCompanyLocationId=cl.intCompanyLocationId) dblPurQty,
					(select sum(dblTotal) FROM @Final t where strSeqHeader='Basis Risk' and t.intCommodityId=@intCommodityId and t.intCompanyLocationId=cl.intCompanyLocationId) dblTotal
					,intCompanyLocationId,strLocationName
	  		from tblSMCompanyLocation cl
			JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId 
			AND lo.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' 
									THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
								)
	JOIN tblICItem i ON lo.intItemId = i.intItemId and i.intCommodityId=@intCommodityId
	JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId)t group by intCompanyLocationId,strLocationName
	  			 

END

ELSE
BEGIN

INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
SELECT 1 intSeqId,strSeqHeader,strCommodityCode,dblTotal,@intCommodityId,@intCommodityUnitMeasureId,intLocationId,strLocationName
FROM(	
SELECT  1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,	sum(Balance) dblTotal,intCompanyLocationId intLocationId,strLocationName
		FROM @tblGetStorageDetailByDate s
                JOIN tblEMEntity e on s.intEntityId=e.intEntityId
                WHERE intCommodityId = @intCommodityId  
                --ANDintCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
                AND s.intEntityId= @intVendorId and strOwnedPhysicalStock='Customer'
				group by intCommodityId,intCompanyLocationId,strLocationName
	UNION all
	SELECT  1intSeqId,'In-House' intInHouse,@strDescription strDescription, sum(dblTotal) dblTotal, intLocationId,strLocationName
	FROM #tempOnHold where intEntityId=@intVendorId group by intCommodityId,intLocationId,strLocationName
)t1
			
	-- Delivary sheet
INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,dblTotal,intCommodityId ,intFromCommodityUnitMeasureId,intCompanyLocationId,strLocationName)
SELECT distinct   1,'In-House', strCommodityCode, sum(dblTotal)  dblTotal,@intCommodityId, intFromCommodityUnitMeasureId,intCompanyLocationId ,strLocationName 
FROM #tempDeliverySheet where intEntityId=@intVendorId group by strCommodityCode,intCompanyLocationId,intFromCommodityUnitMeasureId,strLocationName

END
		 
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(250)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, strLocationName,intCommodityId,intCompanyLocationId)

SELECT	intSeqId,strSeqHeader, strCommodityCode ,strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,strLocationName,
		t.intCommodityId,intCompanyLocationId 
FROM @Final  t
	LEFT JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId	
END

SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
END  
END

if isnull(@intVendorId,0) = 0
BEGIN
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strCommodityCode ASC)) AS intRowNum,strCommodityCode,strUnitMeasure,intCommodityId,strLocationName,sum(0) a,intCompanyLocationId intLocationId,
	(SELECT sum(dblTotal) dblInHouse FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='In-House' and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblInHouse,
	(SELECT sum(dblTotal) dblCompanyTitled FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Company Titled Stock'  and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblCompanyTitled,
	(SELECT sum(dblTotal) dblCaseExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Price Risk'  and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblCaseExposure,
	(SELECT sum(dblTotal) dblBasisExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Basis Risk'  and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblBasisExposure,
	(SELECT sum(dblTotal) dblAvailForSale FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Avail for Spot Sale'  and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblAvailForSale
FROM @FinalTable f
group by strCommodityCode,strUnitMeasure,intCommodityId,strLocationName,intCompanyLocationId
END
ELSE
BEGIN
select  convert(int,ROW_NUMBER() OVER(ORDER BY strCommodityCode ASC)) AS intRowNum, strCommodityCode,strUnitMeasure,intCommodityId,strLocationName,sum(dblTotal) a,intCompanyLocationId intLocationId,
	(SELECT sum(dblTotal) dblInHouse FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='In-House' and f.intCommodityId=t.intCommodityId and f.intCompanyLocationId=t.intCompanyLocationId) dblInHouse,
	0.0 dblCompanyTitled,
	0.0 dblCaseExposure,
	0.0 dblBasisExposure,
	0.0 dblAvailForSale
FROM @FinalTable f 
group by strCommodityCode,strUnitMeasure,intCommodityId,strLocationName,intCompanyLocationId
END