IF NOT EXISTS(SELECT 1 FROM tblAPClearing)
BEGIN
    INSERT INTO dbo.tblAPClearing (
		intTransactionId,
		strTransactionId,
        intTransactionType,
        strReferenceNumber,
		dtmDate,
		intEntityVendorId,
		intLocationId,
		intTransactionDetailId,
		intAccountId,
		intItemId,
		intItemUOMId,
		dblQuantity,
		dblAmount,
		intBillId,
		strBillId,
		intBillDetailId,
		intBillDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)

    --RECEIPT
    SELECT
        intInventoryReceiptId,
        strTransactionNumber,
        1,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intInventoryReceiptItemId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptQty ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptTotal ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPReceiptClearing
    WHERE intInventoryReceiptId         IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intInventoryReceiptItemId     IS NOT NULL AND 
          intAccountId                  IS NOT NULL
    
    --RECEIPT CHARGE
    UNION ALL
    SELECT
        intInventoryReceiptId,
        strTransactionNumber,
        2,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intInventoryReceiptChargeId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptChargeQty ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptChargeTotal ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPReceiptChargeClearing
    WHERE intInventoryReceiptId         IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intInventoryReceiptChargeId   IS NOT NULL AND 
          intAccountId                  IS NOT NULL
    

    --SHIPMENT CHARGE
    UNION ALL
    SELECT
        intInventoryShipmentId,
        strTransactionNumber,
        3,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intInventoryShipmentChargeId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptChargeQty ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblReceiptChargeTotal ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPShipmentChargeClearing
    WHERE intInventoryShipmentId        IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intInventoryShipmentChargeId  IS NOT NULL AND 
          intAccountId                  IS NOT NULL

    --LOAD
    UNION ALL
    SELECT
        intLoadId,
        strTransactionNumber,
        4,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intLoadDetailId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblLoadDetailTotal ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblLoadDetailQty ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPLoadClearing
    WHERE intLoadId                     IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intLoadDetailId               IS NOT NULL AND 
          intAccountId                  IS NOT NULL

    --LOAD COST
    UNION ALL
    SELECT
        intLoadId,
        strTransactionNumber,
        5,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intLoadCostId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblLoadCostDetailTotal ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblLoadCostDetailQty ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPLoadCostClearing
    WHERE intLoadId                     IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intLoadCostId                 IS NOT NULL AND 
          intAccountId                  IS NOT NULL
    
    --GRAIN
    UNION ALL
    SELECT
        intSettleStorageId,
        strTransactionNumber,
        6,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intCustomerStorageId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblSettleStorageQty ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblSettleStorageAmount ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPGrainClearing
    WHERE intSettleStorageId            IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intCustomerStorageId          IS NOT NULL AND 
          intAccountId                  IS NOT NULL
    
    --TRANSFER
    UNION ALL
    SELECT
        intInventoryReceiptId,
        strTransactionNumber,
        7,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intInventoryReceiptItemId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN dblReceiptTotal ELSE dblTransferTotal * -1 END,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN dblReceiptQty ELSE dblTransferQty * -1 END,
        intTransferStorageId,
        strTransferStorageTicket,
        intTransferStorageReferenceId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuGRTransferClearing
    WHERE intInventoryReceiptId         IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intInventoryReceiptItemId     IS NOT NULL AND 
          intAccountId                  IS NOT NULL
    
    --TRANSFER CHARGE
    UNION ALL
    SELECT
        intInventoryReceiptId,
        strTransactionNumber,
        8,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intInventoryReceiptChargeId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN dblReceiptChargeTotal ELSE dblTransferTotal * -1 END,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN dblReceiptChargeQty ELSE dblTransferQty * -1 END,
        intTransferStorageId,
        strTransferStorageTicket,
        intTransferStorageReferenceId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuGRTransferChargesClearing
    WHERE intInventoryReceiptId         IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intInventoryReceiptChargeId   IS NOT NULL AND 
          intAccountId                  IS NOT NULL

    --PAT
    UNION ALL
    SELECT
        intRefundId,
        strTransactionNumber,
        9,
        '',
        dtmDate,
        intEntityVendorId,
        intLocationId,
        intRefundCustomerId,
        intAccountId,
        intItemId,
        intItemUOMId,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblRefundQty ELSE dblVoucherQty * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN dblRefundTotal ELSE dblVoucherTotal * -1 END,
        intBillId,
        strBillId,
        intBillDetailId,
        NULL,
        'APC',
        1,
        GETDATE()
    FROM vyuAPPatClearing
    WHERE intRefundId                   IS NOT NULL AND 
          strTransactionNumber          IS NOT NULL AND 
          dtmDate                       IS NOT NULL AND 
          intEntityVendorId             IS NOT NULL AND 
          intLocationId                 IS NOT NULL AND 
          intRefundCustomerId           IS NOT NULL AND 
          intAccountId                  IS NOT NULL
END