CREATE VIEW [dbo].[vyuAP1099DIV]
AS

WITH DIV1099 (
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
	,dblOrdinaryDividends
	,dblQualified
	,dblCapitalGain
	,dblUnrecapGain
	,dblSection1202
	,dblCollectibles
	,dblNonDividends
	,dblFITW
	,dblInvestment
	,dblForeignTax
	,dblForeignCountry
	,dblCash
	,dblNonCash
	,dblExempt
	,dblPrivate
	,dblState
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
	, A.strVendorId COLLATE Latin1_General_CI_AS as strVendorId
	, A.strZip
	, A.strCity
	, A.strState
	, A.strZipState
	, A.intYear
	, CASE WHEN SUM(dblOrdinaryDividends)	!= 0 THEN  SUM(dblOrdinaryDividends) ELSE NULL END  AS dblOrdinaryDividends
	, CASE WHEN SUM(dblQualified)			!= 0 THEN  SUM(dblQualified)		 ELSE NULL END 	AS dblQualified
	, CASE WHEN SUM(dblCapitalGain)			!= 0 THEN  SUM(dblCapitalGain)		 ELSE NULL END 	AS dblCapitalGain
	, CASE WHEN SUM(dblUnrecapGain)			!= 0 THEN  SUM(dblUnrecapGain)		 ELSE NULL END 	AS dblUnrecapGain
	, CASE WHEN SUM(dblSection1202)			!= 0 THEN  SUM(dblSection1202)		 ELSE NULL END 	AS dblSection1202
	, CASE WHEN SUM(dblCollectibles)		!= 0 THEN  SUM(dblCollectibles)		 ELSE NULL END 	AS dblCollectibles
	, CASE WHEN SUM(dblNonDividends)		!= 0 THEN  SUM(dblNonDividends)		 ELSE NULL END 	AS dblNonDividends
	, CASE WHEN SUM(dblFITW)				!= 0 THEN  SUM(dblFITW)				 ELSE NULL END 	AS dblFITW
	, CASE WHEN SUM(dblInvestment)			!= 0 THEN  SUM(dblInvestment)		 ELSE NULL END 	AS dblInvestment
	, CASE WHEN SUM(dblForeignTax)			!= 0 THEN  SUM(dblForeignTax)		 ELSE NULL END 	AS dblForeignTax
	, CASE WHEN SUM(dblForeignCountry)		!= 0 THEN  SUM(dblForeignCountry)	 ELSE NULL END 	AS dblForeignCountry
	, CASE WHEN SUM(dblCash)				!= 0 THEN  SUM(dblCash)				 ELSE NULL END 	AS dblCash
	, CASE WHEN SUM(dblNonCash)				!= 0 THEN  SUM(dblNonCash)			 ELSE NULL END 	AS dblNonCash
	, CASE WHEN SUM(dblExempt)				!= 0 THEN  SUM(dblExempt)			 ELSE NULL END 	AS dblExempt
	, CASE WHEN SUM(dblPrivate)				!= 0 THEN  SUM(dblPrivate)			 ELSE NULL END 	AS dblPrivate
	, CASE WHEN SUM(dblState)				!= 0 THEN  SUM(dblState)			 ELSE NULL END	AS dblState
	, A.intEntityVendorId																		  
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 5
GROUP BY intYear, intEntityVendorId
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
	 ,SUM(ISNULL(dblOrdinaryDividends,0)
		+ ISNULL(dblQualified,0)
		+ ISNULL(dblCapitalGain,0)
		+ ISNULL(dblUnrecapGain,0)
		+ ISNULL(dblSection1202,0)
		+ ISNULL(dblCollectibles,0)
		+ ISNULL(dblNonDividends,0)
		+ ISNULL(dblFITW,0)
		+ ISNULL(dblInvestment,0)
		+ ISNULL(dblForeignTax,0)
		+ ISNULL(dblForeignCountry,0)
		+ ISNULL(dblCash,0)
		+ ISNULL(dblNonCash,0)
		+ ISNULL(dblExempt,0)
		+ ISNULL(dblPrivate,0)
		+ ISNULL(dblState,0)) AS dblTotalPayment
FROM DIV1099 A
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
	,dblOrdinaryDividends
	,dblQualified
	,dblCapitalGain
	,dblUnrecapGain
	,dblSection1202
	,dblCollectibles
	,dblNonDividends
	,dblFITW
	,dblInvestment
	,dblForeignTax
	,dblForeignCountry
	,dblCash
	,dblNonCash
	,dblExempt
	,dblPrivate
	,dblState