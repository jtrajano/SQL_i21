﻿CREATE VIEW [dbo].[vyuAPPayablesAgingSummary]
WITH SCHEMABINDING
AS
SELECT
A.dtmDate
,A.dtmDueDate
,B.strVendorId
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
	,dblTotal
	,dblAmountPaid
	,dblAmountDue
	,dblInterest
	,dblDiscount
	FROM dbo.vyuAPPayablesSummary
) AS tmpAgingSummaryTotal
LEFT JOIN dbo.tblAPBill A
ON A.intBillId = tmpAgingSummaryTotal.intBillId
LEFT JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.intEntityId = C.intEntityId)
ON B.intVendorId = A.intVendorId
