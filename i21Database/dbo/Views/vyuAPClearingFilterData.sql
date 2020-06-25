CREATE VIEW [dbo].[vyuAPClearingFilterData]
AS

--Receipt Item
SELECT DISTINCT
	receiptItems.dtmDate
	,receiptItems.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
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
	,receiptItems.dtmDate
	,receiptItems.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(receiptItems.dblReceiptQty) - SUM(receiptItems.dblVoucherQty)) != 0
OR	(SUM(receiptItems.dblReceiptTotal) - SUM(receiptItems.dblVoucherTotal)) != 0
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
	,receiptChargeItems.dtmDate
	,receiptChargeItems.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(receiptChargeItems.dblReceiptChargeQty) - SUM(receiptChargeItems.dblVoucherQty)) != 0
OR	(SUM(receiptChargeItems.dblReceiptChargeTotal) - SUM(receiptChargeItems.dblVoucherTotal)) != 0
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
	,shipmentCharges.dtmDate
	,shipmentCharges.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(shipmentCharges.dblReceiptChargeQty) - SUM(shipmentCharges.dblVoucherQty)) != 0
OR	(SUM(shipmentCharges.dblReceiptChargeTotal) - SUM(shipmentCharges.dblVoucherTotal)) != 0
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
	,loadTran.dtmDate
	,loadTran.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(loadTran.dblLoadDetailQty) - SUM(loadTran.dblVoucherQty)) != 0
OR	(SUM(loadTran.dblLoadDetailTotal) - SUM(loadTran.dblVoucherTotal)) != 0
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
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(loadCost.dblLoadCostDetailQty) - SUM(loadCost.dblVoucherQty)) != 0
OR	(SUM(loadCost.dblLoadCostDetailTotal) - SUM(loadCost.dblVoucherTotal)) != 0
UNION
SELECT  DISTINCT
	settleStorage.dtmDate
	,settleStorage.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,settleStorage.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPGrainClearing
) settleStorage
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = settleStorage.[intEntityVendorId]
INNER JOIN tblSMCompanyLocation compLoc
		ON settleStorage.intLocationId = compLoc.intCompanyLocationId
INNER JOIN tblICItem item
	ON item.intItemId = settleStorage.intItemId
GROUP BY
	settleStorage.intEntityVendorId
	,item.strItemNo
	,settleStorage.intLocationId
	,settleStorage.strTransactionNumber
	,settleStorage.dtmDate
	,settleStorage.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(settleStorage.dblSettleStorageQty) - SUM(settleStorage.dblVoucherQty)) != 0
OR	(SUM(settleStorage.dblSettleStorageAmount) - SUM(settleStorage.dblVoucherTotal)) != 0
UNION
SELECT  DISTINCT
	patClearing.dtmDate
	,patClearing.strTransactionNumber
	,item.strItemNo
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,patClearing.strAccountId
	,compLoc.strLocationName
FROM
(
	SELECT
		*
	FROM vyuAPPatClearing
) patClearing
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON B.[intEntityId] = patClearing.[intEntityVendorId]
LEFT JOIN tblSMCompanyLocation compLoc
		ON patClearing.intLocationId = compLoc.intCompanyLocationId
LEFT JOIN tblICItem item
	ON item.intItemId = patClearing.intItemId
GROUP BY
	patClearing.intEntityVendorId
	,item.strItemNo
	,patClearing.intLocationId
	,patClearing.strTransactionNumber
	,patClearing.dtmDate
	,patClearing.strAccountId
	,B.strVendorId
	,C.strEntityNo
	,C.strName
	,compLoc.strLocationName
HAVING 
	(SUM(patClearing.dblRefundQty) - SUM(patClearing.dblVoucherQty)) != 0
OR	(SUM(patClearing.dblRefundTotal) - SUM(patClearing.dblVoucherTotal)) != 0
