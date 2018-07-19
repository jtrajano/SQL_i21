CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail] 
	 @intCommodityId nvarchar(max)  
	,@intLocationId int = NULL	
	,@intVendorId int = null
	,@strPurchaseSales nvarchar(250) = NULL
	,@strPositionIncludes nvarchar(100) = NULL
	,@dtmToDate datetime=null
AS

BEGIN

DECLARE @ysnDisplayAllStorage bit
select @ysnDisplayAllStorage= isnull(ysnDisplayAllStorage,0) from tblRKCompanyPreference

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

if isnull(@strPurchaseSales,'') <> ''
BEGIN
if @strPurchaseSales='Purchase'
BEGIN
	SELECT @strPurchaseSales='Sales'
END
ELSE
BEGIN
	SELECT @strPurchaseSales='Purchase'
END
END

DECLARE @Final AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250),
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
)

DECLARE @FinalTable AS TABLE (
					intRow int IDENTITY(1,1) PRIMARY KEY , 
					intSeqId int, 
					strSeqHeader nvarchar(100),
					strCommodityCode nvarchar(100),
					strType nvarchar(100),
					dblTotal DECIMAL(24,10),
					intCollateralId int,
					strLocationName nvarchar(250),
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

DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  nvarchar(100),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  nvarchar(100),
		strLocationName  nvarchar(100),
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
		,strLocationName nvarchar(100)
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
,dtmHistoryDate datetime)

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
	 strTicket,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId,intEntityId,strOwnedPhysicalStock,ysnReceiptedStorage,intStorageScheduleTypeId into #tempDeliverySheet from(
SELECT * FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY   GR1.intCustomerStorageId ORDER BY dtmHistoryDate DESC) intRowNum,  GR1.intCustomerStorageId,GR.strStorageTypeDescription [Storage Type],@strDescription strCommodityCode,GR.strStorageTypeDescription strType,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,GR1.dblUnits) dblTotal,	
	strName strCustomerReference,strDeliverySheetNumber strTicket,CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDeliverySheetDate ,110),110) dtmDelivarydate,
	l.strLocationName strLocationName,i.strItemNo,
	SCT.intCommodityId intCommodityId, @intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,null [Storage Due],l.intCompanyLocationId  intCompanyLocationId	
	, E.intEntityId , strOwnedPhysicalStock,ysnReceiptedStorage,GR.intStorageScheduleTypeId
	FROM tblSCDeliverySheet SCD 
	INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
	INNER JOIN tblGRStorageHistory GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
	INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
	INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
	INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
	LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
	WHERE SCT.strTicketStatus = 'H' and isnull(SCT.intDeliverySheetId,0) <>0   and isnull(SCD.ysnPost,0) =1
	AND SCT.intCommodityId = @intCommodityId  --AND isnull(GR.intStorageScheduleTypeId,0) > 0
	AND	l.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end
	and  convert(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= convert(datetime,@dtmToDate)
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
		AND	l.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then l.intCompanyLocationId else @intLocationId end and   convert(DATETIME, CONVERT(VARCHAR(10), dtmDeliverySheetHistoryDate, 110), 110) <= convert(datetime,@dtmToDate)
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
	    @intCommodityId as intCommodityId,c.intUnitMeasureId,c.intLocationId intCompanyLocationId,intContractTypeId,c.intLocationId,intEntityId
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		) a where   a.intRowNum =1 

SELECT 	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblQuantity ,0)))  dblTotal,'' strCustomer,null Ticket,null dtmDeliveryDate
	,s.strLocationName,s.strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName
	,null [Storage Due],s.intLocationId intLocationId into #invQty
	FROM vyuICGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   
	LEFT JOIN tblSCTicket t on s.strSourceNumber=t.strTicketNumber		  
	WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0 
			AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate) 
			and isnull(t.strDistributionOption,'') <> 'DP'
			and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)
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
			AND st.intProcessingLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND convert(DATETIME, CONVERT(VARCHAR(10), t.dtmTicketHistoryDate, 110), 110) <=CONVERT(DATETIME,@dtmToDate)
	)t 	WHERE intLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END)
	AND t.intSeqId =1 
	
