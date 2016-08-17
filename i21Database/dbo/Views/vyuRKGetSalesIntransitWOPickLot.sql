CREATE VIEW vyuRKGetSalesIntransitWOPickLot
AS
SELECT strContractNumber,
		dblShipmentQty,
		intCompanyLocationId,
		strLocationName,
		intContractDetailId,
		dblInvoiceQty,
		(isnull(dblShipmentQty,0)-isnull(dblInvoiceQty,0)) dblBalanceToInvoice,intCommodityId,strContractItemName as  strItemName, intCommodityUnitMeasureId as intUnitMeasureId
		,intEntityId
from(
		SELECT d.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
				c.dblQuantity dblShipmentQty,
				d.intCompanyLocationId,
				d.strLocationName,
				d.intContractDetailId,
				intCommodityId,
				c.intItemUOMId,
				d.strContractItemName,
				d.intCommodityUnitMeasureId,
				d.intEntityId,
				isnull((SELECT isnull(id.dblQtyShipped,0) FROM tblARInvoice i
					join tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intContractDetailId=d.intContractDetailId),0) dblInvoiceQty
		FROM tblICInventoryShipment b
		JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1 
		JOIN vyuCTContractDetailView d on d.intContractDetailId=c.intLineNo		
		)t
