CREATE FUNCTION [dbo].[fnPATValidateAssociatedTransaction]
(
	@transactionIds NVARCHAR(MAX),
	@type INT, -- 1 = Issued Stock, 2 = Retired Stock, 3 = Equity Payment, 4 = Voucher
	@transaction NVARCHAR(MAX) = NULL
)
RETURNS @returnTable TABLE
(
	strError NVARCHAR(MAX),
	strTransactionType NVARCHAR(50),
	strTransactionNo NVARCHAR(50),
	intTransactionId INT
)
BEGIN
	DECLARE @tmpTransactions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);

	INSERT INTO @tmpTransactions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	IF(@type = 1)
	BEGIN
		INSERT INTO @returnTable
		SELECT	'Invoice('+ ARI.strInvoiceNumber +') for Issued Stock is already paid.',
				'Issued Stock',
				ARI.strInvoiceNumber,
				ARI.intInvoiceId
		FROM tblPATCustomerStock CS
		INNER JOIN tblARInvoice ARI
			ON ARI.intInvoiceId = CS.intInvoiceId
		WHERE ARI.ysnPaid = 1 AND CS.strActivityStatus = 'Open' AND CS.intCustomerStockId IN (SELECT * FROM @tmpTransactions)
	END
	ELSE IF(@type = 2)
	BEGIN
		INSERT INTO @returnTable
		SELECT	'Voucher('+ APB.strBillId +') for Retired Stock is already paid.',
				'Retired Stock',
				APB.strBillId,
				APB.intBillId
		FROM tblPATCustomerStock CS
		INNER JOIN tblAPBill APB
			ON APB.intBillId = CS.intBillId
		WHERE APB.ysnPaid = 1 AND CS.strActivityStatus = 'Retired' AND CS.intCustomerStockId IN (SELECT * FROM @tmpTransactions)
	END
	ELSE IF(@type = 3)
	BEGIN
		INSERT INTO @returnTable
		SELECT	'Voucher('+ APB.strBillId +') for Equity Payment is already paid.',
				'Equity Payment',
				APB.strBillId,
				APB.intBillId
		FROM tblPATEquityPaySummary EPS
		INNER JOIN tblAPBill APB
			ON APB.intBillId = EPS.intBillId
		WHERE APB.ysnPaid = 1 AND EPS.intEquityPaySummaryId IN (SELECT * FROM @tmpTransactions)
	END
	ELSE IF (@type = 4)
	BEGIN
		INSERT INTO @returnTable
		SELECT	'This voucher was created from Patronage Retire Stock - <strong>'+ CS.strCertificateNo +'</strong>. Unpost it from there.',
				'Voucher',
				APB.strBillId,
				APB.intBillId
		FROM tblAPBill APB
		INNER JOIN tblPATCustomerStock CS
			ON APB.intBillId = CS.intBillId
		WHERE APB.ysnPosted = 1 AND APB.intBillId IN (SELECT * FROM @tmpTransactions) AND @transaction != 'Patronage'
	END
	ELSE IF (@type = 5)
	BEGIN
		INSERT INTO @returnTable
		SELECT 'Could not unpost Refund. Refund Voucher <strong>'+ APB.strBillId +'</strong> is already paid.',
				'Refund',
				APB.strBillId,
				APB.intBillId
		FROM tblPATRefundCustomer RC
		INNER JOIN tblAPBill APB
			ON APB.intBillId = RC.intBillId
		WHERE APB.ysnPaid = 1 AND RC.intRefundId IN (SELECT * FROM @tmpTransactions)
	END

	RETURN
END