IF ISNULL(@intVendorId,0) = 0
BEGIN

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strCustomer,strTicket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intCompanyLocationId)
	SELECT 1 intSeqId,strSeqHeader,strCommodityCode,[strType],dblTotal,strCustomer,Ticket,dtmDeliveryDate,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName
			,[Storage Due],intLocationId 
	FROM(	
	SELECT  1 AS intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,'Receipt' AS [strType],
					sum(dblTotal) dblTotal,'' strCustomer,null Ticket,null dtmDeliveryDate,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName
					,null [Storage Due],intLocationId intLocationId
					FROM #invQty group by strLocationName,strItemNo,intLocationId
			UNION all
				SELECT  1 AS intSeqId,'In-House' strSeqHeader,@strDescription,[Storage Type] AS [strType],
				dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0)),
				strName strCustomer,Ticket,[Delivery Date] dtmDeliveryDate
				,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,[Storage Due]
				,intCompanyLocationId intLocationId
				FROM @tblGetStorageDetailByDate s
				JOIN tblEMEntity e on e.intEntityId= s.intEntityId
				WHERE 
				intCommodityId = @intCommodityId AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

			UNION all
			SELECT  1intSeqId,'In-House' intInHouse,@strDescription strDescription,'On-Hold' strType, dblTotal, strCustomer,Ticket,dtmDeliveryDate,strLocationName,
					strItemNo,intCommodityId,intCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intLocationId
			FROM #tempOnHold 
		)t1
			
		-- Delivary sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   1,'In-House', strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT 2,'Off-Site',@strDescription,'Off-Site',	dblTotal,intCommodityId,strLocation,strItemNo ,dtmDeliveryDate ,strTicket ,strCustomerReference ,strDPAReceiptNo,dblDiscDue,
		[Storage Due] ,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,intCompanyLocationId 
		FROM 
		(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,i.strItemNo ,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,intCompanyLocationId  
		FROM @tblGetStorageOffSiteDetail r
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		) t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,'Purchase In-Transit',@strDescription,'Purchase In-Transit' AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0)) 
	 AS dblTotal,strLocationName,strItemNo,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
			SELECT i.intUnitMeasureId,			
			isnull(i.dblPurchaseContractShippedQty, 0) as ReserveQty,
			i.strLocationName,i.strItemNo,
			i.strContractNumber,intCompanyLocationId			 
			FROM vyuRKPurchaseIntransitView i
			WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end					
		) t where intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)
				
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strTicket,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 4 AS intSeqId,'Sales In-Transit',@strDescription
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemName,strTicket,strCustomerReference,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId
	FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(i.intUnitMeasureId,@intCommodityUnitMeasureId,isnull(i.dblBalanceToInvoice, 0)) as ReserveQty,
				i.strLocationName,i.strItemName,strContractNumber,strTicket,strCustomerReference,i.intCompanyLocationId
				FROM @tblGetSalesIntransitWOPickLot i
				WHERE i.intCommodityId = @intCommodityId
			    AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end	
				)t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due], dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId,intStorageScheduleTypeId)
		SELECT 5,[Storage Type],@strDescription,strType,dblTotal,intCommodityId,strLocation,strItemNo,dtmDeliveryDate ,strTicket  
		,strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId,intCompanyLocationId,intStorageScheduleTypeId   from (
		SELECT [Storage Type],[Storage Type] strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		r.intCommodityId,Loc AS strLocation ,r.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,intCompanyLocationId,intStorageTypeId intStorageScheduleTypeId  
		FROM @tblGetStorageDetailByDate  r
		WHERE r.intCommodityId = @intCommodityId AND r.ysnDPOwnedType = 0  AND r.ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		)t 
		WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
					WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
					ELSE isnull(ysnLicensed, 0) END
				) 
	-- Delivary sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer,
					  intFromCommodityUnitMeasureId,intCompanyLocationId)

	SELECT distinct  5 intSeqId , [Storage Type], strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet

	IF (@ysnDisplayAllStorage=1)
	BEGIN
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 5,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage =0
			  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket ,strLocationName,strItemNo,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	SELECT * FROM 
	(SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId ,ISNULL(Balance, 0)) dblTotal,
		[Delivery Date],
		 Ticket,
		strLocationName,r.strItemNo, @intCommodityId intCommodityId,@intCommodityUnitMeasureId intCommodityUnitMeasureId
		,[Storage Due],intCompanyLocationId
	FROM @tblGetStorageDetailByDate  r
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND r.intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end)t	
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

