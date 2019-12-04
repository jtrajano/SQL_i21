/**
	@tranType
	IC = Inventory
	GR = Grain
*/
CREATE PROCEDURE [dbo].[uspAPDiagnoseClearingData]
	@tranType CHAR(2) = NULL,
	@account INT = NULL,
	@dateStart DATETIME = NULL,
	@dateEnd DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @start DATETIME = CASE WHEN @dateStart IS NOT NULL THEN @dateStart ELSE '1/1/1900' END
DECLARE @end DATETIME = CASE WHEN @dateEnd IS NOT NULL THEN @dateEnd ELSE GETDATE() END

IF @tranType = 'IC'
BEGIN
	--Result of this should be all 0
	SELECT
		'' AS [Receipt/Voucher Total Clearing on GL],
		SUM(dblTotal),
		intAccountId,
		strReceiptNumber
	FROM 
	(
	--BILLS
	SELECT
		dblCredit - dblDebit AS dblTotal,
		A.intAccountId,
		receiptDetails.strReceiptNumber
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblAPBill C 
		ON A.strTransactionId = C.strBillId 
	OUTER APPLY (
		SELECT TOP 1
			D.strReceiptNumber
		FROM tblAPBillDetail C2
		INNER JOIN (tblICInventoryReceipt D INNER JOIN tblICInventoryReceiptItem D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
			ON C2.intInventoryReceiptItemId = D2.intInventoryReceiptItemId
		WHERE C2.intInventoryReceiptItemId > 0 AND C2.intBillId = C.intBillId
	) receiptDetails
	WHERE 
		ysnIsUnposted = 0
	AND 1 = CASE WHEN @account > 0 THEN 
				CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
			ELSE 1
			END
	AND B.intAccountCategoryId = 45
	AND A.intJournalLineNo != 1
	AND receiptDetails.strReceiptNumber IS NOT NULL
	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
	--AND A.strTransactionId IN ('BL-216317','BL-216418')
	UNION ALL
	--RECEIPTS
	SELECT
		dblCredit - dblDebit AS dblTotal,
		A.intAccountId,
		D.strReceiptNumber
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblICInventoryReceipt D ON A.strTransactionId = D.strReceiptNumber
	WHERE 
		ysnIsUnposted = 0
	AND 1 = CASE WHEN @account > 0 THEN 
				CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
			ELSE 1
			END
	AND B.intAccountCategoryId = 45
	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
	--AND A.strTransactionId IN ('IR-102')
	) glDetails
	GROUP BY
		intAccountId,
		strReceiptNumber
	ORDER BY strReceiptNumber

	;WITH receiptTotal (
		dtmReceiptDate,
		dblTotal,
		strReceiptNumber
	)
	AS (
		SELECT
		A.dtmReceiptDate,
		SUM(B.dblLineTotal + B.dblTax) * (CASE WHEN A.strReceiptType = 'Inventory Return' THEN -1 ELSE 1 END) AS dblTotal,
		A.strReceiptNumber
		FROM tblICInventoryReceipt A
		INNER JOIN tblICInventoryReceiptItem B
		ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE DATEADD(dd, DATEDIFF(dd, 0,A.dtmReceiptDate), 0) BETWEEN @start AND @end
		GROUP BY A.dtmReceiptDate, A.strReceiptNumber, A.strReceiptType
	),
	receiptGLTotal (
		dtmDate,
		dblTotal,
		strReceiptNumber
	)
	AS (
		SELECT
			A.dtmDate,
			SUM(dblCredit - dblDebit),
			A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B
		ON A.intAccountId = B.intAccountId
		WHERE B.intAccountCategoryId = 45
		AND A.ysnIsUnposted = 0
		AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
		AND A.strDescription NOT LIKE '%Charges from%'
		GROUP BY A.strTransactionId, A.dtmDate
	)

	SELECT
		'' [Receipt Total Clearing vs GL Total Clearing],
		A.strReceiptNumber,
		A.dtmReceiptDate,
		A.dblTotal,
		B.dblTotal AS dblGLTotal
	FROM receiptTotal A
	INNER JOIN receiptGLTotal B ON A.strReceiptNumber = B.strReceiptNumber
	WHERE A.dblTotal != B.dblTotal

	;WITH billTotal (
		dtmBillDate,
		dblTotal,
		strBillId
	)
	AS (
		SELECT
		A.dtmBillDate,
		SUM(B.dblTotal + B.dblTax) * (CASE WHEN A.intTransactionType != 1 THEN -1 ELSE 1 END) AS dblTotal,
		A.strBillId
		FROM tblAPBill A
		INNER JOIN tblAPBillDetail B
		ON A.intBillId = B.intBillId AND B.intInventoryReceiptItemId > 0
		WHERE DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
		GROUP BY A.dtmBillDate, A.strBillId, A.intTransactionType
	),
	billGLTotal (
		dtmDate,
		dblTotal,
		strBillId
	)
	AS (
		SELECT
			A.dtmDate,
			SUM(dblDebit - dblCredit),
			A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B
		ON A.intAccountId = B.intAccountId
		WHERE B.intAccountCategoryId = 45
		AND A.ysnIsUnposted = 0
		AND A.strCode != 'ICA'
		AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
		GROUP BY A.strTransactionId, A.dtmDate
	)

	SELECT
		'' [Voucher Total Clearing vs GL Total Clearing],
		A.strBillId,
		A.dtmBillDate,
		A.dblTotal,
		B.dblTotal AS dblGLTotal
	FROM billTotal A
	INNER JOIN billGLTotal B ON A.strBillId = B.strBillId
	WHERE A.dblTotal != B.dblTotal
END
ELSE IF @tranType = 'GR'
BEGIN
	--Result of this should be all 0
	SELECT
		'' AS [Grain/Voucher Total Clearing on GL],
		SUM(dblTotal),
		intAccountId,
		strStorageTicket
	FROM 
	(
	--BILLS
	SELECT
		dblCredit - dblDebit AS dblTotal,
		A.intAccountId,
		grainDetails.strStorageTicket
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN tblAPBill C 
		ON A.strTransactionId = C.strBillId 
	OUTER APPLY (
		SELECT TOP 1
			SS.strStorageTicket
		FROM tblAPBillDetail C2
		INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
						ON SST.intCustomerStorageId = CS.intCustomerStorageId
					INNER JOIN tblGRSettleStorage SS
						ON SST.intSettleStorageId = SS.intSettleStorageId AND SS.intParentSettleStorageId IS NOT NULL)
			ON CS.intCustomerStorageId = C2.intCustomerStorageId
		WHERE C2.intCustomerStorageId > 0 AND C2.intBillId = C.intBillId
	) grainDetails
	WHERE 
		ysnIsUnposted = 0
	AND 1 = CASE WHEN @account > 0 THEN 
				CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
			ELSE 1
			END
	AND B.intAccountCategoryId = 45
	AND A.intJournalLineNo != 1
	AND grainDetails.strStorageTicket IS NOT NULL
	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
	--AND A.strTransactionId IN ('BL-216317','BL-216418')
	UNION ALL
	--GRAINS
	SELECT
		dblCredit - dblDebit AS dblTotal,
		A.intAccountId,
		SS.strStorageTicket
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	INNER JOIN (tblGRCustomerStorage CS 
	INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId AND SS.intParentSettleStorageId IS NOT NULL)
		ON A.strTransactionId = SS.strStorageTicket
	WHERE 
		ysnIsUnposted = 0
	AND 1 = CASE WHEN @account > 0 THEN 
				CASE WHEN A.intAccountId = @account THEN 1 ELSE 0 END
			ELSE 1
			END
	AND B.intAccountCategoryId = 45
	AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
	--AND A.strTransactionId IN ('IR-102')
	) glDetails
	GROUP BY
		intAccountId,
		strStorageTicket
	ORDER BY strStorageTicket

	;WITH grainItemTotal (
		dtmGrainDate,
		dblTotal,
		strStorageTicket
	)
	AS (
		SELECT 
			SS.dtmCreated AS dtmDate
			,CASE WHEN SS.dblUnpaidUnits != 0 
				THEN (
					CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
					ELSE SS.dblNetSettlement
					END
				)
				ELSE CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2))
				END AS dblSettleStorageAmount
			,SS.strStorageTicket
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId
				AND SS.intParentSettleStorageId IS NOT NULL
		LEFT JOIN tblGRSettleContract ST
			ON ST.intSettleStorageId = SS.intSettleStorageId
		WHERE DATEADD(dd, DATEDIFF(dd, 0,SS.dtmCreated), 0) BETWEEN @start AND @end
	),
	grainChargeTotal (
		dtmGrainDate,
		dblTotal,
		strStorageTicket
	)
	AS (
		SELECT 
			SS.dtmCreated AS dtmDate
			,CASE WHEN SS.dblUnpaidUnits != 0 
				THEN (
					CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
					ELSE SS.dblNetSettlement
					END
				)
				ELSE CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2))
				END AS dblSettleStorageAmount
			,SS.strStorageTicket
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId
				AND SS.intParentSettleStorageId IS NOT NULL
		LEFT JOIN tblGRSettleContract ST
			ON ST.intSettleStorageId = SS.intSettleStorageId
		WHERE DATEADD(dd, DATEDIFF(dd, 0,SS.dtmCreated), 0) BETWEEN @start AND @end
	),
	grainDiscountTotal (
		dtmGrainDate,
		dblTotal,
		strStorageTicket
	)
	AS (
		SELECT 
			SS.dtmCreated
			,CAST(CASE
				WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 
				THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1)
				WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END)) *  -1
				WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount)
				WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * -1)
			END * (CASE WHEN QM.strCalcMethod = 3 THEN CS.dblGrossQuantity ELSE SST.dblUnits END) AS DECIMAL(18,2))
			,SS.strStorageTicket
		FROM tblQMTicketDiscount QM
		INNER JOIN tblGRDiscountScheduleCode DSC
			ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = QM.intTicketFileId
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId
				AND SS.intParentSettleStorageId IS NOT NULL
				AND SS.ysnPosted = 1
		LEFT JOIN tblGRSettleContract SC
			ON SC.intSettleStorageId = SS.intSettleStorageId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SC.intContractDetailId
		WHERE 
			QM.strSourceType = 'Storage' 
		AND QM.dblDiscountDue <> 0
	),
	grainGLTotal (
		dtmGrainDate,
		dblTotal,
		strStorageTicket
	)
	AS (
		SELECT
			A.dtmDate,
			SUM(dblCredit - dblDebit),
			A.strTransactionId
		FROM tblGLDetail A
		INNER JOIN vyuGLAccountDetail B
		ON A.intAccountId = B.intAccountId
		WHERE B.intAccountCategoryId = 45
		AND A.ysnIsUnposted = 0
		AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
		-- AND A.strDescription NOT LIKE '%Charges from%'
		GROUP BY A.strTransactionId, A.dtmDate
	)

	SELECT
		'' [Grain Total Clearing vs GL Total Clearing],
		A.strStorageTicket,
		A.dtmGrainDate,
		grainTotal.dblTotal,
		A.dblTotal AS dblGLTotal
	FROM grainGLTotal A 
	INNER JOIN 
	(
		SELECT
			SUM(dblTotal) dblTotal,
			strStorageTicket
		FROM
		(
			SELECT
				B.dtmGrainDate,
				B.dblTotal,
				B.strStorageTicket
			FROM grainItemTotal B
			UNION ALL
			SELECT
				C.dtmGrainDate,
				C.dblTotal,
				C.strStorageTicket
			FROM grainChargeTotal C
			UNION ALL
			SELECT
				D.dtmGrainDate,
				D.dblTotal,
				D.strStorageTicket
			FROM grainDiscountTotal D
		) gr
		GROUP BY strStorageTicket
	) grainTotal
	ON A.strStorageTicket = grainTotal.strStorageTicket
	WHERE A.dblTotal != grainTotal.dblTotal
END