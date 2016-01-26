CREATE VIEW [dbo].[vyuAP1099B]
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
	, strEIN = B.strEin--B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strVendorId
	, A.strZip
	, A.strZipState
	, A.strFederalTaxId
	, A.intYear
	, CASE WHEN SUM(A.dbl1099B) >= C.dbl1099B THEN SUM(A.dbl1099B) ELSE 0 END AS dbl1099B
	, A.intEntityVendorId
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 3
GROUP BY intYear, intEntityVendorId
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
,C.dbl1099B
, A.strAddress
, A.strVendorCompanyName
, A.strVendorId
, A.strZip
, A.strZipState
, A.strFederalTaxId