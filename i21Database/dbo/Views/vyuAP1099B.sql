CREATE VIEW [dbo].[vyuAP1099B]
AS

SELECT
		strEmployerAddress = [dbo].[fnAPFormatAddress](NULL,B.strCompanyName
									, NULL
									, B.strAddress
									, B.strCity
									, B.strState
									, +' ' + B.strZip
									, B.strCountry
									, B.strPhone) COLLATE Latin1_General_CI_AS
	, B.strCompanyName
	, A.strPayeeName
	, strEIN = B.strEin--B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strVendorId COLLATE Latin1_General_CI_AS as strVendorId
	, A.strZip
	, A.strCity
	, A.strState
	, A.strZipState
	, A.strFederalTaxId
	, A.intYear
	, CASE WHEN SUM(A.dbl1099B) >= MIN(C.dbl1099B) THEN SUM(A.dbl1099B) ELSE 0 END AS dbl1099B
	, A.[intEntityId]
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 3
GROUP BY intYear, [intEntityId]
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
--,C.dbl1099B
, A.strAddress
, A.strVendorCompanyName
, A.strPayeeName
, A.strVendorId
, A.strZip
, A.strCity
, A.strState
, A.strZipState
, A.strFederalTaxId