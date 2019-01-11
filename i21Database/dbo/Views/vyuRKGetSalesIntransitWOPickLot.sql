﻿CREATE VIEW vyuRKGetSalesIntransitWOPickLot

AS

SELECT strShipmentNumber as strTicket
	, strContractNumber
	, dtmContractDate
	, dblShipmentQty
	, intCompanyLocationId
	, strLocationName
	, intContractDetailId
	, dblInvoiceQty
	, (isnull(dblShipmentQty,0)-isnull(dblInvoiceQty,0)) dblBalanceToInvoice
	, intCommodityId
	, strContractItemName as strItemName
	, intCommodityUnitMeasureId as intUnitMeasureId
	, intEntityId
	, strName as strCustomerReference
FROM (
	SELECT b.strShipmentNumber
		, (d1.strContractNumber +'-' +Convert(nvarchar,d.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
		, d1.dtmContractDate
		, c.dblQuantity dblShipmentQty
		, il.intLocationId intCompanyLocationId
		, cl.strLocationName strLocationName
		, d.intContractDetailId
		, i.intCommodityId
		, iuom.intItemUOMId
		, i.strItemNo as strContractItemName
		, ium.intCommodityUnitMeasureId
		, b.intEntityCustomerId as intEntityId
		, isnull((SELECT isnull(id.dblQtyShipped,0) FROM tblARInvoice i
				JOIN tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intInventoryShipmentItemId=c.intInventoryShipmentItemId),0) dblInvoiceQty
		, e.strName
	FROM tblICInventoryShipment b
	JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1
	join tblICItem i on c.intItemId=i.intItemId
	JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
	JOIN tblICItemLocation il ON il.intItemId = i.intItemId and b.intShipFromLocationId=il.intLocationId
	JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=il.intLocationId
	JOIN tblEMEntity e on b.intEntityCustomerId=e.intEntityId
	LEFT JOIN tblCTContractDetail d on d.intContractDetailId=c.intLineNo
	LEFT JOIN tblCTContractHeader d1 on d1.intContractHeaderId=d.intContractHeaderId
) t