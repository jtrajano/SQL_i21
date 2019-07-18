﻿CREATE PROC uspRKGetBasisDeliveries
	@intCommodityId int
	, @intLocationId int = NULL
	, @intSeqId int

AS

DECLARE @tblTemp TABLE (intInventoryShipmentItemId int
	, strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmTicketDateTime datetime
	, strCustomerReference NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDistributionOption NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, dblTotal NUMERIC(24,10)
	, intCommodityId int)
						
IF @intSeqId = 13
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intInventoryShipmentItemId
			, strLocationName
			, strTicketNumber
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblTotal
			, intCommodityId)
		SELECT PLDetail.intPickLotDetailId as intInventoryShipmentItemId
			, cl.strLocationName
			, (convert(nvarchar,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq)) COLLATE Latin1_General_CI_AS strTicketNumber
			, CT.dtmContractDate as dtmTicketDateTime
			, CT.strCustomerContract as strCustomerReference
			, 'CNT' COLLATE Latin1_General_CI_AS as strDistributionOption
			, PLDetail.dblLotPickedQty AS dblTotal
			, CT.intCommodityId
		FROM tblLGDeliveryPickDetail Del
		INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
		INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
		INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId and CT.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
		WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId and CT.intCompanyLocationId=@intLocationId
		
		UNION ALL SELECT ri.intInventoryReceiptItemId as intInventoryShipmentItemId
			, cl.strLocationName
			, strTicketNumber strTicketNumber
			, st.dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, isnull(ri.dblReceived, 0) AS dblTotal
			, st.intCommodityId
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
		WHERE ch.intCommodityId = @intCommodityId and st.intProcessingLocationId =@intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intInventoryShipmentItemId
			, strLocationName
			, strTicketNumber
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblTotal
			, intCommodityId)
		SELECT PLDetail.intPickLotDetailId as intInventoryShipmentItemId
			, CT.strLocationName
			, (CONVERT(NVARCHAR,CT.strContractNumber)+'/'+convert(nvarchar,CT.intContractSeq)) COLLATE Latin1_General_CI_AS strTicketNumber
			, CT.dtmContractDate as dtmTicketDateTime
			, CT.strCustomerContract as strCustomerReference
			, 'CNT' COLLATE Latin1_General_CI_AS as strDistributionOption
			, PLDetail.dblLotPickedQty AS dblTotal
			, CT.intCommodityId
		FROM tblLGDeliveryPickDetail Del
		INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
		INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
		INNER JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = Lots.intContractDetailId and CT.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=CT.intCompanyLocationId
		WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId

		UNION ALL SELECT ri.intInventoryReceiptItemId as intInventoryShipmentItemId
			, cl.strLocationName
			, strTicketNumber strTicketNumber
			, st.dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, isnull(ri.dblReceived, 0) AS dblTotal
			, st.intCommodityId
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
		WHERE ch.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 14
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (intInventoryShipmentItemId
			, strLocationName
			, strTicketNumber
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblTotal
			, intCommodityId)
		SELECT ri.intInventoryShipmentItemId
			, cl.strLocationName
			, (CONVERT(NVARCHAR,ch.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq)) COLLATE Latin1_General_CI_AS strTicketNumber
			, ch.dtmContractDate as dtmTicketDateTime
			, ch.strCustomerContract as strCustomerReference
			, 'CNT' COLLATE Latin1_General_CI_AS as strDistributionOption
			, ri.dblQuantity AS dblTotal
			, intCommodityId
		FROM tblICInventoryShipment r
		INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	 and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
		WHERE ch.intCommodityId = @intCommodityId AND cl.intCompanyLocationId=@intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (intInventoryShipmentItemId
			, strLocationName
			, strTicketNumber
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblTotal
			, intCommodityId)
		SELECT ri.intInventoryShipmentItemId
			, cl.strLocationName
			, (convert(nvarchar,ch.strContractNumber)+'/'+convert(nvarchar,cd.intContractSeq)) COLLATE Latin1_General_CI_AS strTicketNumber
			, ch.dtmContractDate as dtmTicketDateTime
			, ch.strCustomerContract as strCustomerReference
			, 'CNT' COLLATE Latin1_General_CI_AS as strDistributionOption
			, ri.dblQuantity AS dblTotal
			, intCommodityId
		FROM tblICInventoryShipment r
		INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	and cd.intContractStatusId <> 3
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=cd.intCompanyLocationId
		WHERE ch.intCommodityId = @intCommodityId
	END
END

SELECT intInventoryShipmentItemId
	, strLocationName
	, strTicketNumber
	, dtmTicketDateTime
	, strCustomerReference
	, strDistributionOption
	, dblTotal
FROM @tblTemp