-- Delivary sheet
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)

	SELECT DISTINCT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader, strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet where ysnReceiptedStorage=0 AND strOwnedPhysicalStock = 'Customer'
--Collatral Sale
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		 dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM #tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
						WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
-- Collatral Purchase
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Purchase' strType,
		 dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,
		strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity ,intCommodityId,intUnitMeasureId,intCompanyLocationId
		FROM #tempCollateral 
		WHERE intContractTypeId = 1 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end)t
								WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
SELECT * FROM (
			SELECT 10 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
			FROM @tblGetStorageOffSiteDetail  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND r.intCommodityId = @intCommodityId  
			AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end)t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

IF (@ysnDisplayAllStorage=1)
	BEGIN			 
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 10,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage = 1
				AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
SELECT 11 AS intSeqId,'Total Receipted',@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + (isnull(CollateralSale, 0) - isnull(CollateralPurchases, 0)) dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from @Final where intSeqId=10) dblTotal
		,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
		,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase') AS  CollateralPurchases

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
			SELECT 12 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,r.intCommodityId  ,Loc AS strLocation ,
			i.strItemNo,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
			FROM @tblGetStorageDetailByDate  r
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE  ysnDPOwnedType = 1  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			)t where  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber,intContractHeaderId)
			SELECT * FROM (
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0)) AS dblTotal,
			@intCommodityId intCommodityId,cl.strLocationName,CT.strItemNo,CT.strContractNumber strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId as intCommodityUnitMeasureId,
			CT.intCompanyLocationId,strPickLotNumber,CT.strContractNumber,intContractHeaderId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN tblLGPickLotHeader PH on PH.intPickLotHeaderId=PLDetail.intPickLotHeaderId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN @tblGetOpenContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId  and CT.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end

			UNION ALL
			
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Pur Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,
			@intCommodityId intCommodityId,cl.strLocationName,cd.strItemNo,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId,strReceiptNumber,cd.strContractNumber,intContractHeaderId
			FROM vyuICGetInventoryValuation v
			join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE v.strTransactionType ='Inventory Receipt' and cd.intCommodityId = @intCommodityId AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			)t	WHERE  intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strDPAReceiptNo,strContractNumber)
			select * from (
			SELECT 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sls Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strContractNumber strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId,strShipmentNumber,cd.strContractNumber
			FROM vyuICGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)  
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId,strDPAReceiptNo)

SELECT 15 AS intSeqId,'Company Titled Stock',@strDescription
		,'Company Titled Stock' AS [strType]
		,ISNULL(invQty, 0) +
		  (isnull(CollateralPurchases, 0) - isnull(CollateralSale, 0)) +
		 CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled from tblRKCompanyPreference)=1 then isnull(OffSite,0) else 0 end +  
		CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then 0 else -isnull(DP,0) end  
		 +isnull(SlsBasisDeliveries ,0)
		 AS dblTotal,@intCommodityId,@intCommodityUnitMeasureId,strDPAReceiptNo
	FROM (
		SELECT 
		isnull((select sum(dblUnitOnHand) from (
					SELECT dblTotal dblUnitOnHand,s.intLocationId
				FROM #invQty s  		
				)t WHERE intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)			 
				 ), 0) AS invQty
			
			,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
			,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase')   AS CollateralPurchases
			,(select sum(dblTotal) dblTotal from (SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,CH.intCompanyLocationId
					FROM @tblGetStorageDetailByDate CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
				 )t WHERE intCompanyLocationId IN (
								SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
												WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)) AS OffSite

				,(select sum(dblTotal) from @Final where intSeqId = 14 and intCommodityId=@intCommodityId) as SlsBasisDeliveries
				,(select top 1 strDPAReceiptNo from @Final where intSeqId = 14 and intCommodityId=@intCommodityId) as strDPAReceiptNo
				,(select sum(dblTotal) dblTotal from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) ) AS DP

		) t

INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,strCustomer , dblTotal,intCommodityId,strLocationName,strItemNo,strTicket,dtmDeliveryDate,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,strTruckName,strDriverName,intCompanyLocationId)
SELECT 16 intSeqId,'On-Hold' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,strCustomer,dblTotal,intCommodityId,strLocationName,strItemNo,Ticket,dtmDeliveryDate, 
		strCustomerReference,strDistributionOption,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,strTruckName,strDriverName, intLocationId
FROM #tempOnHold				 

END
ELSE 
BEGIN
    INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName,[Storage Due],intCompanyLocationId)                                
    (SELECT 1 intSeqId,'In-House' strSeqHeader,@strDescription strCommodityCode,[strType],dblTotal,dtmDeliveryDate,strTicket,strLocationName,strItemNo,strName,intCommodityId,intFromCommodityUnitMeasureId,strTruckName,strDriverName
                    ,[Storage Due],intLocationId 
    FROM(  SELECT  [Storage Type] AS [strType],
            dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(Balance,0)) dblTotal,
			Ticket strTicket,s.[Delivery Date] dtmDeliveryDate
                ,strLocationName,strItemNo,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,'' strTruckName,'' strDriverName,[Storage Due]
                ,intCompanyLocationId intLocationId,strName
                FROM @tblGetStorageDetailByDate s
                JOIN tblEMEntity e on s.intEntityId=e.intEntityId
                WHERE intCommodityId = @intCommodityId AND 
                intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
                AND s.intEntityId= @intVendorId and strOwnedPhysicalStock='Customer'

            UNION all
                SELECT 'On-Hold' strType, dblTotal,
				Ticket,dtmDeliveryDate, strLocationName,strItemNo,@intCommodityId,@intCommodityUnitMeasureId,strTruckName,strDriverName,null [Storage Due], 
                        intLocationId,strCustomer
                FROM #tempOnHold
                WHERE intEntityId= @intVendorId 
				)t     WHERE intLocationId IN (
                        SELECT intCompanyLocationId FROM tblSMCompanyLocation
                        WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                    WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                    ELSE isnull(ysnLicensed, 0) END)
		)
		 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   1,'In-House', strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer'

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId ,strLocationName,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,
					strCustomerReference,strDPAReceiptNo ,dblDiscDue ,[Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 2 intSeqId,'Off-Site' strSeqHeader,@strDescription strCommodityCode,'Off-Site' strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,r.intCommodityId,Loc AS strLocation,
		i.strItemNo ,strName,[Delivery Date] AS dtmDeliveryDate ,
				Ticket strTicket ,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,
				[Storage Due] AS [Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId  
		FROM @tblGetStorageOffSiteDetail r
		JOIN tblEMEntity e on r.intEntityId=e.intEntityId
		join tblICItem i on r.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId 
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		AND r.intEntityId= @intVendorId )t
				where intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId)
	SELECT 3 AS intSeqId,'Purchase In-Transit',@strDescription,'Purchase In-Transit' AS [strType],
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0)) 
	 AS dblTotal,strLocationName,strItemNo,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId
	FROM (
			SELECT i.intUnitMeasureId,			
			isnull(i.dblPurchaseContractShippedQty, 0) as ReserveQty,
			i.strLocationName,i.strItemNo,
			i.strContractNumber,i.intCompanyLocationId
			FROM vyuRKPurchaseIntransitView i
			WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end
			AND i.intEntityId= @intVendorId 
								
		) t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,strLocationName,strItemNo,strTicket,strCustomerReference,strContractNumber,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT 4 AS intSeqId,'Sales In-Transit',@strDescription
		,'Sales In-Transit' AS [strType]
		,ISNULL(ReserveQty, 0) AS dblTotal,strLocationName,strItemName,strTicket,strCustomerReference,strContractNumber,@intCommodityId,@intCommodityUnitMeasureId,intCompanyLocationId
	FROM (
		SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(i.intUnitMeasureId,@intCommodityUnitMeasureId,isnull(i.dblBalanceToInvoice, 0)) as ReserveQty,
				i.strLocationName,i.strItemName,strContractNumber,strTicket,strCustomerReference,i.intCompanyLocationId
				FROM vyuRKGetSalesIntransitWOPickLot i
				WHERE i.intCommodityId = @intCommodityId
			    AND i.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then i.intCompanyLocationId else @intLocationId end	
				AND i.intEntityId= @intVendorId 
		) t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 	

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		select * from (
		SELECT 5 intSeqId,[Storage Type] strSeqHeader,@strDescription strCommodityCode,[Storage Type] strType,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		r.intCommodityId,Loc AS strLocation ,r.strItemNo,strName,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
		,Customer as strCustomerReference,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
		,dtmLastStorageAccrueDate ,strScheduleId ,@intCommodityUnitMeasureId intCommodityUnitMeasureId,intCompanyLocationId   
		FROM @tblGetStorageDetailByDate  r
		JOIN tblEMEntity e on r.intEntityId=e.intEntityId
		WHERE r.intCommodityId = @intCommodityId AND ysnDPOwnedType = 0  AND ysnReceiptedStorage = 0  
		AND	intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
		AND r.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
			-- Delivary sheet

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   5,[Storage Type], strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer'
	IF (@ysnDisplayAllStorage=1)
	BEGIN
		INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
		SELECT 5,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
		FROM tblGRStorageType  
		WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage =0
			  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END
	
	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,dtmDeliveryDate ,strTicket,strLocationName,strItemNo,strCustomer,intCommodityId,intFromCommodityUnitMeasureId,[Storage Due],intCompanyLocationId)
	select * from (
	SELECT 7 AS intSeqId,'Total Non-Receipted' strSeqHeader,@strDescription strCommodityCode
		,'Total Non-Receipted' [Storage Type]
		,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(Balance, 0)) dblTotal,
		[Delivery Date],Ticket,
		strLocationName,r.strItemNo,
		strName, @intCommodityId AS intCommodityId,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,[Storage Due],intCompanyLocationId
	FROM @tblGetStorageDetailByDate  r
	JOIN tblEMEntity e on r.intEntityId=e.intEntityId
	WHERE ysnReceiptedStorage = 0
		AND strOwnedPhysicalStock = 'Customer'
		AND r.intCommodityId = @intCommodityId
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end	
		AND r.intEntityId= @intVendorId )t
				WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,dtmDeliveryDate ,strTicket ,strCustomerReference,strCustomer
					  ,intFromCommodityUnitMeasureId,intCompanyLocationId)
	SELECT distinct   7 AS intSeqId,'Total Non-Receipted' strSeqHeader, strCommodityCode,strType, dblTotal  dblTotal,intCommodityId,strLocationName,
	strItemNo,dtmDelivarydate, strTicket,strCustomerReference,strCustomerReference, intFromCommodityUnitMeasureId,intCompanyLocationId  
	FROM #tempDeliverySheet  where intEntityId= @intVendorId  AND strOwnedPhysicalStock = 'Customer' and  ysnReceiptedStorage=0


	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 8 intSeqId,'Collateral Receipts - Sales' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Sales' strType,
		dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,
		dblOriginalQuantity,dblRemainingQuantity,@intCommodityId AS intCommodityId,intUnitMeasureId,intLocationId intCompanyLocationId 
		FROM #tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
		AND intEntityId= @intVendorId )t WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCollateralId,strLocationName,strItemNo,strCustomer,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
		SELECT 9 intSeqId,'Collateral Receipts - Purchase' strSeqHeader, @strDescription strCommodityCode,'Collateral Receipts - Purchase' strType,
		dblTotal,intCollateralId,strLocationName,strItemNo,strEntityName,intReceiptNo,intContractHeaderId,strContractNumber,dtmOpenDate,
		dblOriginalQuantity,dblRemainingQuantity,@intCommodityId intCommodityId,intUnitMeasureId,intLocationId intCompanyLocationId	
		FROM #tempCollateral
		WHERE intContractTypeId = 1 AND intCommodityId = @intCommodityId 
		AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId  else @intLocationId end
		AND intEntityId= @intVendorId)t  WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				)

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName ,strItemNo,strCustomer,dtmDeliveryDate ,strTicket ,strCustomerReference,strDPAReceiptNo ,	dblDiscDue ,
					  [Storage Due] , dtmLastStorageAccrueDate ,strScheduleId,intFromCommodityUnitMeasureId,intCompanyLocationId)
		SELECT * FROM (
			SELECT 10 intSeqId,[Storage Type],@strDescription strCommodityCode,[Storage Type] strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,
			r.intCommodityId  ,Loc AS strLocation ,i.strItemNo,strName,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference, Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS [Storage Due]  
			,dtmLastStorageAccrueDate,strScheduleId,@intCommodityUnitMeasureId as intCommodityUnitMeasureId,intCompanyLocationId  
			FROM @tblGetStorageOffSiteDetail  r
			JOIN tblEMEntity e on r.intEntityId=e.intEntityId
			join tblICItem i on r.intItemId=i.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'  
			AND r.intCommodityId = @intCommodityId  AND intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end 
			AND r.intEntityId= @intVendorId)t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 
