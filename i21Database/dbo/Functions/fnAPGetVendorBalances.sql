CREATE FUNCTION [dbo].[fnAPGetVendorBalances]
(
	@entityId INT
)
RETURNS @returntable TABLE
(
	intEntityVendorId INT PRIMARY KEY
	,dblFuture DECIMAL(18,6)
	,dbl0To30Days DECIMAL(18,6)
	,dbl31To60Days DECIMAL(18,6)
	,dbl61To90Days DECIMAL(18,6)
)
AS
BEGIN
	INSERT @returntable
	SELECT
		@entityId AS intEntityVendorId
		,SUM(dblFuture) dblFuture		
		,SUM(dbl0To30Days) dbl0To30Days
		,SUM(dbl31To60Days) dbl31To60Days
		,SUM(dbl61To90Days) dbl61To90Days
	FROM (
		SELECT
			A.intEntityVendorId
			,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90 THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblFuture
			,CASE 
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
				THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 END AS dbl0To30Days
			,CASE 
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60 
				THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 END AS dbl31To60Days
			,CASE 
				WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
				THEN tmpAgingSummaryTotal.dblAmountDue 
			ELSE 0 END AS dbl61To90Days
		FROM  
		(
			SELECT 
				intBillId
				,SUM(tmpAPPayables.dblTotal) AS dblTotal
				,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
				,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
				,SUM(tmpAPPayables.dblInterest) AS dblInterest
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
			FROM (
				SELECT 
					intBillId
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
		WHERE A.intEntityVendorId = @entityId
	) vendorBalances
	GROUP BY intEntityVendorId
	RETURN
END
