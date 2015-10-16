CREATE VIEW [dbo].[vyuAP1099INT]
AS

SELECT
		strEmployerAddress = [dbo].[fnAPFormatAddress](NULL,B.strCompanyName
									, NULL
									, B.strAddress
									, B.strCity
									, B.strState
									, B.strZip
									, B.strCountry
									, B.strPhone)
	, B.strCompanyName
	, strEIN = B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strVendorId
	, A.strZip
	, A.strFederalTaxId
	, A.intYear
	, CASE WHEN SUM(A.dbl1099INT) >= C.dbl1099INT THEN SUM(A.dbl1099INT) ELSE 0 END AS dbl1099INT
	, A.intEntityVendorId
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 2
GROUP BY intYear, intEntityVendorId
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strFederalTaxID
,C.dbl1099INT
, A.strAddress
, A.strVendorCompanyName
, A.strVendorId
, A.strZip
, A.strFederalTaxId