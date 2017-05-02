CREATE PROCEDURE [dbo].[uspPRUBGRetirementReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Sample XML string structure:
--SET @xmlParam = '
--<xmlparam>
-- <filters>
--  <filter>
--   <fieldname>strEmployeeDeductionId</fieldname>
--   <condition>Between</condition>
--   <from>UBG-EMP</from>
--   <to></to>
--   <join>And</join>
--   <begingroup>0</begingroup>
--   <endgroup>0</endgroup>
--   <datatype>Integer</datatype>
--  </filter>
-- </filters>
-- <options />
--</xmlparam>'

-- Sanitize the @xmlParam
IF LTRIM(RTRIM(@xmlParam)) = ''
SET @xmlParam = NULL
  
-- Declare the variables.  
DECLARE @strEmployeeDeductionId AS NVARCHAR(50)
		,@strEmployerDeductionId AS NVARCHAR(50)
		,@dtmBeginDate AS DATETIME
		,@dtmEndDate AS DATETIME
		,@strBeginEmployeeNo AS NVARCHAR(50)
		,@strEndEmployeeNo AS NVARCHAR(50)

-- Declare the variables for the XML parameter  
DECLARE @xmlDocumentId AS INT

-- Create a table variable to hold the XML data.
DECLARE @temp_xml_table TABLE (
 [fieldname] NVARCHAR(50)
 ,condition NVARCHAR(20)
 ,[from] NVARCHAR(50)
 ,[to] NVARCHAR(50) 
 ,[join] NVARCHAR(10)
 ,[begingroup] NVARCHAR(50)
 ,[endgroup] NVARCHAR(50)
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
 , [from] nvarchar(50)
 , [to] nvarchar(50)
 , [join] nvarchar(10)
 , [begingroup] nvarchar(50)
 , [endgroup] nvarchar(50)
 , [datatype] nvarchar(50)
)

-- Gather the variables values from the xml table.
SELECT @strEmployeeDeductionId = ISNULL((SELECT TOP 1 [from] FROM @temp_xml_table WHERE [fieldname] = 'strEmployeeDeductionId'), '')
SELECT @strEmployerDeductionId = ISNULL((SELECT TOP 1 [from] FROM @temp_xml_table WHERE [fieldname] = 'strEmployerDeductionId'), '') 
SELECT @dtmBeginDate = CAST(ISNULL((SELECT TOP 1 [from] FROM @temp_xml_table WHERE [fieldname] = 'dtmPayDate'), '1753-1-1') AS DATETIME)
SELECT @dtmEndDate = CAST(ISNULL((SELECT TOP 1 ISNULL([to], ISNULL([from], '9999-12-31')) FROM @temp_xml_table WHERE [fieldname] = 'dtmPayDate'), '9999-12-31') AS DATETIME)
SELECT @strBeginEmployeeNo = ISNULL((SELECT TOP 1 [from] FROM @temp_xml_table WHERE [fieldname] = 'strEmployeeId'), (SELECT MIN(strEmployeeId) FROM tblPREmployee))
SELECT @strEndEmployeeNo = ISNULL((SELECT TOP 1 [to] FROM @temp_xml_table WHERE [fieldname] = 'strEmployeeId'), (SELECT MAX(strEmployeeId) FROM tblPREmployee))

-- Report Query:
SELECT DISTINCT
 EMP.strSocialSecurity
 ,EMP.strLastName
 ,EMP.strFirstName
 ,EMP.strMiddleName
 ,strPayType = LEFT(EMP.strType, 1)
 ,strPayClass = CASE WHEN (EXISTS(SELECT TOP 1 1 FROM tblPREmployeeEarning ER1 WHERE intEntityEmployeeId = EMP.intEntityEmployeeId AND ER1.strCalculationType = 'Hourly Rate'))
					 THEN 'H'
					 ELSE 'S' END
 ,dtmTerminated = EMP.dtmTerminated
 ,dtmUnpaidLeaveDate = NULL
 ,dtmReturnDate = NULL
 ,intYear
 ,dblHours = ISNULL(PC.dblHours, 0)
 ,dblHoursYTD = ISNULL(PC.dblHoursYTD, 0)
 ,dblGross = ISNULL(PC.dblGross, 0)
 ,dblGrossYTD = ISNULL(PC.dblGrossYTD, 0)
 ,dblWithholdingWages = ISNULL(PC.dblWithholdingWages, 0)
 ,dblWithholdingWagesYTD = ISNULL(PC.dblWithholdingWagesYTD, 0)
 ,dblDeductionTotal = ISNULL(PC.dblDeductionTotal, 0)
 ,dblDeductionTotalYTD = ISNULL(PC.dblDeductionTotalYTD, 0)
 ,dblDeferredCompDist = 0
 ,dblDeferredCompDistYTD = 0
 ,dblEmployeeCont = ISNULL(PC.dblEmployeeCont, 0)
 ,dblEmployeeContYTD = ISNULL(PC.dblEmployeeContYTD, 0)
 ,dblEmployerCont = ISNULL(PC.dblEmployerCont, 0)
 ,dblEmployerContYTD = ISNULL(PC.dblEmployerContYTD, 0)
FROM 
	tblPREmployee [EMP]
	LEFT JOIN
	(SELECT 
		PC.intEntityEmployeeId
		,intYear = YEAR(PC.dtmPayDate)
		,dblHours = SUM(ISNULL(PC.dblTotalHours, 0))
		,dblHoursYTD = MAX(ISNULL(PCYTD.dblTotalHoursYTD, 0))
		,dblGross = SUM(ISNULL(PC.dblGross, 0))
		,dblGrossYTD = MAX(ISNULL(PCYTD.dblGrossYTD, 0))
		,dblWithholdingWages = SUM(ISNULL(PC.dblAdjustedGross, 0))
		,dblWithholdingWagesYTD = MAX(ISNULL(PCYTD.dblAdjustedGrossYTD, 0))
		,dblDeductionTotal = SUM(ISNULL(PRETAX.dblTotal, 0))
		,dblDeductionTotalYTD = MAX(ISNULL(PRETAX.dblTotalYTD, 0))
		,dblDeferredCompDist = 0
		,dblDeferredCompDistYTD = 0
		,dblEmployeeCont = SUM(ISNULL(COOP.dblTotal, 0))
		,dblEmployeeContYTD = MAX(ISNULL(COOP.dblTotalYTD, 0))
		,dblEmployerCont = SUM(ISNULL(COOPCO.dblTotal, 0))
		,dblEmployerContYTD = MAX(ISNULL(COOPCO.dblTotalYTD, 0))
	FROM 
		tblPRPaycheck PC
		INNER JOIN vyuPRPaycheckYTD PCYTD 
			ON PC.intPaycheckId = PCYTD.intPaycheckId
		INNER JOIN (SELECT intPaycheckId, dblTotal = SUM(dblTotal), dblTotalYTD = SUM(dblTotalYTD)
					FROM vyuPRPaycheckDeduction WHERE strDeductFrom = 'Gross Pay' AND ysnVoid = 0
					AND dtmPayDate >= @dtmBeginDate AND dtmPayDate < DATEADD(DAY, 1, @dtmEndDate)
					GROUP BY intPaycheckId) PRETAX 
			ON PC.intPaycheckId = PRETAX.intPaycheckId
		INNER JOIN vyuPRPaycheckDeduction COOP 
			ON PC.intPaycheckId = COOP.intPaycheckId AND COOP.strDeduction = @strEmployeeDeductionId AND COOP.ysnVoid = 0
		INNER JOIN vyuPRPaycheckDeduction COOPCO 
			ON PC.intPaycheckId = COOPCO.intPaycheckId AND COOPCO.strDeduction = @strEmployerDeductionId AND COOPCO.ysnVoid = 0
	WHERE 
		PC.dtmPayDate >= @dtmBeginDate AND PC.dtmPayDate < DATEADD(DAY, 1, @dtmEndDate) AND PC.ysnVoid = 0
	GROUP BY
		PC.intEntityEmployeeId
		,YEAR(PC.dtmPayDate)) [PC]
	ON EMP.intEntityEmployeeId = PC.intEntityEmployeeId
WHERE 
	EMP.strEmployeeId BETWEEN @strBeginEmployeeNo AND @strEndEmployeeNo