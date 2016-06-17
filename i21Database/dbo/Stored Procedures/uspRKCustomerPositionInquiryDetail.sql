CREATE PROCEDURE uspRKCustomerPositionInquiryDetail
			@intCommodityId int, 
			@intLocationId int = null, 
			@intSeqId int, 
			@strGrainType nvarchar(20),
			@intVendorCustomerId INT = NULL
AS
BEGIN
	
IF @intSeqId= 1
		BEGIN		
		
			SELECT intCustomerStorageId, 'Off-Site' strType, Loc AS strLocation, [Delivery Date] AS dtmDeliveryDate, Ticket strTicket, Customer AS strCustomerReference, Receipt AS strDPAReceiptNo, [Disc Due] AS dblDiscDue, [Storage Due] AS dblStorageDue, dtmLastStorageAccrueDate, strScheduleId, ISNULL(Balance, 0) dblTotal, intCommodityId
			FROM vyuGRGetStorageDetail
			WHERE intCommodityId = @intCommodityId AND ysnDPOwnedType = 0 AND ysnReceiptedStorage = 0 AND [Storage Type] = @strGrainType
			AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId AND ISNULL(Balance, 0) >0
	
		END

ELSE IF @intSeqId=3
		BEGIN
			SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
			isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId	
			FROM tblRKCollateral c
			LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
			JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
			WHERE strType = 'Purchase' and c.intCommodityId=@intCommodityId
			AND c.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId
			
		END
		
ELSE IF @intSeqId=4
		BEGIN						
			SELECT c.intCollateralId,cl.strLocationName,c.strCustomer,c.intReceiptNo,ch.strContractNumber,c.dtmOpenDate,
			isnull(c.dblOriginalQuantity,0.0) dblOriginalQuantity,isnull(c.dblRemainingQuantity,0.0) as dblRemainingQuantity,c.intCommodityId	
			FROM tblRKCollateral c
			LEFT JOIN tblCTContractHeader ch on c.intContractHeaderId=ch.intContractHeaderId
			JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
			WHERE strType = 'Sale' and c.intCommodityId=@intCommodityId
			AND c.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId
			
		END
		
ELSE IF @intSeqId=5
		BEGIN
			SELECT intCustomerStorageId,'Off-Site' strType ,Loc AS strLocation ,[Delivery Date] AS dtmDeliveryDate ,Ticket strTicket  
			,Customer as strCustomerReference ,Receipt AS strDPAReceiptNo ,[Disc Due] AS dblDiscDue ,[Storage Due] AS dblStorageDue  
			,dtmLastStorageAccrueDate ,strScheduleId ,ISNULL(Balance, 0) dblTotal,intCommodityId   
			FROM vyuGRGetStorageDetail  
			WHERE  ysnReceiptedStorage = 1  AND intCommodityId = @intCommodityId 
			AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId AND ISNULL(Balance, 0) >0
		END

ELSE IF @intSeqId=8
		BEGIN
		SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
			CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
			strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (1) and CD.intContractStatusId <> 3
			and CD.intCommodityId = @intCommodityId 
			AND CD.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) >0
		END
		
ELSE IF @intSeqId=9
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
			CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
			strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (1)
			and CD.intCommodityId = @intCommodityId  and CD.intContractStatusId <> 3
			AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId	AND ISNULL(dblBalance, 0) >0		
		END

ELSE IF @intSeqId=10
		BEGIN
			SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
			CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
			strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
			FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (2)
			and CD.intCommodityId = @intCommodityId   and CD.intContractStatusId <> 3
			AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
			AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) >0			
		END
		
ELSE IF @intSeqId=11
BEGIN
	SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
	CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
	strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
	FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (2)  and CD.intContractStatusId <> 3
	and CD.intCommodityId = @intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) >0	
END

ELSE IF @intSeqId=12
BEGIN
	SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
	CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
	strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
	FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 1  AND CD.intPricingTypeId IN (3)  and CD.intContractStatusId <> 3
	and CD.intCommodityId = @intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) >0	
END

ELSE IF @intSeqId=13
BEGIN
	SELECT  CD.intContractDetailId,CD.strLocationName,CD.strContractNumber,CD.intContractSeq,strEntityName,
	CD.dtmEndDate,CD.strRemark as Comments,strFreightTerm as strShipVia,isnull(dblCashPrice,0) dblCashPrice,
	strPricingType,strCurrency,isnull(CD.dblBalance,0) AS dblTotal,intCommodityId
	FROM vyuCTContractDetailView CD WHERE   CD.intContractTypeId = 2  AND CD.intPricingTypeId IN (3)  and CD.intContractStatusId <> 3
	and CD.intCommodityId = @intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) >0	
END

ELSE IF @intSeqId=14
BEGIN		
		
		SELECT intInventoryReceiptItemId as intInventoryShipmentItemId,cl.strLocationName,
		convert(nvarchar,ch.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq) strTicketNumber,ch.dtmContractDate as dtmTicketDateTime,
		ch.strCustomerContract as strCustomerReference, 'CNT' as strDistributionOption,isnull(ri.dblOpenReceive, 0) AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end

END
END
