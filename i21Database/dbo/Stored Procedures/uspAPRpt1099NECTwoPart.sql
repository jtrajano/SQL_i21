CREATE PROCEDURE [dbo].[uspAPRpt1099NECTwoPart]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @vendorFromParam NVARCHAR(100) = NULL;
DECLARE @vendorToParam NVARCHAR(100) = NULL;
DECLARE @yearParam INT = YEAR(GETDATE());
DECLARE @correctedParam BIT = 0;
DECLARE @reprint BIT = 0;
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT 
		NULL AS strCorrected, 
		NULL AS strYear, 
		*,
		
		NULL AS strCorrected2,
		NULL AS strYear2,
		NULL AS strEmployerAddress2, 
		NULL AS strCompanyName2, 
		NULL AS strEIN2, 
		NULL AS strFederalTaxId2, 
		NULL AS strAddress2, 
		NULL AS strVendorCompanyName2, 
		NULL AS strPayeeName2, 
		NULL AS strVendorId2, 
		NULL AS strZip2, 
		NULL AS strCity2, 
		NULL AS strState2, 
		NULL AS strZipState2, 
		0 AS intYear2, 
		NULL AS intEntityVendorId2, 
		0 AS dblNonemployeeCompensationNEC2, 
		NULL AS strDirectSalesXTotal2, 
		0 AS dblDirectSalesNEC2, 
		0 AS dblFederalIncomeNEC2, 
		0 AS dblStateNEC2, 
		0 AS dblTotalPayment2,

		NULL AS strCorrected3,
		NULL AS strYear3,
		NULL AS strEmployerAddress3, 
		NULL AS strCompanyName3, 
		NULL AS strEIN3, 
		NULL AS strFederalTaxId3, 
		NULL AS strAddress3, 
		NULL AS strVendorCompanyName3, 
		NULL AS strPayeeName3, 
		NULL AS strVendorId3, 
		NULL AS strZip3, 
		NULL AS strCity3, 
		NULL AS strState3, 
		NULL AS strZipState3, 
		0 AS intYear3, 
		NULL AS intEntityVendorId3, 
		0 AS dblNonemployeeCompensationNEC3, 
		NULL AS strDirectSalesXTotal3, 
		0 AS dblDirectSalesNEC3, 
		0 AS dblFederalIncomeNEC3, 
		0 AS dblStateNEC3, 
		0 AS dblTotalPayment3
	FROM vyuAP1099NEC WHERE intYear = 0 --RETURN NOTHING TO RETURN SCHEMA
	RETURN;
END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(200)
	, [to] nvarchar(200)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@vendorFromParam = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'vendorFrom'

	SELECT 
		@vendorToParam = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'vendorTo'

	SELECT 
		@yearParam = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'year'

	SELECT 
		@reprint = [from]
	FROM @temp_xml_table WHERE [fieldname] = 'reprint'

	SELECT 
		@correctedParam = CAST([from] AS BIT)
	FROM @temp_xml_table WHERE [fieldname] = 'corrected'
END;

WITH NEC1099 (
	int1099NECId,
	strCorrected,
	strYear,
	strEmployerAddress, 
	strCompanyName, 
	strEIN, 
	strFederalTaxId, 
	strAddress, 
	strVendorCompanyName, 
	strPayeeName, 
	strVendorId, 
	strZip, 
	strCity, 
	strState, 
	strZipState, 
	intYear, 
	intEntityVendorId, 
	dblNonemployeeCompensationNEC, 
	strDirectSalesXTotal, 
	dblDirectSalesNEC, 
	dblFederalIncomeNEC, 
	dblStateNEC, 
	dblTotalPayment
)
AS 
(
	SELECT 
		int1099NECId = ROW_NUMBER() OVER(ORDER BY (SELECT 1))
		,(CASE WHEN ISNULL(@correctedParam,0) = 0 THEN NULL ELSE 'X' END) AS strCorrected
		,(SELECT RIGHT(@yearParam,2)) AS strYear
		,A.* 
	FROM vyuAP1099NEC A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 1
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
						(CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
							WHEN History.ysnPrinted IS NULL THEN 1
							WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
						ELSE 0 END)
			END)
)

