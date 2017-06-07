CREATE VIEW [dbo].[vyuAPOpenPayableDetailsFields]
AS
SELECT *
FROM (
	SELECT A.dtmDate
		,A.dtmDueDate
		,B.strVendorId
		,B.[intEntityId]
		,A.intBillId
		,A.strBillId
		,A.strVendorOrderNumber
		,T.strTerm
		,(
			SELECT TOP 1 strCompanyName
			FROM dbo.tblSMCompanySetup
			) AS strCompanyName
		,A.intAccountId
		,D.strAccountId
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblAmountPaid
		,tmpAgingSummaryTotal.dblDiscount
		,tmpAgingSummaryTotal.dblInterest
		,tmpAgingSummaryTotal.dblAmountDue
		,ISNULL(B.strVendorId, '') + ' - ' + isnull(C.strName, '') AS strVendorIdName
	FROM (
		SELECT intBillId
			,SUM(tmpAPPayables.dblTotal) AS dblTotal
			,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
			,SUM(tmpAPPayables.dblDiscount) AS dblDiscount
			,SUM(tmpAPPayables.dblInterest) AS dblInterest
			,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
		FROM (
			SELECT intBillId
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
	LEFT JOIN dbo.tblAPBill A ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN (
		dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId
		) ON B.[intEntityId] = A.[intEntityVendorId]
	LEFT JOIN dbo.tblGLAccount D ON A.intAccountId = D.intAccountId
	LEFT JOIN dbo.tblSMTerm T ON A.intTermsId = T.intTermID
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	) MainQuery