CREATE PROC uspRKDPRSalesIntransitWOPickLot 
	@intCommodityId int,
	@dtmToDate datetime=null

AS

set @dtmToDate=convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

SELECT strShipmentNumber as strTicket,strContractNumber,
		dblShipmentQty,
		intCompanyLocationId,
		strLocationName,
		intContractDetailId,
		dblInvoiceQty,
		(isnull(dblShipmentQty,0)-isnull(dblInvoiceQty,0)) dblBalanceToInvoice,
		intCommodityId,
		strContractItemName as  strItemName, 
		intCommodityUnitMeasureId as intUnitMeasureId
		,intEntityId,strName as strCustomerReference	
FROM(
				SELECT b.strShipmentNumber,d1.strContractNumber +'-' +Convert(nvarchar,d.intContractSeq) strContractNumber,
				(SELECT TOP 1 dblQty FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) dblShipmentQty,
				il.intLocationId intCompanyLocationId,
				il.strDescription strLocationName,
				d.intContractDetailId,
				i.intCommodityId,
				iuom.intItemUOMId,
				i.strItemNo as strContractItemName,
				ium.intCommodityUnitMeasureId,
				b.intEntityCustomerId as intEntityId,
				(SELECT TOP 1 dblQty FROM tblARInvoice ia
				JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId 
				WHERE ad.strDocumentNumber=it.strTransactionId and ysnPosted=1 ) dblInvoiceQty,
					e.strName
		FROM tblICInventoryTransaction it
		  join tblICInventoryShipment b on b.strShipmentNumber=it.strTransactionId  
		JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1 
		join tblICItem i on c.intItemId=i.intItemId
		JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICItemLocation il ON it.intItemId = i.intItemId and it.intItemLocationId=il.intItemLocationId and il.strDescription='In-Transit'		
		JOIN tblEMEntity e on b.intEntityCustomerId=e.intEntityId
		LEFT JOIN tblCTContractDetail d on d.intContractDetailId=c.intLineNo		
		LEFT JOIN tblCTContractHeader d1 on d1.intContractHeaderId=d.intContractHeaderId
		WHERE i.intCommodityId = @intCommodityId and convert(DATETIME, CONVERT(VARCHAR(10), it.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate)
	)t