IF (@ysnDisplayAllStorage=1)
	BEGIN			 
			INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId)
			SELECT 10,strStorageTypeDescription [Storage Type],@strDescription,strStorageTypeDescription,0.00,@intCommodityId
			FROM tblGRStorageType  
			WHERE ISNULL(ysnActive,0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage = 1
				  AND intStorageScheduleTypeId NOT IN(SELECT DISTINCT isnull(intStorageScheduleTypeId,0) FROM @Final WHERE intSeqId=5)
	END

	INSERT INTO @Final(intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,intFromCommodityUnitMeasureId)
    SELECT 11 AS intSeqId,'Total Receipted',@strDescription
		,'Total Receipted' AS [strType]
		,isnull(dblTotal, 0)  + case when @strPurchaseSales = 'Purchase' then isnull(CollateralSale, 0) else 0 end  + case when @strPurchaseSales ='Sales' then isnull(CollateralPurchases, 0) else 0 end  dblTotal,@intCommodityId,@intCommodityUnitMeasureId
	FROM (select sum(dblTotal) dblTotal from @Final where intSeqId=10) dblTotal
		,(SELECT dblTotal CollateralSale FROM @Final where intSeqId = 8 and strSeqHeader='Collateral Receipts - Sales') AS CollateralSale
		,(SELECT dblTotal CollateralPurchases FROM @Final where intSeqId = 9 and strSeqHeader='Collateral Receipts - Purchase')   AS CollateralPurchases

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strContractNumber,intContractHeaderId)
			SELECT * FROM (
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0))
			 AS dblTotal,@intCommodityId intCommodityId,cl.strLocationName,CT.strItemNo,strName,CT.strContractNumber strTicket,CT.dtmContractDate as dtmTicketDateTime ,
			CT.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,@intCommodityUnitMeasureId intCommodityUnitMeasureId,CT.intCompanyLocationId intCompanyLocationId,CT.strContractNumber,intContractHeaderId
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN @tblGetOpenContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId  and CT.intContractStatusId <> 3
			JOIN tblEMEntity e on e.intEntityId=CT.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CT.intCommodityId AND CT.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			AND CT.intEntityId= @intVendorId 

			UNION ALL
			
			SELECT 13 intSeqId,'Pur Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Purchase Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0)) AS dblTotal,
			@intCommodityId intCommodityId,cl.strLocationName,cd.strItemNo,strName,strTicketNumber strTicket,st.dtmTicketDateTime,strCustomerReference,
					strDistributionOption,@intCommodityUnitMeasureId AS intCommodityUnitMeasureId,st.intProcessingLocationId intCompanyLocationId,cd.strContractNumber,intContractHeaderId
			FROM vyuICGetInventoryValuation v
			join tblICInventoryReceipt r on r.strReceiptNumber=v.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			JOIN tblEMEntity e on st.intEntityId=e.intEntityId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2  and cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId 
			WHERE cd.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			AND st.intEntityId= @intVendorId and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			)t 	WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmTicketDateTime,strCustomerReference, 
						strDistributionOption,intFromCommodityUnitMeasureId,intCompanyLocationId,strContractNumber )
			select * from (
			SELECT 14 intSeqId,'Sls Basis Deliveries' strSeqHeader,@strDescription strCommodityCode,'Sales Basis Deliveries' strType,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,
			cd.intCommodityId,cl.strLocationName,cd.strItemNo,strName,cd.strContractNumber strTicketNumber,
			cd.dtmContractDate as dtmTicketDateTime ,
			cd.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,cd.intUnitMeasureId,cl.intCompanyLocationId,cd.strContractNumber 
			FROM  vyuICGetInventoryValuation v 
			JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3
			JOIN tblEMEntity e on r.intEntityId=cd.intEntityId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
			WHERE cd.intCommodityId = @intCommodityId 
			AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
			and cd.intEntityId= @intVendorId and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=CONVERT(DATETIME,@dtmToDate))t
				WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 

	INSERT INTO @Final (intSeqId,strSeqHeader,strCommodityCode,strType,dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,strTicket,dtmDeliveryDate,strCustomerReference,
					 strDistributionOption,intFromCommodityUnitMeasureId,strTruckName,strDriverName,intCompanyLocationId)
	SELECT * FROM (
	SELECT 16 intSeqId,'On-Hold' strSeqHeader,@strDescription strCommodityCode,'On-Hold' strType,
		dblTotal,intCommodityId,strLocationName,strItemNo,strCustomer,Ticket strTicket,dtmDeliveryDate,strCustomerReference,strDistributionOption,
		@intCommodityUnitMeasureId intCommodityUnitMeasureId,strTruckName,strDriverName,intLocationId
		FROM #tempOnHold
		WHERE intCommodityId  = @intCommodityId
			  AND intLocationId  = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end
			  AND intEntityId= @intVendorId and isnull(intDeliverySheetId,0) =0 )t
				WHERE intLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				) 


