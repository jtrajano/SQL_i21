/*
For Cash Projection (DASH-2443)
*/	
CREATE VIEW dbo.vyuAPOpenPayables
AS
    SELECT
		A.dtmDueDate		
		,tmpAgingSummaryTotal.dblAmountDue 
		FROM  
		(
			SELECT 
			intBillId
			,dtmDueDate
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT dblTotal, dblInterest,dblAmountPaid,dblDiscount, intBillId,dtmDueDate FROM dbo.vyuAPPayables
			) tmpAPPayables 
			GROUP BY intBillId,dtmDueDate
			UNION ALL
			SELECT 
			intBillId
			,dtmDueDate	
			,CAST((SUM(tmpAPPayables2.dblTotal) + SUM(tmpAPPayables2.dblInterest) - SUM(tmpAPPayables2.dblAmountPaid) - SUM(tmpAPPayables2.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT dblTotal, dblInterest,dblAmountPaid,dblDiscount, intBillId, dtmDueDate FROM dbo.vyuAPPrepaidPayables
			) tmpAPPayables2 
			GROUP BY intBillId,dtmDueDate
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		UNION ALL
		SELECT
			A.dtmDueDate
			,CAST((SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPSalesForPayables A
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
		WHERE D.strAccountCategory = 'AP Account' --there are old data where cash refund have been posted to non AP account
		GROUP BY A.dtmDueDate
		UNION ALL
		SELECT
			tmpAgingSummaryTotal.dtmDueDate
			,tmpAgingSummaryTotal.dblAmountDue 
		FROM  
		(
			SELECT 
				intBillId
				,dtmDueDate
				,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT 
					intBillId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
					,intCount
					,dtmDueDate
				  FROM dbo.vyuAPPayablesAgingDeleted
			) tmpAPPayables 
			GROUP BY intBillId,dtmDueDate
			HAVING SUM(DISTINCT intCount) > 1 --DO NOT INCLUDE DELETED REPORT IF THAT IS ONLY THE PART OF DELETED DATA
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBillArchive A ON tmpAgingSummaryTotal.intBillId = A.intBillId
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId