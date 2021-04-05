﻿CREATE FUNCTION [dbo].[fnAPClearing]
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
	[intReferenceId]			INT NULL,
	[strRemarks]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
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
		ISNULL(BD.dblQtyReceived, 0) * -1,
		ISNULL(ISNULL(BD.dblOldCost, BD.dblCost) * BD.dblQtyReceived, 0) * -1,
		B.intBillId,
		B.strBillId,
		BD.intBillDetailId,
		NULL,
		'AP',
		NULL,
		NULL
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = BD.intAccountId
	OUTER APPLY (
		SELECT TOP 1 *
		FROM fnAPGetDetailSourceTransaction (
				BD.intInventoryReceiptItemId,
				BD.intInventoryReceiptChargeId,
				BD.intInventoryShipmentChargeId,
				BD.intLoadDetailId,
				BD.intCustomerStorageId,
				BD.intSettleStorageId,
				BD.intBillId,
				BD.intItemId
			)
		ORDER BY intSourceTransactionTypeId DESC
	) ST
	WHERE B.intBillId IN (SELECT intId FROM @ids) AND
	AD.intAccountCategoryId = 45 AND
	ST.intSourceTransactionId > 0

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
		ISNULL(DT.dblTax, 0) * -1,
		B.intBillId,
		B.strBillId,
		BD.intBillDetailId,
		DT.intBillDetailTaxId,
		'AP',
		NULL,
		NULL
	FROM tblAPBill B
	INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
	INNER JOIN tblAPBillDetailTax DT ON DT.intBillDetailId = BD.intBillDetailId
	INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = BD.intAccountId
	OUTER APPLY (
		SELECT TOP 1 *
		FROM fnAPGetDetailSourceTransaction (
				BD.intInventoryReceiptItemId,
				BD.intInventoryReceiptChargeId,
				BD.intInventoryShipmentChargeId,
				BD.intLoadDetailId,
				BD.intCustomerStorageId,
				BD.intSettleStorageId,
				BD.intBillId,
				BD.intItemId
			)
		ORDER BY intSourceTransactionTypeId DESC
	) ST
	WHERE B.intBillId IN (SELECT intId FROM @ids) AND
	AD.intAccountCategoryId = 45 AND
	ST.intSourceTransactionId > 0

	RETURN
END
