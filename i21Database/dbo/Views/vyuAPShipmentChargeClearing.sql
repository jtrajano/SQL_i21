CREATE VIEW [dbo].[vyuAPShipmentChargeClearing]  
AS   
  
--Shipment Charges  
SELECT DISTINCT  
    Shipment.dtmShipDate AS dtmDate  
    ,Shipment.intEntityCustomerId AS intEntityVendorId  
    ,Shipment.strShipmentNumber   
    ,Shipment.intInventoryShipmentId  
    ,NULL AS intBillId  
    ,NULL AS strBillId  
    ,NULL AS intBillDetailId  
    ,ShipmentCharge.intInventoryShipmentChargeId  
    ,ShipmentCharge.intChargeId  AS intItemId
    ,0 AS dblVoucherTotal  
    ,0 AS dblVoucherQty  
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal  
    ,ISNULL(ShipmentCharge.dblQuantity,0) AS dblReceiptChargeQty  
    ,Shipment.intShipFromLocationId  AS intLocationId
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
FROM dbo.tblICInventoryShipmentCharge ShipmentCharge  
INNER JOIN tblICInventoryShipment Shipment   
 ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId  
INNER JOIN tblSMCompanyLocation compLoc  
    ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
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
    ,((ShipmentCharge.dblAmount) * (CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -1 ELSE 1 END))  
         + ShipmentCharge.dblTax AS dblReceiptChargeTotal  
    ,ShipmentCharge.dblQuantity   
        * (CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty  
    ,Shipment.intShipFromLocationId  
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
FROM tblAPBill bill  
INNER JOIN tblAPBillDetail billDetail  
    ON bill.intBillId = billDetail.intBillId  
INNER JOIN tblICInventoryShipmentCharge ShipmentCharge  
    ON billDetail.intInventoryShipmentChargeId  = ShipmentCharge.intInventoryShipmentChargeId  
INNER JOIN tblICInventoryShipment Shipment  
    ON Shipment.intInventoryShipmentId  = ShipmentCharge.intInventoryShipmentId  
INNER JOIN tblSMCompanyLocation compLoc  
    ON Shipment.intShipFromLocationId = compLoc.intCompanyLocationId  
WHERE   
    billDetail.intInventoryShipmentChargeId IS NOT NULL  
AND bill.ysnPosted = 1