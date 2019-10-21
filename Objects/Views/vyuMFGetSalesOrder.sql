CREATE VIEW [dbo].[vyuMFGetSalesOrder]
AS 
Select sh.intSalesOrderId,sh.strSalesOrderNumber,sh.dtmDueDate,c.strName AS strCustomerName,cl.strLocationName,
sd.intSalesOrderDetailId,
i.intItemId,i.strItemNo,i.strDescription,sd.dblQtyOrdered AS dblOrderedQty,sd.intItemUOMId,um.strUnitMeasure AS strUOM
From tblSOSalesOrder sh Join tblSOSalesOrderDetail sd on sh.intSalesOrderId=sd.intSalesOrderId 
Join tblICItem i on sd.intItemId=i.intItemId
Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblSMCompanyLocation cl on sh.intCompanyLocationId=cl.intCompanyLocationId
Left Join vyuARCustomer c on sh.intEntityCustomerId=c.[intEntityId] 
Where sh.strOrderStatus NOT IN ('Closed','Cancelled','Short Closed')