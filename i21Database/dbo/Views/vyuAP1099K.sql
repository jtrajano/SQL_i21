CREATE VIEW [dbo].[vyuAP1099K]
AS 

WITH K1099 (
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
	,strFilerType
	,strTransactionType
	,strMerchantCode
	,dblJanuary
	,dblFebruary
	,dblMarch
	,dblApril
	,dblMay
	,dblJune
	,dblJuly
	,dblAugust
	,dblSeptember
	,dblOctober
	,dblNovember
	,dblDecember
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
		, C.strFilerType
		, C.strTransactionType
		, C.strMerchantCode
		, CASE WHEN MONTH(A.dtmDate) = 1 THEN SUM(A.dbl1099K) ELSE NULL END AS dblJanuary
		, CASE WHEN MONTH(A.dtmDate) = 2 THEN SUM(A.dbl1099K) ELSE NULL END AS dblFebruary
		, CASE WHEN MONTH(A.dtmDate) = 3 THEN SUM(A.dbl1099K) ELSE NULL END AS dblMarch
		, CASE WHEN MONTH(A.dtmDate) = 4 THEN SUM(A.dbl1099K) ELSE NULL END AS dblApril
		, CASE WHEN MONTH(A.dtmDate) = 5 THEN SUM(A.dbl1099K) ELSE NULL END AS dblMay
		, CASE WHEN MONTH(A.dtmDate) = 6 THEN SUM(A.dbl1099K) ELSE NULL END AS dblJune
		, CASE WHEN MONTH(A.dtmDate) = 7 THEN SUM(A.dbl1099K) ELSE NULL END AS dblJuly
		, CASE WHEN MONTH(A.dtmDate) = 8 THEN SUM(A.dbl1099K) ELSE NULL END AS dblAugust
		, CASE WHEN MONTH(A.dtmDate) = 9 THEN SUM(A.dbl1099K) ELSE NULL END AS dblSeptember
		, CASE WHEN MONTH(A.dtmDate) = 10 THEN SUM(A.dbl1099K) ELSE NULL END AS dblOctober
		, CASE WHEN MONTH(A.dtmDate) = 11 THEN SUM(A.dbl1099K) ELSE NULL END AS dblNovember
		, CASE WHEN MONTH(A.dtmDate) = 12 THEN SUM(A.dbl1099K) ELSE NULL END AS dblDecember
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 6
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
	, C.strFilerType
	, C.strTransactionType
	, C.strMerchantCode
	, MONTH(A.dtmDate)
),
grossThirdParty (
	intEntityVendorId,
	dblGrossThirdParty,
	dblCardNotPresent
)
AS 
(
	SELECT
		A.intEntityId AS intEntityVendorId,
		CASE WHEN A.int1099Category = 1 THEN SUM(dbl1099K) ELSE NULL END AS dblCardNotPresent,
		CASE WHEN A.int1099Category = 2 THEN SUM(dbl1099K) ELSE NULL END AS dblGrossThirdParty
	FROM vyuAP1099 A
	WHERE A.int1099Form = 6
	GROUP BY A.intEntityId, A.int1099Category
)

SELECT
	A.strEmployerAddress
	,A.strCompanyName
	,A.strEIN
	,A.strFederalTaxId
	,A.strAddress
	,A.strVendorCompanyName
	,A.strPayeeName
	,A.strVendorId
	,A.strZip
	,A.strCity
	,A.strState
	,A.strZipState
	,A.intYear
	,A.intEntityVendorId
	,A.strFilerType
	,A.strTransactionType
	,A.strMerchantCode
	,B.dblCardNotPresent AS dblCardNotPresent
	,B.dblGrossThirdParty AS dblGrossThirdParty
	,0 AS dblFederalIncomeTax
	,SUM(dblJanuary) dblJanuary
	,SUM(dblFebruary) dblFebruary
	,SUM(dblMarch) dblMarch
	,SUM(dblApril) dblApril
	,SUM(dblMay) dblMay
	,SUM(dblJune) dblJune
	,SUM(dblJuly) dblJuly
	,SUM(dblAugust) dblAugust
	,SUM(dblSeptember) dblSeptember
	,SUM(dblOctober) dblOctober
	,SUM(dblNovember) dblNovember
	,SUM(dblDecember) dblDecember
	,SUM(ISNULL(dblJanuary,0)
		+ ISNULL(dblFebruary,0)
		+ ISNULL(dblMarch,0)
		+ ISNULL(dblApril,0)
		+ ISNULL(dblMay,0)
		+ ISNULL(dblJune,0)
		+ ISNULL(dblJuly,0)
		+ ISNULL(dblAugust,0)
		+ ISNULL(dblSeptember,0)
		+ ISNULL(dblOctober,0)
		+ ISNULL(dblNovember,0)
		+ ISNULL(dblDecember,0)) AS dblTotalPayment
FROM K1099 A
INNER JOIN grossThirdParty B ON A.intEntityVendorId = B.intEntityVendorId
GROUP BY A.intEntityVendorId
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
	,strFilerType
	,strTransactionType
	,strMerchantCode
	,intYear
	,dblCardNotPresent
	,dblGrossThirdParty
HAVING SUM(ISNULL(dblJanuary,0)
		+ ISNULL(dblFebruary,0)
		+ ISNULL(dblMarch,0)
		+ ISNULL(dblApril,0)
		+ ISNULL(dblMay,0)
		+ ISNULL(dblJune,0)
		+ ISNULL(dblJuly,0)
		+ ISNULL(dblAugust,0)
		+ ISNULL(dblSeptember,0)
		+ ISNULL(dblOctober,0)
		+ ISNULL(dblNovember,0)
		+ ISNULL(dblDecember,0)) > 0