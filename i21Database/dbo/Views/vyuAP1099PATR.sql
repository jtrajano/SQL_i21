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
									, B.strPhone) COLLATE Latin1_General_CI_AS
	, B.strCompanyName
	, strEIN = B.strEin--B.strFederalTaxID
	, A.strFederalTaxId
	, A.strAddress
	, A.strVendorCompanyName
	, A.strPayeeName
	, A.strVendorId  COLLATE Latin1_General_CI_AS as strVendorId
	, A.strZip
	, A.strCity
	, A.strState
	, A.strZipState
	, A.intYear
	, CASE WHEN A.int1099Form = 4 AND  SUM(A.dblDividends)		!= 0 THEN SUM(A.dblDividends)	ELSE NULL END AS dblDividends
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblNonpatronage)	!= 0 THEN SUM(A.dblNonpatronage) ELSE NULL END AS dblNonpatronage
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblPerUnit)			!= 0 THEN SUM(A.dblPerUnit)		ELSE NULL END AS dblPerUnit
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblFederalTax)		!= 0 THEN SUM(A.dblFederalTax)	ELSE NULL END AS dblFederalTax
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblRedemption)		!= 0 THEN SUM(A.dblRedemption)	ELSE NULL END AS dblRedemption
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblDomestic)		!= 0 THEN SUM(A.dblDomestic)	ELSE NULL END AS dblDomestic
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblInvestments) 	!= 0 THEN SUM(A.dblInvestments) ELSE NULL END AS dblInvestment
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblOpportunity) 	!= 0 THEN SUM(A.dblOpportunity) ELSE NULL END AS dblOpportunity
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblAMT)				!= 0 THEN SUM(A.dblAMT)			ELSE NULL END AS dblAMT
	, CASE WHEN A.int1099Form = 4 AND SUM(A.dblOther)			!= 0 THEN SUM(A.dblOther)		ELSE NULL END AS dblOther
	, A.[intEntityId]
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 4
GROUP BY intYear, [intEntityId]
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
,A.int1099Form
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