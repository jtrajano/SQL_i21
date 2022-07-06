CREATE FUNCTION [dbo].[fnAPClearing]
(
	@ids Id READONLY
)
RETURNS @returntable TABLE
(
	[intTransactionId]			INT NOT NULL,
	[strTransactionId]			NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionType]		INT NOT NULL,
	[strReferenceNumber]		NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]					DATETIME NOT NULL,
	[intEntityVendorId]			INT NOT NULL,
	[intLocationId]				INT NOT NULL,
	[intTransactionDetailId]	INT NOT NULL,
	[intAccountId]				INT NOT NULL,
	[intItemId]					INT NULL,
	[intItemUOMId]				INT NULL,
	[dblQuantity]				NUMERIC(18, 6) DEFAULT 0 NOT NULL,
	[dblAmount]					NUMERIC(18, 6) DEFAULT 0 NOT NULL,
	[intOffsetId]				INT NULL,
	[strOffsetId]				NVARCHAR(55) COLLATE Latin1_General_CI_AS NULL,
	[intOffsetDetailId]			INT NULL,
	[intOffsetDetailTaxId]		INT NULL,
	[strCode]					NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN
	INSERT @returntable
	--VOUCHER DETAIL
	SELECT
		ST.intSourceTransactionId,
		ST.strSourceTransaction,
		ST.intSourceTransactionTypeId,
		'',
		B.dtmDate,
		B.intEntityVendorId,
		B.intShipToId,
		ST.intSourceTransactionDetailId,
		BD.intAccountId,
		BD.intItemId,
		BD.intUnitOfMeasureId,
		CASE WHEN B.intTransactionType IN (2, 3, 8, 13) THEN ISNULL(ISNULL(ST.dblSourceTransactionQuantity, BD.dblQtyReceived), 0) ELSE ISNULL(ISNULL(ST.dblSourceTransactionQuantity, BD.dblQtyReceived), 0) * -1 END,
		CASE WHEN B.intTransactionType IN (2, 3, 8, 13) THEN ISNULL(ISNULL(BD.dblOldCost, BD.dblCost) * ISNULL(ST.dblSourceTransactionQuantity, BD.dblQtyReceived), 0) ELSE ISNULL(ISNULL(BD.dblOldCost, BD.dblCost) * ISNULL(ST.dblSourceTransactionQuantity, BD.dblQtyReceived), 0) * -1 END,
		B.intBillId,
		B.strBillId,
		BD.intBillDetailId,
		NULL,
		'AP',
		NULL
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = BD.intAccountId
	OUTER APPLY fnAPGetDetailSourceTransaction(BD.intInventoryReceiptItemId, BD.intInventoryReceiptChargeId, BD.intInventoryShipmentChargeId, BD.intLoadDetailId, BD.intLoadShipmentCostId, BD.intCustomerStorageId, BD.intSettleStorageId, BD.intBillId, BD.intItemId) ST
	WHERE B.intBillId IN (SELECT intId FROM @ids) AND AD.intAccountCategoryId = 45
	AND ST.intSourceTransactionId IS NOT NULL --ONLY BILLS WITH SOURCE TRANSACTION

	INSERT @returntable
	--DETAIL TAX
	SELECT
		ST.intSourceTransactionId,
		ST.strSourceTransaction,
		ST.intSourceTransactionTypeId,
		'',
		B.dtmDate,
		B.intEntityVendorId,
		B.intShipToId,
		ST.intSourceTransactionDetailId,
		BD.intAccountId,
		BD.intItemId,
		BD.intUnitOfMeasureId,
		0,
		CASE WHEN B.intTransactionType IN (2, 3, 8, 13) THEN ISNULL(DT.dblTax, 0) ELSE ISNULL(DT.dblTax, 0) * -1 END,
		B.intBillId,
		B.strBillId,
		BD.intBillDetailId,
		DT.intBillDetailTaxId,
		'AP',
		NULL
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN tblAPBillDetailTax DT ON DT.intBillDetailId = BD.intBillDetailId
	INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = BD.intAccountId
	OUTER APPLY fnAPGetDetailSourceTransaction(BD.intInventoryReceiptItemId, BD.intInventoryReceiptChargeId, BD.intInventoryShipmentChargeId, BD.intLoadDetailId, BD.intLoadShipmentCostId, BD.intCustomerStorageId, BD.intSettleStorageId, BD.intBillId, BD.intItemId) ST
	WHERE B.intBillId IN (SELECT intId FROM @ids) AND AD.intAccountCategoryId = 45 
	AND ST.intSourceTransactionTypeId IN (1, 2, 3) AND ST.dblSourceTransactionTax <> 0 AND DT.dblTax <> 0 --ONLY RECEIPT AND SHIPMENT TAXES AND DON'T INCLUDE 0 
	AND ST.intSourceTransactionId IS NOT NULL --ONLY BILLS WITH SOURCE TRANSACTION

	RETURN
END
