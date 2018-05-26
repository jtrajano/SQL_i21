CREATE PROCEDURE [dbo].[uspRKDPRPreCrushPositionDetail] @intCommodityId NVARCHAR(max)
	,@intLocationId NVARCHAR(max) = NULL
	,@intVendorId INT = NULL
	,@strPurchaseSales NVARCHAR(50) = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate DATETIME = NULL
	,@intBookId INT = NULL
	,@intSubBookId INT = NULL
	,@strPositionBy NVARCHAR(100) = NULL
AS

BEGIN
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	IF isnull(@strPurchaseSales, '') <> ''
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
	DECLARE @Commodity AS TABLE (
		intCommodityIdentity INT IDENTITY(1, 1) PRIMARY KEY
		,intCommodity INT
		)

	INSERT INTO @Commodity (intCommodity)
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@intCommodityId, ',')

	DECLARE @List AS TABLE (
		intRowNumber INT IDENTITY(1, 1)
		,intContractHeaderId INT
		,strContractNumber NVARCHAR(200)
		,intFutOptTransactionHeaderId INT
		,strInternalTradeNo NVARCHAR(200)
		,intCommodityId INT
		,strCommodityCode NVARCHAR(200)
		,strType NVARCHAR(50)
		,strLocationName NVARCHAR(100)
		,strContractEndMonth NVARCHAR(50)
		,strContractEndMonthNearBy NVARCHAR(50)
		,dblTotal DECIMAL(24, 10)
		,intSeqNo INT
		,strUnitMeasure NVARCHAR(50)
		,intFromCommodityUnitMeasureId INT
		,intToCommodityUnitMeasureId INT
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId INT
		,strInstrumentType NVARCHAR(50)
		,strEntityName NVARCHAR(100)
		,intOrderId int
		,strInventoryType NVARCHAR(100)
		,intPricingTypeId int
		)
	DECLARE @FinalList AS TABLE (
		intRowNumber INT IDENTITY(1, 1)
		,intContractHeaderId INT
		,strContractNumber NVARCHAR(200)
		,intFutOptTransactionHeaderId INT
		,strInternalTradeNo NVARCHAR(200)
		,intCommodityId INT
		,strCommodityCode NVARCHAR(200)
		,strType NVARCHAR(50)
		,strLocationName NVARCHAR(100)
		,strContractEndMonth NVARCHAR(50)
		,strContractEndMonthNearBy NVARCHAR(50)
		,dblTotal DECIMAL(24, 10)
		,intSeqNo INT
		,strUnitMeasure NVARCHAR(50)
		,intFromCommodityUnitMeasureId INT
		,intToCommodityUnitMeasureId INT
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId INT
		,strInstrumentType NVARCHAR(50)
		,strEntityName NVARCHAR(100)
		,intOrderId int
		)
	DECLARE @InventoryStock AS TABLE (		
	strCommodityCode NVARCHAR(100)
	,dblTotal numeric(24,10)
	,strLocationName nvarchar(100)
	,intCommodityId int
	,intFromCommodityUnitMeasureId int
	,strType nvarchar(100)
	,strInventoryType NVARCHAR(100)
	,intPricingTypeId int
	)

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
			DECLARE @tblGetOpenContractDetail TABLE (
				intRowNum INT
				,strCommodityCode NVARCHAR(100)
				,intCommodityId INT
				,intContractHeaderId INT
				,strContractNumber NVARCHAR(100)
				,strLocationName NVARCHAR(100)
				,dtmEndDate DATETIME
				,dblBalance DECIMAL(24, 10)
				,intUnitMeasureId INT
				,intPricingTypeId INT
				,intContractTypeId INT
				,intCompanyLocationId INT
				,strContractType NVARCHAR(100)
				,strPricingType NVARCHAR(100)
				,intCommodityUnitMeasureId INT
				,intContractDetailId INT
				,intContractStatusId INT
				,intEntityId INT
				,intCurrencyId INT
				,strType NVARCHAR(100)
				,intItemId INT
				,strItemNo NVARCHAR(100)
				,dtmContractDate DATETIME
				,strEntityName NVARCHAR(100)
				,strCustomerContract NVARCHAR(100)
				,intFutureMarketId int
				,intFutureMonthId int
				)

			INSERT INTO @tblGetOpenContractDetail (
				intRowNum
				,strCommodityCode
				,intCommodityId
				,intContractHeaderId
				,strContractNumber
				,strLocationName
				,dtmEndDate
				,dblBalance
				,intUnitMeasureId
				,intPricingTypeId
				,intContractTypeId
				,intCompanyLocationId
				,strContractType
				,strPricingType
				,intCommodityUnitMeasureId
				,intContractDetailId
				,intContractStatusId
				,intEntityId
				,intCurrencyId
				,strType
				,intItemId
				,strItemNo
				,dtmContractDate
				,strEntityName
				,strCustomerContract
				,intFutureMarketId
				,intFutureMonthId
				)
			EXEC uspRKDPRContractDetail @intCommodityId	,@dtmToDate

			DECLARE @tblGetOpenFutureByDate TABLE (
				intFutOptTransactionId INT
				,intOpenContract INT
				)

			INSERT INTO @tblGetOpenFutureByDate (
				intFutOptTransactionId
				,intOpenContract
				)
			EXEC uspRKGetOpenContractByDate @intCommodityId, @dtmToDate

			INSERT INTO @List (
				strCommodityCode
				,intCommodityId
				,intContractHeaderId
				,strContractNumber
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strEntityName
				)
			SELECT strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strType,strLocationName,strContractEndMonth,strContractEndMonthNearBy,dblTotal
			,intFromCommodityUnitMeasureId,strEntityName from 
			(SELECT strCommodityCode
				,CD.intCommodityId
				,CD.intContractHeaderId
				,strContractNumber
				,CD.strType [strType]
				,strLocationName
				,case when @strPositionBy ='Delivery Month' then RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
						else RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8) end strContractEndMonth
				,case when @strPositionBy ='Delivery Month' then RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) 
						else RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8) end strContractEndMonthNearBy
				,CASE WHEN intContractTypeId = 1 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) ELSE - dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) END AS dblTotal
				,CD.intUnitMeasureId intFromCommodityUnitMeasureId
				,CD.strEntityName
			FROM @tblGetOpenContractDetail CD
			JOIN tblCTContractDetail det on CD.intContractDetailId=det.intContractDetailId 
			JOIN tblRKFuturesMonth fm on CD.intFutureMonthId=fm.intFutureMonthId and CD.intFutureMarketId=fm.intFutureMarketId
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId AND CD.intContractStatusId <> 3 
			AND CD.intCompanyLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			WHERE  intContractTypeId IN (1, 2) AND CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN CD.intCompanyLocationId ELSE @intLocationId END 
			AND CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END) t where dblTotal <>0
						

			DECLARE @intUnitMeasureId INT
			DECLARE @strUnitMeasure NVARCHAR(50)

			SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId
			FROM tblRKCompanyPreference

			SELECT @strUnitMeasure = strUnitMeasure
			FROM tblICUnitMeasure
			WHERE intUnitMeasureId = @intUnitMeasureId

			INSERT INTO @FinalList (
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
				)
			SELECT strCommodityCode
				,strContractNumber
				,intContractHeaderId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal)) dblTotal
				,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure
				,strAccountNumber
				,strTranType
				,dblNoOfLot
				,dblDelta
				,intBrokerageAccountId
				,strInstrumentType
				,strEntityName
				,intOrderId
			FROM @List t
			JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
			JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
			LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
			WHERE t.intCommodityId = @intCommodityId

