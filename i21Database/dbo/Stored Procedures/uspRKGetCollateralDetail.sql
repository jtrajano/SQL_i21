CREATE PROC uspRKGetCollateralDetail 
	@intCommodityId int,
	@intLocationId int = NULL,
	@strCollateralType nvarchar(20)
AS

declare  @tblTemp table
			(intCollateralId int,
			strLocationName nvarchar(50),
			strCustomer nvarchar(50),
			intReceiptNo nvarchar(50),
			strContractNumber nvarchar(100),
			dtmOpenDate datetime,
			dblOriginalQuantity  numeric(24,10),
			dblRemainingQuantity numeric(24,10),
			intCommodityId int
			)

IF @strCollateralType ='Sale'
BEGIN
IF ISNULL(@intLocationId, 0) <> 0
BEGIN
INSERT INTO @tblTemp (intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId)
	    SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId	
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
END
ELSE
BEGIN
INSERT INTO @tblTemp (intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId)
	    SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,c.intCommodityId	
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId

END
		
END
ELSE
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
		INSERT INTO @tblTemp (intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId)
				SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
				isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId	
				FROM tblRKCollateral c
				LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
		END
	ELSE
		BEGIN
		
		INSERT INTO @tblTemp (intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,dblOriginalQuantity,dblRemainingQuantity,intCommodityId)
				SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
				isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity,c.intCommodityId	
				FROM tblRKCollateral c
				LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId
				
		END
END
			
DECLARE @intUnitMeasureId int
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
if isnull(@intUnitMeasureId,'')<> ''
BEGIN

SELECT intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,
isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,round(dblOriginalQuantity,4)),0) dblOriginalQuantity,
isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,round(dblRemainingQuantity,4)),0) dblRemainingQuantity
	FROM @tblTemp t
JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
END
ELSE
BEGIN
SELECT intCollateralId,strLocationName,strCustomer,intReceiptNo,strContractNumber,dtmOpenDate,dblOriginalQuantity FROM @tblTemp
END