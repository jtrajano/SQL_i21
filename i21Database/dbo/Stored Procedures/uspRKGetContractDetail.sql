CREATE PROC uspRKGetContractDetail 
	@intCommodityId int,
	@intLocationId int = NULL,
	@intSeqId int
AS
declare  @tblTemp table
			(intContractDetailId int,
			strLocationName nvarchar(50),
			strContractNumber nvarchar(50),
			intContractSeq int,
			strEntityName nvarchar(100),
			dtmEndDate datetime,
			Comments nvarchar(500),
			strShipVia nvarchar(500),
			dblCashPrice numeric(24,10),
			strPricingType nvarchar(50),
			strCurrency nvarchar(50),
			dblTotal numeric(24,10),
			intCommodityId int
			)

IF @intSeqId = 1
BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 and CD.intContractStatusId <> 3  AND CD.intPricingTypeId IN (1)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (1)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 2
	BEGIN

		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (2)
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 and CD.intContractStatusId <> 3 AND CD.intPricingTypeId IN (2)
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 3
	BEGIN
	
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END
	
ELSE IF @intSeqId = 4
	BEGIN

		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (1) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (1) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END

	
ELSE IF @intSeqId = 5
	BEGIN

		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (2) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (2) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId 
		END	
		
	END

ELSE IF @intSeqId = 6
	BEGIN

		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId AND CD.intCompanyLocationId = @intLocationId
		END
		ELSE
		BEGIN 
		INSERT INTO @tblTemp (intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal,intCommodityId)

			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
					CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
					strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (3) and CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId 
		END	
		
END
DECLARE @intUnitMeasureId int
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
if isnull(@intUnitMeasureId,'')<> ''
BEGIN

SELECT intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,
	isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,round(dblTotal,4)),0) dblTotal
FROM @tblTemp t
JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
END
ELSE
BEGIN
SELECT intContractDetailId,strLocationName,strContractNumber,intContractSeq ,strEntityName ,dtmEndDate ,Comments ,strShipVia ,
	dblCashPrice ,strPricingType ,strCurrency ,dblTotal FROM @tblTemp
END