-- inventory
INSERT INTO @InventoryStock(strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType,intPricingTypeId)
SELECT strCommodityCode ,sum(dblTotal)  dblTotal,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType,intPricingTypeId FROM(
SELECT strCommodityCode,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(s.dblQuantity,0))  dblTotal,
	strLocationName,@intCommodityId intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId, 'Inventory' strInventoryType,intPricingTypeId
	FROM vyuICGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   
	JOIN tblICCommodity c on i.intCommodityId=c.intCommodityId
	LEFT JOIN tblICInventoryReceipt ir on ir.strReceiptNumber = s.strTransactionId
	LEFT JOIN tblICInventoryReceiptItem ri on ri.intInventoryReceiptId=ir.intInventoryReceiptId
	LEFT JOIN tblCTContractDetail cd on cd.intContractDetailId =ri.intLineNo		  
	WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0
			AND s.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then s.intLocationId else @intLocationId end
			and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			and s.intLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				))t group by strCommodityCode ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId,strInventoryType,intPricingTypeId
--Collateral
INSERT INTO @InventoryStock(strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType)
select strCommodityCode ,sum(dblTotal)  dblTotal,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType from(
SELECT strCommodityCode,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,'Collateral' strInventoryType  FROM (
		SELECT  ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC) intRowNum,
		case when c.strType='Purchase' then
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0))
		else -abs(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0))) end dblTotal,
	    @intCommodityId as intCommodityId,co.strCommodityCode,cl.strLocationName,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		LEFT JOIn tblCTContractDetail det on ch.intContractDetailId=det.intContractDetailId
		WHERE c.intCommodityId = @intCommodityId 
		AND c.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then c.intLocationId else @intLocationId end
		and convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		--and det.intBookId = case when isnull(@intBookId,0) =0 then det.intBookId else @intBookId end
		--and det.intSubBookId = case when isnull(@intSubBookId,0) =0 then det.intSubBookId else @intSubBookId end
		) a where   a.intRowNum =1 )t group by strCommodityCode ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType
