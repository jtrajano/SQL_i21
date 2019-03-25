CREATE VIEW [dbo].[vyuAPAging]
AS

SELECT TOP 100 PERCENT
	intEntityVendorId
	,SUM(dblCurrent) AS dblCurrent
	,SUM(dbl10) AS dbl10
	,SUM(dbl30) AS dbl30
	,SUM(dbl60) AS dbl60
	,SUM(dbl90) AS dbl90
	,SUM(dblOver90) AS dblOver90
	,SUM(dblAmountDue) AS dblTotalAmountDue
FROM (
	SELECT
		A.intEntityVendorId
		--,tmpAgingSummaryTotal.dblTotal
		--,tmpAgingSummaryTotal.dblAmountPaid
		--,tmpAgingSummaryTotal.dblDiscount
		--,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		-- ,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
		-- 		ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=10 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl10
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>10 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30 
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl90
		,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
				THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblOver90
		-- ,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 'Current'
		-- 		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 THEN '01 - 30 Days'
		-- 		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days' 
		-- 		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'
		-- 		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90 THEN 'Over 90' 
		-- 		ELSE 'Current' END AS strAge
		FROM  
		(
			SELECT 
				intBillId
				,SUM(tmpAPPayables.dblTotal) AS dblTotal
				,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
				,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
				,SUM(tmpAPPayables.dblInterest) AS dblInterest
				,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM 
			(
				SELECT
					intBillId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
				FROM dbo.vyuAPPayables
			) tmpAPPayables 
			GROUP BY intBillId
			UNION ALL
			SELECT 
				intBillId
				,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
				,SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
				,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
				,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
				,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM 
			(
				SELECT
					intBillId
					,intAccountId
					,dblTotal
					,dblAmountDue
					,dblAmountPaid
					,dblDiscount
					,dblInterest
					,dtmDate
					,intPrepaidRowType
				FROM dbo.vyuAPPrepaidPayables
			) tmpAPPrepaidPayables 
			GROUP BY intBillId, intPrepaidRowType
		) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill A
	ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
	ON B.[intEntityId] = A.[intEntityVendorId]
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
) agingTotal
GROUP BY intEntityVendorId
ORDER BY intEntityVendorId
