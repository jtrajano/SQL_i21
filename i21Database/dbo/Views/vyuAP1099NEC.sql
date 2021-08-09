CREATE VIEW [dbo].[vyuAP1099NEC]
AS

WITH NEC1099 (
	strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,intYear
	,intEntityVendorId
	,dblNonemployeeCompensationNEC
	,strDirectSalesXTotal
	,dblDirectSalesNEC
	,dblFederalIncomeNEC
	,dblStateNEC
)
AS
(
	SELECT
		  strEmployerAddress = [dbo].[fnAPFormatAddress](NULL
										, B.strCompanyName
										, NULL
										, B.strAddress
										, B.strCity
										, B.strState
										, +' '+B.strZip
										, B.strCountry
										, B.strPhone) COLLATE Latin1_General_CI_AS
		, B.strCompanyName
		, strEIN = B.strEin--B.strFederalTaxID
		, A.strFederalTaxId
		, A.strAddress
		, A.strVendorCompanyName
		, A.strPayeeName
		, A.strVendorId
		, A.strZip
		, A.strCity
		, A.strState
		, A.strZipState
		, A.intYear
		, A.[intEntityId]
		, CASE WHEN SUM(A.dblNonemployeeCompensationNEC) != 0 THEN SUM(A.dblNonemployeeCompensationNEC) ELSE NULL END
		, CASE WHEN SUM(A.dblDirectSalesNEC) >= 5000 THEN 'X' ELSE '' END AS strDirectSalesXTotal
		, CASE WHEN SUM(A.dblDirectSalesNEC) != 0 THEN SUM(A.dblDirectSalesNEC) ELSE NULL END
		, CASE WHEN SUM(A.dblFederalIncomeNEC) != 0 THEN SUM(A.dblFederalIncomeNEC) ELSE NULL END
		, CASE WHEN SUM(A.dblStateNEC) != 0 THEN SUM(A.dblStateNEC) ELSE NULL END
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 7
	GROUP BY intYear, [intEntityId]
	,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strPayeeName
	, A.strVendorId
	, A.strZip
	, A.strFederalTaxId
	, A.strCity
	, A.strState
	, A.strZipState
)

SELECT
	*
	,SUM(ISNULL(dblNonemployeeCompensationNEC,0)
		+ ISNULL(dblFederalIncomeNEC,0)) AS dblTotalPayment
FROM NEC1099 A
GROUP BY intEntityVendorId
	,strEmployerAddress
	,strCompanyName
	,strEIN
	,strFederalTaxId
	,strAddress
	,strVendorCompanyName
	,strPayeeName
	,strVendorId
	,strZip
	,strCity
	,strState
	,strZipState
	,intYear
	,intEntityVendorId
	,dblNonemployeeCompensationNEC
	,strDirectSalesXTotal
	,dblDirectSalesNEC
	,dblFederalIncomeNEC
	,dblStateNEC
HAVING SUM(ISNULL(dblNonemployeeCompensationNEC,0)) >= 600 OR SUM(ISNULL(dblFederalIncomeNEC,0)) > 0
	
GO