SELECT
	NEC1099Top.strCorrected, 
	NEC1099Top.strYear,
	NEC1099Top.strEmployerAddress, 
	NEC1099Top.strCompanyName, 
	NEC1099Top.strEIN, 
	NEC1099Top.strFederalTaxId, 
	NEC1099Top.strAddress, 
	NEC1099Top.strVendorCompanyName, 
	NEC1099Top.strPayeeName, 
	NEC1099Top.strVendorId, 
	NEC1099Top.strZip, 
	NEC1099Top.strCity, 
	NEC1099Top.strState, 
	NEC1099Top.strZipState, 
	NEC1099Top.intYear, 
	NEC1099Top.intEntityVendorId, 
	NEC1099Top.dblNonemployeeCompensationNEC, 
	NEC1099Top.strDirectSalesXTotal, 
	NEC1099Top.dblDirectSalesNEC, 
	NEC1099Top.dblFederalIncomeNEC, 
	NEC1099Top.dblStateNEC, 
	NEC1099Top.dblTotalPayment,
	NEC1099Middle.strCorrected AS strCorrected2, 
	NEC1099Middle.strYear AS strYear2,
	NEC1099Middle.strEmployerAddress AS strEmployerAddress2, 
	NEC1099Middle.strCompanyName AS strCompanyName2, 
	NEC1099Middle.strEIN AS strEIN2, 
	NEC1099Middle.strFederalTaxId AS strFederalTaxId2, 
	NEC1099Middle.strAddress AS strAddress2, 
	NEC1099Middle.strVendorCompanyName AS strVendorCompanyName2, 
	NEC1099Middle.strPayeeName AS strPayeeName2, 
	NEC1099Middle.strVendorId AS strVendorId2, 
	NEC1099Middle.strZip AS strZip2, 
	NEC1099Middle.strCity AS strCity2, 
	NEC1099Middle.strState AS strState2, 
	NEC1099Middle.strZipState AS strZipState2, 
	NEC1099Middle.intYear AS intYear2, 
	NEC1099Middle.intEntityVendorId AS intEntityVendorId2, 
	NEC1099Middle.dblNonemployeeCompensationNEC AS dblNonemployeeCompensationNEC2, 
	NEC1099Middle.strDirectSalesXTotal AS strDirectSalesXTotal2, 
	NEC1099Middle.dblDirectSalesNEC AS dblDirectSalesNEC2, 
	NEC1099Middle.dblFederalIncomeNEC AS dblFederalIncomeNEC2, 
	NEC1099Middle.dblStateNEC AS dblStateNEC2, 
	NEC1099Middle.dblTotalPayment AS dblTotalPayment2,
	NEC1099Bottom.strCorrected AS strCorrected3, 
	NEC1099Bottom.strYear AS strYear3,
	NEC1099Bottom.strEmployerAddress AS strEmployerAddress3, 
	NEC1099Bottom.strCompanyName AS strCompanyName3, 
	NEC1099Bottom.strEIN AS strEIN3, 
	NEC1099Bottom.strFederalTaxId AS strFederalTaxId3, 
	NEC1099Bottom.strAddress AS strAddress3, 
	NEC1099Bottom.strVendorCompanyName AS strVendorCompanyName3, 
	NEC1099Bottom.strPayeeName AS strPayeeName3, 
	NEC1099Bottom.strVendorId AS strVendorId3, 
	NEC1099Bottom.strZip AS strZip3, 
	NEC1099Bottom.strCity AS strCity3, 
	NEC1099Bottom.strState AS strState3, 
	NEC1099Bottom.strZipState AS strZipState3, 
	NEC1099Bottom.intYear AS intYear3, 
	NEC1099Bottom.intEntityVendorId AS intEntityVendorId3, 
	NEC1099Bottom.dblNonemployeeCompensationNEC AS dblNonemployeeCompensationNEC3, 
	NEC1099Bottom.strDirectSalesXTotal AS strDirectSalesXTotal3, 
	NEC1099Bottom.dblDirectSalesNEC AS dblDirectSalesNEC3, 
	NEC1099Bottom.dblFederalIncomeNEC AS dblFederalIncomeNEC3, 
	NEC1099Bottom.dblStateNEC AS dblStateNEC3, 
	NEC1099Bottom.dblTotalPayment AS dblTotalPayment3
FROM (
	SELECT *
	FROM NEC1099 A
	WHERE ROUND(((A.int1099NECId / 3.00) % 1), 2) = .33
) NEC1099Top
OUTER APPLY (
	SELECT *
	FROM NEC1099 A
	WHERE A.int1099NECId = (NEC1099Top.int1099NECId + 1)
) NEC1099Middle
OUTER APPLY (
	SELECT *
	FROM NEC1099 A
	WHERE A.int1099NECId = (NEC1099Middle.int1099NECId + 1)
) NEC1099Bottom