-- OFfSite
INSERT INTO @InventoryStock(strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType)
SELECT strCommodityCode ,sum(dblTotal)  dblTotal,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType from(
SELECT strCommodityCode,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,'OffSite' strInventoryType FROM 
(SELECT strCommodityCode, strLocationName ,c.intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId, 
	dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal,CH.intCompanyLocationId
	FROM @tblGetStorageDetailByDate CH
	join tblICCommodity c on CH.intCommodityId=c.intCommodityId
	WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'	AND CH.intCommodityId  = @intCommodityId
		AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end	
	)t WHERE intCompanyLocationId IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
))t group by strCommodityCode ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType
		
-- OFfSite
INSERT INTO @InventoryStock(strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType)
select strCommodityCode ,sum(dblTotal)  dblTotal,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType from(
select  strCommodityCode,dblTotal ,strLocationName ,intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId ,'Sls Basis Deliveries' strInventoryType from (
	SELECT strCommodityCode,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,cd.intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))  AS dblTotal,cl.strLocationName
	,cd.intCommodityId,cd.intCompanyLocationId
	FROM vyuICGetInventoryValuation v 
	JOIN tblICInventoryShipment r on r.strShipmentNumber=v.strTransactionId
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3  AND cd.intContractTypeId = 2
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
	INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
	LEFT  JOIN tblCTContractDetail det on cd.intContractDetailId=det.intContractDetailId
	WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType ='Inventory Shipment'
	AND cl.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then cl.intCompanyLocationId else @intLocationId end
	and convert(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			--	and det.intBookId = case when isnull(@intBookId,0) =0 then det.intBookId else @intBookId end
			--and det.intSubBookId = case when isnull(@intSubBookId,0) =0 then det.intSubBookId else @intSubBookId end	
	)t
		WHERE intCompanyLocationId IN (
		SELECT intCompanyLocationId FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
						ELSE isnull(ysnLicensed, 0) END
		))t group by strCommodityCode ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType
-- DP
INSERT INTO @InventoryStock(strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType)
select strCommodityCode ,sum(dblTotal)  dblTotal,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType from(
select strCommodityCode ,dblTotal ,strLocationName ,intCommodityId,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId , 'DP' strInventoryType from (
					SELECT strCommodityCode,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal,
					strLocationName,c.intCommodityId,ch.intCompanyLocationId
					FROM @tblGetStorageDetailByDate ch
					join tblICCommodity c on ch.intCommodityId=c.intCommodityId
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t 	WHERE intCompanyLocationId  IN (
				SELECT intCompanyLocationId FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
				))t group by strCommodityCode ,strLocationName ,intCommodityId,intFromCommodityUnitMeasureId ,strInventoryType

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
	)
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
		  when strType= 'Purchase Basis'  then 10 
		  when strType= 'Sale Basis'  then 11
		  when strType= 'Purchase DP (Priced Later)'  then 12 
		  when strType= 'Sale DP (Priced Later)'  then 13  end  intOrderId
