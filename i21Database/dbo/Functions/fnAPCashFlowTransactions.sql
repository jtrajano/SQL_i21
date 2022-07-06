CREATE FUNCTION [dbo].[fnAPCashFlowTransactions]
(
	@dtmFrom DATETIME = NULL,
	@dtmTo DATETIME = NULL
)
RETURNS @returntable TABLE
(
	intTransactionId INT NOT NULL,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intCurrencyId INT NOT NULL,
	dtmDate DATETIME NOT NULL,
	dblAmount DECIMAL(18, 6) NOT NULL,
	intBankAccountId INT NOT NULL,
	intGLAccountId INT NOT NULL,
	intCompanyLocationId INT NULL
)
AS
BEGIN
	INSERT @returntable
	--AP PAYABLES
	SELECT
	B.intBillId,
	B.strBillId,
	CASE B.intTransactionType
		WHEN 1 THEN 'Voucher'
		WHEN 2 THEN 'Vendor Prepayment'
		WHEN 3 THEN 'Debit Memo'
		WHEN 7 THEN 'Invalid Type'
		WHEN 9 THEN '1099 Adjustment'
		WHEN 11 THEN 'Claim'
		WHEN 12 THEN 'Prepayment Reversal'
		WHEN 13 THEN 'Basis Advance'
		WHEN 14 THEN 'Deferred Interest'
		ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	B.intCurrencyId,
	CASE WHEN B.ysnOverrideCashFlow = 1 THEN B.dtmCashFlowDate ELSE dtmDueDate END dtmDate,
	tmpAgingSummaryTotal.dblAmountDue,
	-1,
	B.intAccountId,
	B.intShipToId
	FROM  
	(
		SELECT 
			intBillId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT
				intBillId
				,dblTotal
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				FROM dbo.vyuAPPayables
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ISNULL(@dtmFrom, '01-01-1900') AND ISNULL(@dtmTo, GETDATE())) tmpAPPayables 
		GROUP BY intBillId
		UNION ALL
		SELECT 
			intBillId
			,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT
				intBillId
				,dblTotal
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				,intPrepaidRowType
				FROM dbo.vyuAPPrepaidPayables
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ISNULL(@dtmFrom, '01-01-1900') AND ISNULL(@dtmTo, GETDATE())) tmpAPPrepaidPayables 
		GROUP BY intBillId, intPrepaidRowType
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill B ON B.intBillId = tmpAgingSummaryTotal.intBillId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	UNION ALL
	--AP PAYABLES ARCHIVED
	SELECT
	B.intBillId,
	B.strBillId,
	CASE B.intTransactionType
		WHEN 1 THEN 'Voucher'
		WHEN 2 THEN 'Vendor Prepayment'
		WHEN 3 THEN 'Debit Memo'
		WHEN 7 THEN 'Invalid Type'
		WHEN 9 THEN '1099 Adjustment'
		WHEN 11 THEN 'Claim'
		WHEN 12 THEN 'Prepayment Reversal'
		WHEN 13 THEN 'Basis Advance'
		WHEN 14 THEN 'Deferred Interest'
		ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	B.intCurrencyId,
	CASE WHEN B.ysnOverrideCashFlow = 1 THEN B.dtmCashFlowDate ELSE dtmDueDate END dtmDate,
	tmpAgingSummaryTotal.dblAmountDue,
	-1,
	B.intAccountId,
	B.intShipToId
	FROM  
	(
		SELECT 
			intBillId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT
				intBillId
				,dblTotal
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				,intCount
				FROM dbo.vyuAPPayablesAgingDeleted
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ISNULL(@dtmFrom, '01-01-1900') AND ISNULL(@dtmTo, GETDATE())) tmpAPPayables 
		GROUP BY intBillId
		HAVING SUM(DISTINCT intCount) > 1 --DO NOT INCLUDE DELETED REPORT IF THAT IS ONLY THE PART OF DELETED DATA
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBillArchive B ON B.intBillId = tmpAgingSummaryTotal.intBillId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	UNION ALL
	--AR PAYABLES
	SELECT
		I.intInvoiceId,
		I.strInvoiceNumber,
		I.strTransactionType,
		I.intCurrencyId,
		CASE WHEN I.ysnOverrideCashFlow = 1 THEN I.dtmCashFlowDate ELSE dtmDueDate END dtmDate,
		tmpAgingSummaryTotal.dblAmountDue,
		-1,
		I.intAccountId,
		I.intShipToLocationId
	FROM  
	(
		SELECT 
			intInvoiceId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT --DISTINCT 
				intInvoiceId
				,dblTotal
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				FROM dbo.vyuAPSalesForPayables
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ISNULL(@dtmFrom, '01-01-1900') AND ISNULL(@dtmTo, GETDATE())) tmpAPPayables 
		GROUP BY intInvoiceId
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblARInvoice I ON I.intInvoiceId = tmpAgingSummaryTotal.intInvoiceId
	LEFT JOIN dbo.vyuGLAccountDetail AD ON  AD.intAccountId = I.intAccountId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	AND AD.strAccountCategory = 'AP Account'

	RETURN
END
