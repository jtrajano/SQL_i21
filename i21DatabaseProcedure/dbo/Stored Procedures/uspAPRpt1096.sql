CREATE PROCEDURE [dbo].[uspAPRpt1096]
	@year INT
	,@form1099 INT = 0
	,@vendorFrom NVARCHAR(100)  = NULL
	,@vendorTo NVARCHAR(100)  = NULL
	,@reprint BIT = 0 
	,@corrected BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @vendorFromParam NVARCHAR(100) = @vendorFrom;
DECLARE @vendorToParam NVARCHAR(100) = @vendorTo;
DECLARE @yearParam INT = @year;
DECLARE @form1099Param INT = @form1099;
DECLARE @correctedParam BIT = @corrected;
DECLARE @reprintParam BIT = @reprint;

WITH INT1099 (
	intTotalForm
	,intYear
	,dblTotal
	,strYear
)
AS
(
	SELECT
		COUNT(*) AS intTotalForm
		,A.intYear
		,SUM(dbl1099INT) dblTotal
		,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM vyuAP1099INT A
	OUTER APPLY
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 2
		AND B.intEntityVendorId = A.[intEntityId]
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
				ELSE 
					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprintParam = 1 THEN 1 
						WHEN History.ysnPrinted IS NULL THEN 1
						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
					ELSE 0 END)
		END)
	GROUP BY A.intYear,A.strEIN,A.strCompanyName,A.strAddress,A.strCity,A.strZipState
),
B1099 (
	intTotalForm
	,intYear
	,dblTotal
	,strYear
)
AS
(
	SELECT
		COUNT(*) AS intTotalForm
		,A.intYear
		,SUM(dbl1099B) dblTotal
		,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM vyuAP1099B A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 3
		AND B.intEntityVendorId = A.[intEntityId]
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
				ELSE 
					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprintParam = 1 THEN 1 
						WHEN History.ysnPrinted IS NULL THEN 1
						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
					ELSE 0 END)
		END)
	GROUP BY A.intYear,A.strEIN,A.strCompanyName,A.strAddress,A.strCity,A.strZipState
),
MISC1099 (
	intTotalForm
	,intYear
	,dblTotal
	,strYear
)
AS
(
	SELECT
		COUNT(*) AS intTotalForm
		,A.intYear
		,SUM(dblTotalPayment) dblTotal
		,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM vyuAP1099MISC A
	OUTER APPLY
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 2
		AND B.intEntityVendorId = A.intEntityVendorId
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
				ELSE 
					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprintParam = 1 THEN 1 
						WHEN History.ysnPrinted IS NULL THEN 1
						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
					ELSE 0 END)
		END)
	GROUP BY A.intYear,A.strEIN,A.strCompanyName,A.strAddress,A.strCity,A.strZipState
),
PATR1099 (
	intTotalForm
	,intYear
	,dblTotal
	,strYear
)
AS
( 
	SELECT
		COUNT(*) AS intTotalForm
		,A.intYear
		,SUM(dblTotalPayment) dblTotal
		,(SELECT RIGHT(@yearParam,2)) AS strYear
	FROM dbo.vyuAP1099PATR A
	OUTER APPLY
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 4
		AND B.intEntityVendorId = A.intEntityVendorId
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
				ELSE 1 END)
	AND A.intYear = @yearParam
	AND 1 = (
		CASE WHEN  ISNULL(@correctedParam,0) = 1 THEN 1 
				ELSE 
					(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprintParam = 1 THEN 1 
						WHEN History.ysnPrinted IS NULL THEN 1
						WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
					ELSE 0 END)
		END)
	GROUP BY A.intYear,A.strEIN,A.strCompanyName,A.strAddress,A.strCity,A.strZipState
)

SELECT
	A.strEin
	,A.strCompanyName  
	,A.strAddress  
	,A.strCity + ', ' + A.strState + ' ' + A.strZip as strCityZipCode  
	,A.strPhone
	,SUM(intTotalForm) intTotalForm
	,SUM(dblTotal) dblTotal
	,(SELECT RIGHT(@yearParam,2)) AS strYear
	,str1099MISC = CASE WHEN EXISTS(SELECT 1 FROM MISC1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 1 THEN 1 ELSE 0 END)) THEN 'X' ELSE NULL END
	,str1099INT = CASE WHEN EXISTS(SELECT 1 FROM INT1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 2 THEN 1 ELSE 0 END)) THEN 'X' ELSE NULL END
	,str1099B = CASE WHEN EXISTS(SELECT 1 FROM B1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 3 THEN 1 ELSE 0 END)) THEN 'X' ELSE NULL END
	,str1099PATR = CASE WHEN EXISTS(SELECT 1 FROM PATR1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 4 THEN 1 ELSE 0 END)) THEN 'X' ELSE NULL END   
FROM tblSMCompanySetup A,
(
	SELECT 
		*
	FROM MISC1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 1 THEN 1 ELSE 0 END)
	UNION ALL
	SELECT 
		*
	FROM INT1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 2 THEN 1 ELSE 0 END)
	UNION ALL
	SELECT 
		*
	FROM B1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 3 THEN 1 ELSE 0 END)
	UNION ALL
	SELECT 
		*
	FROM PATR1099 WHERE 1 = (CASE WHEN @form1099Param = 0 OR @form1099Param = 4 THEN 1 ELSE 0 END)
) Data1099
GROUP BY intYear
,strEin  
,strAddress  
,strCity  
,strState
,strZip
,strCompanyName
,strYear
,strPhone