FROM @FinalList
WHERE strContractEndMonth = 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)')

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
	)
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
		  when strType= 'Purchase Basis'  then 10 
		  when strType= 'Sale Basis'  then 11
		  when strType= 'Purchase DP (Priced Later)'  then 12 
		  when strType= 'Sale DP (Priced Later)'  then 13  end  intOrderId
FROM @FinalList 
WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)')
ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC


INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType,intPricingTypeId)
SELECT 	strCommodityCode,dblTotal,'Near By',strLocationName,intCommodityId,intFromCommodityUnitMeasureId,5 intOrderId,'Inventory',strInventoryType,intPricingTypeId from @InventoryStock 
where strInventoryType='Inventory'

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType,intPricingTypeId)
SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,6 intOrderId,'Net Physical Position' strType,
strInventoryType,intPricingTypeId FROM @List WHERE intOrderId in(1,2,3,4,5)


INSERT INTO @List (
				strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,intOrderId
				)
			SELECT strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,'Pre-Crush'
				,strLocationName
				,strFutureMonth
				,dtmFutureMonthsDate
				,HedgedQty
				,intUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,7 intOrderId
			FROM (
				SELECT  
					strCommodityCode
					,strInternalTradeNo
					,intFutOptTransactionHeaderId
					,f.intCommodityId
					,left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) dtmFutureMonthsDate
					,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END * dblContractSize) AS HedgedQty
					,l.strLocationName
					,left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) strFutureMonth
					,m.intUnitMeasureId
					,e.strName + '-' + ba.strAccountNumber strAccountNumber
					,strBuySell AS strTranType
					,f.intBrokerageAccountId
					,CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END AS strInstrumentType
					,CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END dblNoOfLot
				FROM @tblGetOpenFutureByDate oc
				JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 and isnull(ysnPreCrush,0)=1
				INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
				INNER JOIN tblICCommodity ic ON f.intCommodityId = ic.intCommodityId
				JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
				INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
				INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
				 AND intCompanyLocationId IN (
						SELECT intCompanyLocationId
						FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
						)
				INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
				INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
				WHERE ic.intCommodityId IN (select distinct intCommodity from @Commodity c) 
				AND f.intLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN f.intLocationId ELSE @intLocationId END
				--and f.intBookId = case when isnull(@intBookId,0) =0 then f.intBookId else @intBookId end
				--and f.intSubBookId = case when isnull(@intSubBookId,0) =0 then f.intSubBookId else @intSubBookId end
				) t

INSERT INTO @List (
				strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,intOrderId
				)
			SELECT strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,'Net Futures'
				,strLocationName
				,strFutureMonth
				,dtmFutureMonthsDate
				,HedgedQty
				,intUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,8 intOrderId
			FROM (
				SELECT  
					strCommodityCode
					,strInternalTradeNo
					,intFutOptTransactionHeaderId
					,f.intCommodityId
					,left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) dtmFutureMonthsDate
					,dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END * dblContractSize) AS HedgedQty
					,l.strLocationName
					,left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) strFutureMonth
					,m.intUnitMeasureId
					,e.strName + '-' + ba.strAccountNumber strAccountNumber
					,strBuySell AS strTranType
					,f.intBrokerageAccountId
					,CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END AS strInstrumentType
					,CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END dblNoOfLot
				FROM @tblGetOpenFutureByDate oc
				JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 and isnull(ysnPreCrush,0)=0
				INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
				INNER JOIN tblICCommodity ic ON f.intCommodityId = ic.intCommodityId
				JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
				INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
				INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
				 AND intCompanyLocationId IN (
						SELECT intCompanyLocationId
						FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
						)
				INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
				INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
				WHERE ic.intCommodityId IN (select distinct intCommodity from @Commodity c) 
				AND f.intLocationId = CASE WHEN isnull(@intLocationId, 0) = 0 THEN f.intLocationId ELSE @intLocationId END
				--and f.intBookId = case when isnull(@intBookId,0) =0 then f.intBookId else @intBookId end
				--and f.intSubBookId = case when isnull(@intSubBookId,0) =0 then f.intSubBookId else @intSubBookId end
				) t

