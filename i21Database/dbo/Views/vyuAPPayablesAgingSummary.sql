CREATE VIEW [dbo].[vyuAPPayablesAgingSummary]
WITH SCHEMABINDING
AS
SELECT
A.dtmDate
,A.dtmDueDate
,B.strVendorId
,B.[intEntityVendorId]
,A.intBillId
,A.strBillId
,A.intAccountId
,D.strAccountId
,tmpAgingSummaryTotal.dblTotal
,tmpAgingSummaryTotal.dblAmountPaid
,tmpAgingSummaryTotal.dblDiscount
,tmpAgingSummaryTotal.dblInterest
,tmpAgingSummaryTotal.dblAmountDue
,ISNULL(B.strVendorId,'') + ' - ' + isnull(C.strName,'') as strVendorIdName 
,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
		ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
		ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
		THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent,
	CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
		THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
		THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
		THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
		THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl90
,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 'Current'
		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 THEN '01 - 30 Days'
		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60 THEN '31 - 60 Days' 
		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 THEN '61 - 90 Days'
		WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90 THEN 'Over 90' 
		ELSE 'Current' END AS strAge
FROM  
(
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
		,dtmDate
		FROM dbo.vyuAPPayables
		) tmpAPPayables 
	GROUP BY intBillId
) AS tmpAgingSummaryTotal
LEFT JOIN dbo.tblAPBill A
ON A.intBillId = tmpAgingSummaryTotal.intBillId
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.[intEntityVendorId] = C.intEntityId)
ON B.[intEntityVendorId] = A.intVendorId
LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
