CREATE VIEW [dbo].[vyuAP1099INT]
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
	, strEIN = B.strEin--B.strFederalTaxID
	, A.strAddress
	, A.strVendorCompanyName
	, A.strPayeeName
	, A.strVendorId COLLATE Latin1_General_CI_AS strVendorId
	, A.strCity
	, A.strState
	, A.strZip
	, A.strZipState
	, A.strFederalTaxId
	, A.intYear
	, CASE WHEN SUM(A.dbl1099INT) >= MIN(C.dbl1099INT) THEN SUM(A.dbl1099INT) ELSE 0 END AS dbl1099INT
	, A.[intEntityId]
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 2
GROUP BY intYear, [intEntityId]
,B.strCompanyName, B.strAddress, B.strCity, B.strState, B.strZip, B.strCountry, B.strPhone, B.strEin--B.strFederalTaxID
--,C.dbl1099INT
, A.strAddress
, A.strVendorCompanyName
, A.strPayeeName
, A.strVendorId
, A.strZip
, A.strCity
, A.strState
, A.strZipState
, A.strFederalTaxId