INSERT INTO @List (
				strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,intOrderId
				)
SELECT strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,'Net Price Risk Position' strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,9 FROM  @List WHERE intOrderId in(1,2,3,4,7,8) 
union all
SELECT strCommodityCode
				,intCommodityId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,'Net Price Risk Position' strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,intFromCommodityUnitMeasureId
				,strAccountNumber
				,strTranType
				,intBrokerageAccountId
				,strInstrumentType
				,dblNoOfLot
				,9 FROM  @List WHERE intOrderId = 6  and intPricingTypeId = 1

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,14 intOrderId,'Net Unpriced Position' strType,strInventoryType from @List where intOrderId in(10,11,12,13)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
SELECT 	strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,15 intOrderId,'Owned Quantity Position' strType,strInventoryType from @List where intOrderId in(6,14)


DECLARE @ListFinal AS TABLE (
		intRowNumber1 INT IDENTITY(1, 1),
		intRowNumber INT
		,intContractHeaderId INT
		,strContractNumber NVARCHAR(200)
		,intFutOptTransactionHeaderId INT
		,strInternalTradeNo NVARCHAR(200)
		,intCommodityId INT
		,strCommodityCode NVARCHAR(200)
		,strType NVARCHAR(50)
		,strLocationName NVARCHAR(100)
		,strContractEndMonth NVARCHAR(50)
		,strContractEndMonthNearBy NVARCHAR(50)
		,dblTotal DECIMAL(24, 10)
		,intSeqNo INT
		,strUnitMeasure NVARCHAR(50)
		,intFromCommodityUnitMeasureId INT
		,intToCommodityUnitMeasureId INT
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId INT
		,strInstrumentType NVARCHAR(50)
		,strEntityName NVARCHAR(100)
		,intOrderId int
		,strInventoryType NVARCHAR(100)
		)


DECLARE @MonthOrderList AS TABLE (		
		strContractEndMonth NVARCHAR(100))

insert into @MonthOrderList
SELECT distinct  strContractEndMonth FROM @List where strContractEndMonth <> 'Near By' 

DECLARE @MonthOrderListFinal AS TABLE (		
		strContractEndMonth NVARCHAR(100))

insert into @MonthOrderListFinal 
SELECT 'Near By' 
insert into @MonthOrderListFinal 
SELECT  strContractEndMonth from @MonthOrderList order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

DECLARE @TopRowRec AS TABLE (		
		strType NVARCHAR(100),
		strCommodityCode NVARCHAR(100))
insert into @TopRowRec 
SELECT TOP 1 strType,strCommodityCode from @List 

insert into @ListFinal(
		strCommodityCode		
		,strType		
		,strContractEndMonth
		,dblTotal)
SELECT   strCommodityCode		
		,strType		
		,strContractEndMonth		
		,0.0 dblTotal
	FROM @TopRowRec t
	cross join @MonthOrderListFinal t1
	
insert into @ListFinal(intSeqNo
		,intRowNumber
		,strCommodityCode
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
		,strEntityName,intOrderId)
SELECT intSeqNo
		,intRowNumber
		,strCommodityCode
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
		,strEntityName,intOrderId
	FROM @List 
	WHERE --ISNULL(dblTotal,0) <> 0 
	 strContractEndMonth = 'Near By'

insert into @ListFinal(intSeqNo
		,intRowNumber
		,strCommodityCode
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
		,strEntityName,intOrderId)
SELECT intSeqNo
		,intRowNumber
		,strCommodityCode
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
		,strEntityName,intOrderId
	FROM @List 
	WHERE ISNULL(dblTotal,0) <> 0 
	and strContractEndMonth not in( 'Near By') order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

	select intSeqNo
		,convert(int,row_number() over (order by intSeqNo)) intRowNumber
		,strCommodityCode
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
		,strEntityName,intOrderId from @ListFinal  order by intOrderId