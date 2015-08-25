CREATE PROC uspRKGetCollateralDetail 
	@intCommodityId int,
	@intLocationId int = NULL,
	@strCollateralType nvarchar(20)
AS
IF @strCollateralType ='Sale'
BEGIN
IF ISNULL(@intLocationId, 0) <> 0
BEGIN
	    SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity	
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
END
ELSE
BEGIN
	    SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
		isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity	
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
				SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
				isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity	
				FROM tblRKCollateral c
				LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId AND c.intLocationId = @intLocationId
		END
	ELSE
		BEGIN
				SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
				isnull(c.dblOriginalQuantity,0) dblOriginalQuantity,c.dblRemainingQuantity	
				FROM tblRKCollateral c
				LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
				JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
				WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId
		END
END
			
