CREATE VIEW [dbo].[vyuAPAging]
AS

--use tblAPBill table if dynamic is not needed for performance
SELECT
	A.dtmDate
	,A.dtmDueDate
	,B.strVendorId
	,C.strName as strVendorName
	,B.[intEntityId] as intEntityVendorId
	,A.intBillId
	,A.strBillId
	,A.strVendorOrderNumber
	,T.strTerm
	,(SELECT Top 1 strCompanyName FROM dbo.tblSMCompanySetup) as strCompanyName
	,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
	,A.intAccountId
	,D.strAccountId
	,tmpAgingSummaryTotal.dblTotal
	,tmpAgingSummaryTotal.dblAmountPaid
	,tmpAgingSummaryTotal.dblDiscount
	,tmpAgingSummaryTotal.dblInterest
	,tmpAgingSummaryTotal.dblAmountDue
	,dbo.fnTrim(ISNULL(B.strVendorId, C.strEntityNo) + ' - ' + isnull(C.strName,'')) as strVendorIdName 
	,EC.strClass
	,F.strCommodityCode
	,CASE WHEN tmpAgingSummaryTotal.dblAmountDue>=0 THEN 0 
			ELSE tmpAgingSummaryTotal.dblAmountDue END AS dblUnappliedAmount
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 THEN 0
			ELSE DATEDIFF(dayofyear,A.dtmDueDate,GETDATE()) END AS intAging
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=0 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dblCurrent
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>0 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=10 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl0
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>10 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=30 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl1 
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>30 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=60
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl30
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>60 AND DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())<=90 
			THEN tmpAgingSummaryTotal.dblAmountDue ELSE 0 END AS dbl60
	,CASE WHEN DATEDIFF(dayofyear,A.dtmDueDate,GETDATE())>90  
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
	LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
	LEFT JOIN dbo.tblSMTerm T ON A.intTermsId = T.intTermID
	LEFT JOIN dbo.tblEMEntityClass EC ON EC.intEntityClassId = C.intEntityClassId
	LEFT JOIN vyuAPVoucherCommodity F ON F.intBillId = tmpAgingSummaryTotal.intBillId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
