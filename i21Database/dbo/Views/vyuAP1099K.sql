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
		, A.[intEntityId]
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
	, MONTH(A.dtmDate)
)

SELECT
	*
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