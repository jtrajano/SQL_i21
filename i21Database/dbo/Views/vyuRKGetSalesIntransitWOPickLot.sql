CREATE VIEW [dbo].[vyuRKGetSalesIntransitWOPickLot]
AS
SELECT strShipmentNumber as strTicket,
		strContractNumber,
        dblShipmentQty,
        intCompanyLocationId,
        strLocationName,
        intContractDetailId,
        dblInvoiceQty,
        (isnull(dblShipmentQty,0)-isnull(dblInvoiceQty,0)) dblBalanceToInvoice,intCommodityId,strContractItemName as  strItemName, intCommodityUnitMeasureId as intUnitMeasureId
        ,intEntityId,strName as strCustomerReference   
from(
    SELECT distinct b.strShipmentNumber,d.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
        c.dblQuantity dblShipmentQty,
        cl.intCompanyLocationId intCompanyLocationId,
        cl.strLocationName strLocationName,
        d.intContractDetailId,
        i.intCommodityId,
        iuom.intItemUOMId,
        i.strItemNo as strContractItemName,
        ium.intCommodityUnitMeasureId,
        b.intEntityCustomerId as intEntityId,
        isnull((SELECT sum(isnull(id.dblQtyShipped,0)) FROM tblARInvoice i
                        join tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId and i.ysnPosted=1 and id.intInventoryShipmentItemId=c.intInventoryShipmentItemId),0) dblInvoiceQty,
                        e.strName
    FROM tblICInventoryShipment b
    JOIN tblICInventoryShipmentItem c on c.intInventoryShipmentId=b.intInventoryShipmentId and b.ysnPosted=1 
    join tblICItem i on c.intItemId=i.intItemId
    JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
    JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1 
    JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
    JOIN tblEMEntity e on b.intEntityCustomerId=e.intEntityId
    LEFT JOIN vyuCTContractDetailView d on d.intContractDetailId=c.intLineNo   
    LEFT JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=d.intCompanyLocationId                         
)t
