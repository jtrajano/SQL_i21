CREATE VIEW [dbo].[vyuMFGetSalesOrder]
AS 
SELECT sh.intSalesOrderId
	 , sh.strSalesOrderNumber
	 , sh.dtmDueDate
	 , c.strName AS strCustomerName
	 , cl.strLocationName
	 , sd.intSalesOrderDetailId
	 , i.intItemId
	 , i.strItemNo
	 , i.strDescription
	 , ISNULL(sd.dblQtyOrdered, 0) AS dblOrderedQty
	 , sd.intItemUOMId
	 , um.strUnitMeasure AS strUOM
FROM tblSOSalesOrder sh 
JOIN tblSOSalesOrderDetail sd ON sh.intSalesOrderId = sd.intSalesOrderId 
JOIN tblICItem i ON sd.intItemId = i.intItemId
JOIN tblICItemUOM iu ON sd.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
JOIN tblSMCompanyLocation cl ON sh.intCompanyLocationId = cl.intCompanyLocationId
LEFT JOIN vyuARCustomer c ON sh.intEntityCustomerId = c.[intEntityId] 
WHERE sh.strOrderStatus NOT IN ('Closed', 'Cancelled', 'Short Closed')