CREATE VIEW [dbo].[vyuAPClearingFilterData]
AS

--Receipt Item
SELECT DISTINCT
	receiptItems.dtmDate
	,receiptItems.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,receiptItems.strAccountId
	,compLoc.strLocationName
FROM 
(
	SELECT
		*
	FROM vyuAPReceiptClearing
) receiptItems
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = receiptItems.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON receiptItems.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = receiptItems.intItemId
GROUP BY
	receiptItems.intEntityVendorId
	,item.strItemNo
	,receiptItems.intLocationId
	,receiptItems.strTransactionNumber
	,receiptItems.dblReceiptQty
	,receiptItems.dtmDate
	,receiptItems.strAccountId
	,receiptItems.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (receiptItems.dblReceiptQty - SUM(receiptItems.dblVoucherQty)) != 0
UNION --RECEIPT CHARGES, USE 'UNION' TO REMOVE DUPLICATES ON REPORT FILTER
SELECT  DISTINCT
	receiptChargeItems.dtmDate
	,receiptChargeItems.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,receiptChargeItems.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPReceiptChargeClearing
) receiptChargeItems
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = receiptChargeItems.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON receiptChargeItems.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = receiptChargeItems.intItemId
GROUP BY
	receiptChargeItems.intEntityVendorId
	,item.strItemNo
	,receiptChargeItems.intLocationId
	,receiptChargeItems.strTransactionNumber
	,receiptChargeItems.dblReceiptChargeQty
	,receiptChargeItems.dtmDate
	,receiptChargeItems.strAccountId
	,receiptChargeItems.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (receiptChargeItems.dblReceiptChargeQty - SUM(receiptChargeItems.dblVoucherQty)) != 0
UNION --SHIPMENT CHARGE
SELECT  DISTINCT
	shipmentCharges.dtmDate
	,shipmentCharges.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,shipmentCharges.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPShipmentChargeClearing
) shipmentCharges
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = shipmentCharges.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON shipmentCharges.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = shipmentCharges.intItemId
GROUP BY
	shipmentCharges.intEntityVendorId
	,item.strItemNo
	,shipmentCharges.intLocationId
	,shipmentCharges.strTransactionNumber
	,shipmentCharges.dblReceiptChargeQty
	,shipmentCharges.dtmDate
	,shipmentCharges.strAccountId
	,shipmentCharges.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (shipmentCharges.dblReceiptChargeQty - SUM(shipmentCharges.dblVoucherQty)) != 0
UNION --LOAD TRANSACTION
SELECT  DISTINCT
	loadTran.dtmDate
	,loadTran.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,loadTran.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPLoadClearing
) loadTran
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = loadTran.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON loadTran.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = loadTran.intItemId
GROUP BY
	loadTran.intEntityVendorId
	,item.strItemNo
	,loadTran.intLocationId
	,loadTran.strTransactionNumber
	,loadTran.dblLoadDetailQty
	,loadTran.dtmDate
	,loadTran.strAccountId
	,loadTran.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (loadTran.dblLoadDetailQty - SUM(loadTran.dblVoucherQty)) != 0
UNION
SELECT  DISTINCT
	loadCost.dtmDate
	,loadCost.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,loadCost.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPLoadCostClearing
) loadCost
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = loadCost.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON loadCost.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = loadCost.intItemId
GROUP BY
	loadCost.intEntityVendorId
	,item.strItemNo
	,loadCost.intLocationId
	,loadCost.strTransactionNumber
	,loadCost.dblLoadCostDetailQty
	,loadCost.dtmDate
	,loadCost.strAccountId
	,loadCost.strTransactionNumber
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING (loadCost.dblLoadCostDetailQty - SUM(loadCost.dblVoucherQty)) != 0