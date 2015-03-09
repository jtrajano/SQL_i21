CREATE VIEW vyuAPPayablesSummary
WITH SCHEMABINDING
AS 
SELECT 
A.intBillId
,A.strBillId
,B.strVendorId
,tmpAPPayablesSummary.dblTotal
,tmpAPPayablesSummary.dblAmountPaid
,tmpAPPayablesSummary.dblDiscount
,tmpAPPayablesSummary.dblInterest
,tmpAPPayablesSummary.dblAmountDue
FROM (
	SELECT 
	intBillId
	,SUM(tmpAPPayables.dblTotal) AS dblTotal
	,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
	,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
	,SUM(tmpAPPayables.dblInterest) AS dblInterest
	,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
	FROM (
		SELECT 
		intBillId
		,dblTotal
		,dblAmountDue
		,dblAmountPaid
		,dblDiscount
		,dblInterest
		FROM dbo.vyuAPPayables	
		) tmpAPPayables 
	GROUP BY intBillId
	) tmpAPPayablesSummary
LEFT JOIN dbo.tblAPBill A
ON A.intBillId = tmpAPPayablesSummary.intBillId
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.intEntityVendorId = C.intEntityId)
ON B.intEntityVendorId = A.intVendorId

