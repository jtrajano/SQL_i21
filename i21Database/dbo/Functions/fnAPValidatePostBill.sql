CREATE FUNCTION [dbo].[fnAPValidatePostBill]
(
	@billIds NVARCHAR(MAX),
	@post BIT
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(200),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	intTransactionId INT
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
		--Fiscal Year
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)

		--zero amount
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'You cannot post a bill with zero amount.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) 
		AND A.dblTotal = 0

		--No Terms specified
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'No terms has been specified.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
			0 = A.intTermsId

		--NOT BALANCE
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The debit and credit amounts are not balanced.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			(A.dblTotal) <> (SELECT SUM(dblTotal) + SUM(dblTax) FROM tblAPBillDetail WHERE intBillId = A.intBillId)

		--ALREADY POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'The transaction is already posted.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.ysnPosted = 1

		--Header Account ID
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'The AP account is not specified.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.intAccountId IS NULL AND A.intAccountId = 0

		--For Approved
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'You cannot post for approved transaction.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			A.ysnForApproval = 1

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'The account id on one of the details is not specified.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.intBillId IN (SELECT [intBillId] FROM @tmpBills) AND 
			1 = (SELECT 1 FROM tblAPBillDetail B 
					WHERE B.intBillId IN (SELECT [intBillId] FROM @tmpBills)
							AND (B.intAccountId IS NULL AND B.intAccountId = 0))

		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'The item "' + C.strItemNo + '" on this transaction was already billed.',
			'Bill',
			A.strBillId,
			A.intBillId
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
				WHERE E.dblOpenReceive = E.dblBillQty
			) C ON C.intInventoryReceiptItemId = B.[intInventoryReceiptItemId]
			WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)

		--DO NOT ALLOW TO POST IF BILL ITEMS HAVE ASSOCIATED ITEM RECEIPT AND AND ITEM RECEIPT IS NOT POSTED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'The associated item receipt ' + C.strReceiptNumber + ' was unposted.',
			'Bill',
			A.strBillId,
			A.intBillId
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

		--DO NOT ALLOW TO POST IF BILL HAS CONTRACT ITEMS AND CONTRACT PRICE ON CONTRACT RECORD DID NOT MATCHED
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'The cost of item ' + D.strItemNo + ' did not match with the contract price.'
			,'Bill'
			,A.strBillId
			,A.intBillId
		FROM  tblAPBill A
		INNER JOIN tblAPBillDetail C ON A.intBillId = C.intBillId
		INNER JOIN (tblCTContractHeader B1 INNER JOIN tblCTContractDetail B2 ON B1.intContractHeaderId = B2.intContractHeaderId)
			ON C.intContractDetailId = B2.intContractDetailId
		INNER JOIN tblICItem D ON C.intItemId = D.intItemId
		WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		AND A.ysnPosted = 0 AND C.intContractDetailId IS NOT NULL AND B1.intPricingTypeId NOT IN (7)
		AND ISNULL(B2.dblCashPrice,0) <> ISNULL(C.dblCost,0)

	END
	ELSE
	BEGIN
		--ALREADY HAVE PAYMENTS
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT
			'You cannot unpost this bill. ' + A.strPaymentRecordNum + ' payment was already made on this bill. You must delete the payable first.',
			'Bill',
			C.strBillId,
			C.intBillId
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

		--NO FISCAL PERIOD
		INSERT INTO @returntable(strError, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			'Bill',
			A.strBillId,
			A.intBillId
		FROM tblAPBill A 
		WHERE  A.[intBillId] IN (SELECT [intBillId] FROM @tmpBills) AND 
			0 = ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0)
	END

	RETURN
END
