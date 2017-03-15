CREATE PROCEDURE [dbo].[uspARGLAccountReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = ''
	BEGIN 
		SET @xmlParam = NULL

		DECLARE @tempGLTable TABLE(	
			 [intAccountId]			INT
			,[dblGLBalance]			NUMERIC(18,6)
			,[strAccountId]			NVARCHAR(100)
			,[strAccountCategory]	NVARCHAR(MAX)
		)

		SELECT * FROM @tempGLTable
	END

-- Declare the variables.
DECLARE  @xmlDocumentId				AS INT
		,@query						AS NVARCHAR(MAX)
		,@filter					AS NVARCHAR(MAX) = ''
		,@fieldname					AS NVARCHAR(50)
		,@condition					AS NVARCHAR(20)
		,@id						AS INT 
		,@from						AS NVARCHAR(100)
		,@to						AS NVARCHAR(100)
		,@join						AS NVARCHAR(10)
		,@begingroup				AS NVARCHAR(50)
		,@endgroup					AS NVARCHAR(50)
		,@datatype					AS NVARCHAR(50)
		,@dtmAsOfDate				AS DATETIME
		
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50)
	,[condition]	NVARCHAR(20)
	,[from]			NVARCHAR(100)
	,[to]			NVARCHAR(100)
	,[join]			NVARCHAR(10)
	,[begingroup]	NVARCHAR(50)
	,[endgroup]		NVARCHAR(50)
	,[datatype]		NVARCHAR(50)
)

-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(100)
	, [to]		   NVARCHAR(100)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

-- Gather the variables values from the xml table.
SELECT	@dtmAsOfDate   = ISNULL([to], '')
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

IF @dtmAsOfDate IS NULL
    SET @dtmAsOfDate = GETDATE()

SELECT GLD.intAccountId
     , strAccountId
	 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
	 , strAccountCategory
FROM tblGLDetail GLD
	INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
		AND GLAD.strAccountCategory = 'AR Account'
WHERE GLD.ysnIsUnposted = 0
AND GLD.dtmDate <= @dtmAsOfDate
GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory

UNION ALL 

SELECT GLD.intAccountId
     , strAccountId
	 , dblGLBalance         = SUM(dblDebit) - SUM(dblCredit)
	 , strAccountCategory
FROM tblGLDetail GLD
	INNER JOIN vyuGLAccountDetail GLAD ON GLD.intAccountId = GLAD.intAccountId
		AND GLAD.strAccountCategory = 'Customer Prepayments'
WHERE GLD.ysnIsUnposted = 0
AND GLD.dtmDate <= @dtmAsOfDate
GROUP BY GLD.intAccountId, GLAD.strAccountId, strAccountCategory