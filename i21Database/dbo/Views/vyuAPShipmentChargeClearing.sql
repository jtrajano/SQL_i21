CREATE VIEW [dbo].[vyuAPShipmentChargeClearing]  
AS   
  
--Shipment Charges  
SELECT DISTINCT  
    Shipment.dtmShipDate AS dtmDate  
    ,ISNULL(ShipmentCharge.intEntityVendorId, Shipment.intEntityCustomerId) AS intEntityVendorId  
    ,Shipment.strShipmentNumber   AS strTransactionNumber
    ,Shipment.intInventoryShipmentId  
    ,NULL AS intBillId  
    ,NULL AS strBillId  
    ,NULL AS intBillDetailId  
    ,ShipmentCharge.intInventoryShipmentChargeId  
    ,ShipmentCharge.intChargeId  AS intItemId
    ,ShipmentCharge.intCostUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
    ,0 AS dblVoucherTotal  
    ,0 AS dblVoucherQty  
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal  
    ,ISNULL(ShipmentCharge.dblQuantity,0) AS dblReceiptChargeQty  
    ,Shipment.intShipFromLocationId  AS intLocationId
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM dbo.tblICInventoryShipmentCharge ShipmentCharge  
INNER JOIN tblICInventoryShipment Shipment   
 ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId  
INNER JOIN tblSMCompanyLocation compLoc  
    ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = ShipmentCharge.intCostUOMId
OUTER APPLY (
	SELECT TOP 1
		ga.strAccountId
		,ga.intAccountId
	FROM 
		tblGLDetail gd INNER JOIN tblGLAccount ga
			ON ga.intAccountId = gd.intAccountId
		INNER JOIN tblGLAccountGroup ag
			ON ag.intAccountGroupId = ga.intAccountGroupId
	WHERE
		gd.strTransactionId = Shipment.strShipmentNumber
		AND ag.strAccountType = 'Liability'
		AND gd.ysnIsUnposted = 0 
) APClearing
WHERE Shipment.ysnPosted = 1 AND ShipmentCharge.ysnAccrue = 1  
UNION ALL  
SELECT  
    bill.dtmDate AS dtmDate  
    ,bill.intEntityVendorId  
    ,Shipment.strShipmentNumber  
    ,Shipment.intInventoryShipmentId  
    ,bill.intBillId  
    ,bill.strBillId  
    ,billDetail.intBillDetailId  
    ,billDetail.intInventoryShipmentChargeId  
    ,billDetail.intItemId  
    ,billDetail.intUnitOfMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal  
    ,CASE   
        WHEN billDetail.intWeightUOMId IS NULL THEN   
            ISNULL(billDetail.dblQtyReceived, 0)   
        ELSE   
            CASE   
                WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN   
                    ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)  
                ELSE   
                    ISNULL(billDetail.dblNetWeight, 0)   
            END  
    END AS dblVoucherQty  
    ,0 AS dblReceiptChargeTotal
    ,0 AS dblReceiptChargeQty
    -- ,((ShipmentCharge.dblAmount) * (CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -1 ELSE 1 END))  
    --      + ShipmentCharge.dblTax AS dblReceiptChargeTotal  
    -- ,ShipmentCharge.dblQuantity   
    --     * (CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty  
    ,Shipment.intShipFromLocationId  
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblAPBill bill  
INNER JOIN tblAPBillDetail billDetail  
    ON bill.intBillId = billDetail.intBillId  
INNER JOIN tblICInventoryShipmentCharge ShipmentCharge  
    ON billDetail.intInventoryShipmentChargeId  = ShipmentCharge.intInventoryShipmentChargeId  
INNER JOIN tblICInventoryShipment Shipment  
    ON Shipment.intInventoryShipmentId  = ShipmentCharge.intInventoryShipmentId  
INNER JOIN tblSMCompanyLocation compLoc  
    ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId
OUTER APPLY (
	SELECT TOP 1
		ga.strAccountId
		,ga.intAccountId
	FROM 
		tblGLDetail gd INNER JOIN tblGLAccount ga
			ON ga.intAccountId = gd.intAccountId
		INNER JOIN tblGLAccountGroup ag
			ON ag.intAccountGroupId = ga.intAccountGroupId
	WHERE
		gd.strTransactionId = Shipment.strShipmentNumber
		AND ag.strAccountType = 'Liability'
		AND gd.ysnIsUnposted = 0 
) APClearing
WHERE   
    billDetail.intInventoryShipmentChargeId IS NOT NULL  
AND bill.ysnPosted = 1