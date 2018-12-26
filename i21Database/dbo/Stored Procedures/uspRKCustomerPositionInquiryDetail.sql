CREATE PROCEDURE uspRKCustomerPositionInquiryDetail
	@intCommodityId INT
	, @intLocationId INT = NULL
	, @intSeqId INT
	, @strGrainType NVARCHAR(20)
	, @intVendorCustomerId INT = NULL

AS
BEGIN
	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END

	IF @intSeqId = 1
	BEGIN
		SELECT intCustomerStorageId
			, strType = 'Off-Site' COLLATE Latin1_General_CI_AS
			, strLocation = Loc COLLATE Latin1_General_CI_AS
			, dtmDeliveryDate = [Delivery Date]
			, strTicket = Ticket COLLATE Latin1_General_CI_AS
			, strCustomerReference = Customer COLLATE Latin1_General_CI_AS
			, strDPAReceiptNo = Receipt COLLATE Latin1_General_CI_AS
			, dblDiscDue = [Disc Due]
			, dblStorageDue = [Storage Due]
			, dtmLastStorageAccrueDate
			, strScheduleId COLLATE Latin1_General_CI_AS
			, ISNULL(Balance, 0) dblTotal
			, intCommodityId
		FROM vyuGRGetStorageDetail
		WHERE intCommodityId = @intCommodityId AND ysnDPOwnedType = 0 AND ysnReceiptedStorage = 0 AND [Storage Type] = @strGrainType
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(Balance, 0) > 0
	END
	ELSE IF @intSeqId = 3
	BEGIN
		SELECT c.intCollateralId
			, cl.strLocationName COLLATE Latin1_General_CI_AS
			, c.strCustomer COLLATE Latin1_General_CI_AS
			, c.intReceiptNo
			, ch.strContractNumber COLLATE Latin1_General_CI_AS
			, c.dtmOpenDate
			, dblOriginalQuantity = ISNULL(c.dblOriginalQuantity, 0.0)
			, dblRemainingQuantity = ISNULL(c.dblRemainingQuantity, 0.0)
			, c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch ON c.intContractHeaderId = ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		WHERE strType = 'Purchase' AND c.intCommodityId = @intCommodityId
			AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
			AND intEntityId = @intVendorCustomerId
	END
	ELSE IF @intSeqId = 4
	BEGIN
		SELECT c.intCollateralId
			, cl.strLocationName COLLATE Latin1_General_CI_AS
			, c.strCustomer COLLATE Latin1_General_CI_AS
			, c.intReceiptNo
			, ch.strContractNumber COLLATE Latin1_General_CI_AS
			, c.dtmOpenDate
			, dblOriginalQuantity = ISNULL(c.dblOriginalQuantity, 0.0)
			, dblRemainingQuantity = ISNULL(c.dblRemainingQuantity, 0.0)
			, c.intCommodityId
		FROM tblRKCollateral c
		LEFT JOIN tblCTContractHeader ch ON c.intContractHeaderId = ch.intContractHeaderId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		WHERE strType = 'Sale' AND c.intCommodityId=@intCommodityId
			AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
			AND intEntityId = @intVendorCustomerId
	END
	ELSE IF @intSeqId = 5
	BEGIN
		SELECT intCustomerStorageId
			, strType = 'Off-Site' COLLATE Latin1_General_CI_AS
			, strLocation = Loc COLLATE Latin1_General_CI_AS
			, dtmDeliveryDate = [Delivery Date]
			, strTicket = Ticket COLLATE Latin1_General_CI_AS
			, strCustomerReference = Customer COLLATE Latin1_General_CI_AS
			, strDPAReceiptNo = Receipt COLLATE Latin1_General_CI_AS
			, dblDiscDue = [Disc Due]
			, dblStorageDue = [Storage Due]
			, dtmLastStorageAccrueDate
			, strScheduleId COLLATE Latin1_General_CI_AS
			, dblTotal = ISNULL(Balance, 0)
			, intCommodityId
		FROM vyuGRGetStorageDetail
		WHERE ysnReceiptedStorage = 1 AND intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(Balance, 0) > 0
	END
	ELSE IF @intSeqId = 8
	BEGIN
		SELECT CD.intContractDetailId
			, CD.strLocationName COLLATE Latin1_General_CI_AS
			, CD.strContractNumber COLLATE Latin1_General_CI_AS
			, CD.intContractSeq
			, strEntityName COLLATE Latin1_General_CI_AS
			, CD.dtmEndDate
			, Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			, strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			, dblCashPrice = ISNULL(dblCashPrice, 0)
			, strPricingType COLLATE Latin1_General_CI_AS
			, strCurrency COLLATE Latin1_General_CI_AS
			, dblTotal = ISNULL(CD.dblBalance, 0)
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (1) AND CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId 
			AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 9
	BEGIN
		SELECT CD.intContractDetailId
			, CD.strLocationName COLLATE Latin1_General_CI_AS
			, CD.strContractNumber COLLATE Latin1_General_CI_AS
			, CD.intContractSeq
			, strEntityName COLLATE Latin1_General_CI_AS
			, CD.dtmEndDate
			, Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			, strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			, dblCashPrice = ISNULL(dblCashPrice, 0)
			, strPricingType COLLATE Latin1_General_CI_AS
			, strCurrency COLLATE Latin1_General_CI_AS
			, dblTotal = ISNULL(CD.dblBalance, 0)
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (1)
			AND CD.intCommodityId = @intCommodityId AND CD.intContractStatusId <> 3
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 10
	BEGIN
		SELECT CD.intContractDetailId
			, CD.strLocationName COLLATE Latin1_General_CI_AS
			, CD.strContractNumber COLLATE Latin1_General_CI_AS
			, CD.intContractSeq
			, strEntityName COLLATE Latin1_General_CI_AS
			, CD.dtmEndDate
			, Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			, strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			, dblCashPrice = ISNULL(dblCashPrice, 0)
			, strPricingType COLLATE Latin1_General_CI_AS
			, strCurrency COLLATE Latin1_General_CI_AS
			, dblTotal = ISNULL(CD.dblBalance, 0)
			, intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (2)
			AND CD.intCommodityId = @intCommodityId AND CD.intContractStatusId <> 3
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId=@intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 11
	BEGIN
		SELECT CD.intContractDetailId
			,CD.strLocationName COLLATE Latin1_General_CI_AS
			,CD.strContractNumber COLLATE Latin1_General_CI_AS
			,CD.intContractSeq 
			,strEntityName COLLATE Latin1_General_CI_AS
			,CD.dtmEndDate
			,Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			,strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			,dblCashPrice = ISNULL(dblCashPrice, 0)
			,strPricingType COLLATE Latin1_General_CI_AS
			,strCurrency COLLATE Latin1_General_CI_AS
			,dblTotal = ISNULL(CD.dblBalance, 0)
			,intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (2) AND CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 12
	BEGIN
		SELECT CD.intContractDetailId
			,CD.strLocationName COLLATE Latin1_General_CI_AS
			,CD.strContractNumber COLLATE Latin1_General_CI_AS
			,CD.intContractSeq
			,strEntityName COLLATE Latin1_General_CI_AS
			,CD.dtmEndDate
			,Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			,strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			,dblCashPrice = ISNULL(dblCashPrice, 0)
			,strPricingType COLLATE Latin1_General_CI_AS
			,strCurrency COLLATE Latin1_General_CI_AS
			,dblTotal = ISNULL(CD.dblBalance, 0)
			,intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 1 AND CD.intPricingTypeId IN (3) AND CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 13
	BEGIN
		SELECT CD.intContractDetailId
			,CD.strLocationName COLLATE Latin1_General_CI_AS
			,CD.strContractNumber COLLATE Latin1_General_CI_AS
			,CD.intContractSeq
			,strEntityName COLLATE Latin1_General_CI_AS
			,CD.dtmEndDate
			,Comments = CD.strRemark COLLATE Latin1_General_CI_AS
			,strShipVia = strFreightTerm COLLATE Latin1_General_CI_AS
			,dblCashPrice = ISNULL(dblCashPrice, 0)
			,strPricingType COLLATE Latin1_General_CI_AS
			,strCurrency COLLATE Latin1_General_CI_AS
			,dblTotal = ISNULL(CD.dblBalance, 0)
			,intCommodityId
		FROM vyuCTContractDetailView CD
		WHERE CD.intContractTypeId = 2 AND CD.intPricingTypeId IN (3) AND CD.intContractStatusId <> 3
			AND CD.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND intEntityId = @intVendorCustomerId AND ISNULL(dblBalance, 0) > 0
	END
	ELSE IF @intSeqId = 14
	BEGIN
		SELECT intInventoryShipmentItemId = intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,strTicketNumber = CONVERT(NVARCHAR, ch.strContractNumber) COLLATE Latin1_General_CI_AS + '/' + CONVERT(NVARCHAR,cd.intContractSeq) COLLATE Latin1_General_CI_AS
			,dtmTicketDateTime = ch.dtmContractDate
			,strCustomerReference = ch.strCustomerContract COLLATE Latin1_General_CI_AS
			,strDistributionOption = 'CNT' COLLATE Latin1_General_CI_AS
			,dblTotal = ISNULL(ri.dblOpenReceive, 0)
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId = cd.intCompanyLocationId
		WHERE ch.intCommodityId = @intCommodityId AND ch.intEntityId = @intVendorCustomerId
			AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
	END
END