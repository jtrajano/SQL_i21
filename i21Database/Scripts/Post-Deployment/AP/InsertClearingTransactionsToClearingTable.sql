PRINT N'START: INITIALIZING tblAPClearing'
IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPClearing)
BEGIN
    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPReceiptClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptTotal, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPReceiptClearing...'

    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPReceiptChargeClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptChargeQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptChargeTotal, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPReceiptChargeClearing...'

    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPShipmentChargeClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptChargeQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblReceiptChargeTotal, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPShipmentChargeClearing...'

    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPLoadClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblLoadDetailQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblLoadDetailTotal, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPLoadClearing...'

    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPLoadCostClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblLoadCostDetailQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblLoadCostDetailTotal, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPLoadCostClearing...'
    
    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPGrainClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblSettleStorageQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblSettleStorageAmount, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPGrainClearing...'
    
    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuGRTransferClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN ISNULL(dblReceiptQty, 0) ELSE ISNULL(dblTransferQty, 0) * -1 END,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN ISNULL(dblReceiptTotal, 0) ELSE ISNULL(dblTransferTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuGRTransferClearing...'
    
    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuGRTransferChargesClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN ISNULL(dblReceiptChargeQty, 0) ELSE ISNULL(dblTransferQty, 0) * -1 END,
        CASE WHEN intTransferStorageId IS NULL OR intTransferStorageId < 0 THEN ISNULL(dblReceiptChargeTotal, 0) ELSE ISNULL(dblTransferTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuGRTransferChargesClearing...'

    PRINT N'START: INSERTING RECORDS TO tblAPClearing FROM vyuAPPatClearing...'
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
		intOffsetId,
		strOffsetId,
		intOffsetDetailId,
		intOffsetDetailTaxId,
		strCode,
		ysnPostAction,
		dtmDateEntered
	)
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
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblRefundQty, 0) ELSE ISNULL(dblVoucherQty, 0) * -1 END,
        CASE WHEN intBillId IS NULL OR intBillId < 0 THEN ISNULL(dblRefundTotal, 0) ELSE ISNULL(dblVoucherTotal, 0) * -1 END,
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
    PRINT N'SUCCESS: INSERTING RECORDS TO tblAPClearing FROM vyuAPPatClearing...'
END
PRINT N'SUCCESS: INITIALIZING tblAPClearing'