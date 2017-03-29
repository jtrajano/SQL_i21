CREATE VIEW [dbo].[vyuAP1099PATR]
AS

WITH PATR1099 (
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
	,dblDividends
	,dblNonpatronage
	,dblPerUnit
	,dblFederalTax
	,dblRedemption
	,dblDomestic
	,dblInvestment
	,dblOpportunity
	,dblAMT
	,dblOther
	,intEntityVendorId
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
									, +' ' + B.strZip
									, B.strCountry
									, B.strPhone)
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
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 1 THEN SUM(A.dbl1099) ELSE NULL END AS dblDividends
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 2 THEN SUM(A.dbl1099) ELSE NULL END AS dblNonpatronage
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 3 THEN SUM(A.dbl1099) ELSE NULL END AS dblPerUnit
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 4 THEN SUM(A.dbl1099) ELSE NULL END AS dblFederalTax
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 5 THEN SUM(A.dbl1099) ELSE NULL END AS dblRedemption
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 6 THEN SUM(A.dbl1099) ELSE NULL END AS dblDomestic
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 7 THEN SUM(A.dbl1099) ELSE NULL END AS dblInvestment
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 8 THEN SUM(A.dbl1099) ELSE NULL END AS dblOpportunity
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 9 THEN SUM(A.dbl1099) ELSE NULL END AS dblAMT
	, CASE WHEN A.int1099Form = 4 AND A.int1099Category = 10 THEN SUM(A.dbl1099) ELSE NULL END AS dblOther
	, A.[intEntityId]
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 4
GROUP BY intYear, [intEntityId]
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
,A.int1099Form
,A.int1099Category
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
	,SUM(ISNULL(dblDividends,0)
		+ ISNULL(dblNonpatronage,0)
		+ ISNULL(dblPerUnit,0)
		+ ISNULL(dblFederalTax,0)
		+ ISNULL(dblRedemption,0)
		+ ISNULL(dblDomestic,0)
		+ ISNULL(dblInvestment,0)
		+ ISNULL(dblOpportunity,0)
		+ ISNULL(dblAMT,0)
		+ ISNULL(dblOther,0)) AS dblTotalPayment
FROM PATR1099 A
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
	,dblDividends
	,dblNonpatronage
	,dblPerUnit
	,dblFederalTax
	,dblRedemption
	,dblDomestic
	,dblInvestment
	,dblOpportunity
	,dblAMT
	,dblOther