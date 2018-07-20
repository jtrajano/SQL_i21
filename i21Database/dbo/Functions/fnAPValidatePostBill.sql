CREATE FUNCTION [dbo].[fnAPValidatePostBill]
(
	@billIds NVARCHAR(MAX),
	@post BIT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(1000),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT,
	intErrorKey INT
)
AS
BEGIN
	
	DECLARE @tmpBills TABLE(
		[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
	);
	INSERT INTO @tmpBills SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@billIds)

	IF @post = 1
	BEGIN
		--Validate updating of payment, amountdue after apply (offset) feature.
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			A.strBillId + ' invalid amount applied.',
			'Bill',
			A.strBillId,
			A.intBillId,
			1
		FROM tblAPBill A
		WHERE 
		EXISTS(SELECT 1 FROM tblAPAppliedPrepaidAndDebit B WHERE B.intBillId IN (SELECT intBillId FROM @tmpBills) 
					AND B.intTransactionId = A.intBillId AND B.ysnApplied = 1) --Prepay and Debit Memo transactions
		AND (
			A.dblPayment > A.dblTotal
			OR A.dblAmountDue < 0
			OR A.dblAmountDue > A.dblTotal
			OR A.dblPayment < 0
		)

		--You cannot post foreign transaction that has no rate. 
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			A.strBillId + ' '  + 'is using Foreign currency. Please check transaction if has a forex rate.',
			'Bill',
			A.strBillId,
			A.intBillId,
			2
		FROM tblAPBill A 
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills)
		AND A.intCurrencyId ! = (SELECT TOP 1 intDefaultCurrencyId  FROM dbo.tblSMCompanyPreference) AND dblRate = 0

		--You cannot post recurring transaction.
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'You cannot post recurring transaction',
			'Bill',
			A.strBillId,
			A.intBillId,
			3
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills)
		AND A.ysnRecurring = 1

		--Missing vendor order number
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Unable to post. Invoice number is missing.',
			'Bill',
			A.strBillId,
			A.intBillId,
			4
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills)
		AND A.intTransactionType = 1
		AND ISNULL(A.strVendorOrderNumber,'') = ''

		----Fiscal Year
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		--SELECT 
		--	'Unable to find an open fiscal year period to match the transaction date.',
		--	'Bill',
		--	A.strBillId,
		--	A.intBillId
		--FROM tblAPBill A 
		--WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
		--	0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)

		--zero amount
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'You cannot post a bill with no details.',
			'Bill',
			A.strBillId,
			A.intBillId,
			5
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND NOT EXISTS(SELECT 1 FROM tblAPBillDetail B WHERE B.intBillId = A.intBillId)

		--No Terms specifiedvouch
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'No terms has been specified.',
			'Bill',
			A.strBillId,
			A.intBillId,
			6
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
			0 = A.intTermsId

		--NOT BALANCE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'The debit and credit amounts are not balanced.',
			'Bill',
			A.strBillId,
			A.intBillId,
			7
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			(A.dblTotal) <> (SELECT SUM(dblTotal) + SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = A.intBillId)

		--ALREADY POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'The transaction is already posted.',
			'Bill',
			A.strBillId,
			A.intBillId,
			8
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.ysnPosted = 1

		--Header Account ID
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'The AP account is not specified.',
			'Bill',
			A.strBillId,
			A.intBillId,
			9
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.intAccountId IS NULL AND A.intAccountId = 0

		--For Approved
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'You cannot post for approved transaction.',
			'Bill',
			A.strBillId,
			A.intBillId,
			10
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) 
		AND EXISTS (
			SELECT 1 FROM vyuAPForApprovalTransaction B WHERE A.intBillId = B.intTransactionId AND B.strScreenName = 'Voucher'
		)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'The account id on one of the details is not specified.',
			'Bill',
			A.strBillId,
			A.intBillId,
			11
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			1 = (SELECT 1 FROM tblAPBillDetail B 
					WHERE B.intBillId IN (SELECT [intBillId] FROM @tmpBills)
							AND (B.intAccountId IS NULL AND B.intAccountId = 0))

		--VALIDATION FOR RECEIPT
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'The item "' + C.strItemNo + '" on this transaction was already vouchered.',
			'Bill',
			A.strBillId,
			A.intBillId,
			12
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN
			(
				SELECT
					D.strReceiptNumber
					,F.strItemNo
					,E.intItemId
					,intInventoryReceiptItemId
				FROM tblICInventoryReceipt D
					INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptId = E.intInventoryReceiptId
					INNER JOIN tblICItem F ON E.intItemId = F.intItemId
				WHERE E.dblOpenReceive = E.dblBillQty
			) C ON C.intInventoryReceiptItemId = B.[intInventoryReceiptItemId] AND B.intItemId = C.intItemId
			WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
			AND A.intTransactionType = 1

		--VALIDATION FOR RECEIPT CHARGE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'The item "' + D.strItemNo + '" on this transaction was already vouchered.',
			'Bill',
			A.strBillId,
			A.intBillId,
			12
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN dbo.tblICInventoryReceiptCharge C ON B.intInventoryReceiptChargeId = C.intInventoryReceiptChargeId
			INNER JOIN dbo.tblICItem D ON D.intItemId  = B.intItemId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills) 
			AND C.dblQuantityBilled = C.dblQuantity	  
			AND A.intTransactionType = 1
			AND C.ysnPrice = 0

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'You cannot over bill the item "' + D.strItemNo + '" on this transaction.',
			'Bill',
			A.strBillId,
			A.intBillId,
			13
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN tblICInventoryReceiptItem C ON C.intInventoryReceiptItemId = B.[intInventoryReceiptItemId] AND B.intItemId = C.intItemId
			INNER JOIN tblICItem D ON C.intItemId = D.intItemId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND (C.dblBillQty + (CASE WHEN A.intTransactionType != 1 THEN B.dblQtyReceived * -1 ELSE (CASE WHEN B.dblNetWeight > 0 THEN B.dblNetWeight ELSE  B.dblQtyReceived END) END)) > C.dblOpenReceive

		--VALIDATION FOR MISCELLANEOUS ITEM
		-- INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		-- SELECT
		-- 	'The item "' + D.strItemNo + '" on this transaction was already vouchered.',
		-- 	'Bill',
		-- 	A.strBillId,
		-- 	A.intBillId,
		-- 	14
		-- FROM tblAPBill A 
		-- 	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		-- 	INNER JOIN tblPOPurchaseDetail C ON B.intPurchaseDetailId = C.intPurchaseDetailId
		-- 	INNER JOIN tblICItem D ON C.intItemId = D.intItemId
		-- WHERE C.dblQtyOrdered = C.dblQtyReceived
		-- AND D.strType IN ('Service','Software','Non-Inventory','Other Charge')
		-- AND A.intBillId IN (SELECT [intBillId] FROM @tmpBills)

		--DO NOT ALLOW TO POST IF BILL ITEMS HAVE ASSOCIATED ITEM RECEIPT AND AND ITEM RECEIPT IS NOT POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'The associated item receipt ' + C.strReceiptNumber + ' was unposted.',
			'Bill',
			A.strBillId,
			A.intBillId,
			15
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN
			(
				SELECT
					D.strReceiptNumber
					,F.strItemNo
					,intInventoryReceiptItemId
				FROM tblICInventoryReceipt D
					INNER JOIN tblICInventoryReceiptItem E ON D.intInventoryReceiptId = E.intInventoryReceiptId
					INNER JOIN tblICItem F ON E.intItemId = F.intItemId
				WHERE D.ysnPosted = 0
			) C ON C.intInventoryReceiptItemId = B.[intInventoryReceiptItemId]
			WHERE B.intInventoryReceiptItemId IS NOT NULL
			AND A.intBillId IN (SELECT [intBillId] FROM @tmpBills)

		--VALIDATE EXPENSE ACCOUNT USED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Account used for item ''' + ISNULL(ISNULL(C.strItemNo, B.strMiscDescription),'') + ''' is invalid.',
			'Bill',
			A.strBillId,
			A.intBillId,
			16
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN vyuGLAccountDetail GLD ON B.intAccountId = GLD.intAccountId
			LEFT JOIN tblICItem C ON B.intItemId = C.intItemId
			--INNER JOIN tblGLAccount D ON B.intAccountId = D.intAccountId
			--INNER JOIN tblGLAccountGroup E ON D.intAccountGroupId = E.intAccountGroupId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND GLD.intAccountCategoryId IN (1, 2, 5, 27) OR GLD.intAccountId IS NULL

		--VALIDATE EXPENSE ACCOUNT USED IF ACTIVE DETAIL
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Expense Account used to this Voucher is Inactive.',
			'Bill',
			A.strBillId,
			A.intBillId,
			17
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN vyuGLAccountDetail GLD ON B.intAccountId = GLD.intAccountId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND GLD.ysnActive = 0

		--VALIDATE EXPENSE ACCOUNT USED IF ACTIVE HEADER
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Account used to this Voucher is Inactive.',
			'Bill',
			A.strBillId,
			A.intBillId,
			18
		FROM tblAPBill A 
			INNER JOIN vyuGLAccountDetail GLD ON A.intAccountId = GLD.intAccountId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND GLD.ysnActive = 0

		--DO NOT POST NEGATIVE VOUCHER
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Posting of negative voucher is not allowed.',
			'Bill',
			A.strBillId,
			A.intBillId,
			19
		FROM tblAPBill A 
		CROSS APPLY (
			SELECT
				SUM(B.dblTotal)  + SUM(B.dblTax) AS dblTotal
			FROM tblAPBillDetail B 
			WHERE B.intBillId = A.intBillId
		) details
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND details.dblTotal < 0
		AND A.intTransactionType = 1
			
		--DO NOT ALLOW TO POST IF BILL HAS CONTRACT ITEMS AND CONTRACT PRICE ON CONTRACT RECORD DID NOT MATCHED
		--COMPARE THE CASH PRICE
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		--SELECT
		--	'The cost of item ' + D.strItemNo + ' did not match with the contract price.'
		--	,'Bill'
		--	,A.strBillId
		--	,A.intBillId
		--FROM  tblAPBill A
		--INNER JOIN tblAPBillDetail C ON A.intBillId = C.intBillId
		--INNER JOIN tblICInventoryReceiptItem E ON C.intInventoryReceiptItemId = E.intInventoryReceiptItemId
		--INNER JOIN (tblCTContractHeader B1 INNER JOIN tblCTContractDetail B2 ON B1.intContractHeaderId = B2.intContractHeaderId)
		--	ON C.intContractDetailId = B2.intContractDetailId
		--INNER JOIN tblICItem D ON C.intItemId = D.intItemId
		--WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		--AND A.ysnPosted = 0 AND C.intContractDetailId IS NOT NULL AND B1.intPricingTypeId NOT IN (7)
		--AND ISNULL(B2.dblCashPrice,0) <> ISNULL(E.dblUnitCost,0)
		
		--Zero cost in one of the details
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'The cost in one of the details is 0.',
			'Bill',
			A.strBillId,
			A.intBillId,
			26
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND EXISTS(SELECT * FROM tblAPBillDetail B WHERE B.intBillId = A.intBillId AND B.dblCost = 0.000000)

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'There was a cost adjustment made on item "' + E.strItemNo + '" on this transaction. Please setup Other Charge Expense Account for the item.',
			'Bill',
			A.strBillId,
			A.intBillId,
			27
		FROM tblAPBill A 
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN tblICInventoryReceiptItem C ON C.intInventoryReceiptItemId = B.[intInventoryReceiptItemId] AND B.intItemId = C.intItemId
			INNER JOIN tblICInventoryReceiptCharge D ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
			INNER JOIN tblICItem E ON B.intItemId = E.intItemId
			INNER JOIN tblICItemLocation ItemLoc
				ON A.intShipToId = ItemLoc.intLocationId AND B.intItemId = ItemLoc.intItemId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND B.dblOldCost IS NOT NULL AND D.ysnInventoryCost = 0
		AND [dbo].[fnGetItemGLAccount](B.intItemId, ItemLoc.intItemLocationId, 'Other Charge Expense') IS NULL

		--Do not allow to post if tblAPBill.dblTotal != tblAPBill.dblTotalController
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'Voucher Total is not equal with control total.',
			'Bill',
			A.strBillId,
			A.intBillId,
			32
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.dblTotalController != 0 AND A.dblTotal <> A.dblTotalController
	END
	ELSE
	BEGIN

		--BILL WAS POSTED FROM ORIGIN
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Voucher cannot be unpost because it is already unposted. Voucher will be refresh.',
			'Bill',
			A.strBillId,
			A.intBillId,
			33
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND A.ysnPosted = 0

		--BILL WAS POSTED FROM ORIGIN
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT 
			'Modification not allowed. Transaction is from Origin System.',
			'Bill',
			A.strBillId,
			A.intBillId,
			20
		FROM tblAPBill A 
		OUTER APPLY (
			SELECT intGLDetailId FROM tblGLDetail B
			WHERE B.strTransactionId = A.strBillId AND A.intBillId = B.intTransactionId AND B.strModuleName = 'Accounts Payable'
		) GLEntries
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND A.ysnPosted = 1
		AND GLEntries.intGLDetailId IS NULL

		--ALREADY HAVE PAYMENTS
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		SELECT
			'You cannot unpost this voucher. ' + A.strPaymentRecordNum + ' payment was already made on this voucher. You must delete the payment first.',
			'Bill',
			C.strBillId,
			C.intBillId,
			21
		FROM tblAPPayment A
			INNER JOIN tblAPPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			LEFT JOIN tblCMBankTransaction D
				ON A.strPaymentRecordNum = D.strTransactionId
		WHERE  C.[intBillId] IN (SELECT [intBillId] FROM @tmpBills)
		AND 1 = CASE WHEN D.intTransactionId IS NOT NULL
					THEN CASE WHEN D.ysnCheckVoid = 0 THEN 1 ELSE 0 END
				ELSE 1 END
		UNION ALL
		SELECT
			'You cannot unpost this voucher. ' + A.strRecordNumber + ' payment was already made on this voucher. You must delete the payment first.',
			'Bill',
			C.strBillId,
			C.intBillId,
			21
		FROM tblARPayment A
			INNER JOIN tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
		WHERE  C.[intBillId] IN (SELECT [intBillId] FROM @tmpBills)
		AND A.ysnPosted = 1

		--NO FISCAL PERIOD
		--INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId, intErrorKey)
		--SELECT 
		--	'Unable to find an open fiscal year period to match the transaction date.',
		--	'Bill',
		--	A.strBillId,
		--	A.intBillId
		--FROM tblAPBill A 
		--WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
		--	0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)
	END

	RETURN
END