END
		
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(250)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
INSERT INTO @FinalTable (intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
				intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
				strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
				dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName)

SELECT	intSeqId,strSeqHeader, strCommodityCode ,strType ,
			    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
			case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure, intCollateralId,strLocationName,strCustomer,
		intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,t.intCommodityId,
		strCustomerReference ,strDistributionOption ,strDPAReceiptNo ,
		dblDiscDue ,[Storage Due] ,	dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
		dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName  
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

SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName			
FROM @FinalTable 
 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC
END
ELSE
BEGIN
SELECT intRow,intSeqId,strSeqHeader, strCommodityCode ,strType ,dblTotal ,strUnitMeasure, intCollateralId,strLocationName,strCustomer,
					intReceiptNo,intContractHeaderId,strContractNumber ,dtmOpenDate,dblOriginalQuantity ,dblRemainingQuantity ,intCommodityId,
					strCustomerReference ,strDistributionOption ,strDPAReceiptNo,dblDiscDue ,[Storage Due] as dblStorageDue ,dtmLastStorageAccrueDate ,strScheduleId ,strTicket ,
					dtmDeliveryDate ,dtmTicketDateTime,strItemNo,strTruckName,strDriverName			
FROM @FinalTable WHERE strType <> 'Company Titled Stock'-- and strType not like '%'+@strPurchaseSales+'%'
 ORDER BY strCommodityCode,intSeqId ASC,intContractHeaderId DESC
END