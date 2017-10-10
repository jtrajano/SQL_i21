﻿CREATE PROCEDURE [dbo].[uspARCustomerAgingReport]
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
		
		SELECT * FROM tblARCustomerAgingStagingTable
	END

-- Declare the variables.
DECLARE @dtmDateTo						DATETIME
      , @dtmDateFrom					DATETIME
	  , @intEntityCustomerId			INT	= NULL
	  , @strSalesperson					NVARCHAR(100)
	  , @strCustomerName				NVARCHAR(MAX)
	  , @xmlDocumentId					INT
	  , @filter							NVARCHAR(MAX) = ''
	  , @fieldname						NVARCHAR(50)
	  , @condition						NVARCHAR(20)
	  , @id								INT 
	  , @from							NVARCHAR(100)
	  , @to								NVARCHAR(100)
	  , @join							NVARCHAR(10)
	  , @begingroup						NVARCHAR(50)
	  , @endgroup						NVARCHAR(50)
	  , @datatype						NVARCHAR(50)
	  , @strSourceTransaction			NVARCHAR(100)
	  , @strAgedBalances				NVARCHAR(100)
	  , @ysnPrintOnlyOverCreditLimit	BIT
	
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
SELECT  @strCustomerName = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strCustomerName'

SELECT  @strSalesperson = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSalespersonName'

SELECT  @dtmDateFrom = CAST(CASE WHEN ISNULL([from], '') <> '' THEN [from] ELSE CAST(-53690 AS DATETIME) END AS DATETIME)
 	   ,@dtmDateTo   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmAsOfDate'

SELECT  @strSourceTransaction = ISNULL([from], '')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strSourceTransaction'

SELECT	@strAgedBalances = ISNULL([from], 'All')
FROM	@temp_xml_table
WHERE	[fieldname] = 'strAgedBalances'

SELECT	@ysnPrintOnlyOverCreditLimit = CASE WHEN ISNULL([from], 'False') = 'False' THEN 0 ELSE 1 END
FROM	@temp_xml_table
WHERE	[fieldname] = 'ysnPrintOnlyOverCreditLimit'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDateTo IS NOT NULL
	SET @dtmDateTo = CAST(FLOOR(CAST(@dtmDateTo AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDateTo = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

IF @dtmDateFrom IS NOT NULL
	SET @dtmDateFrom = CAST(FLOOR(CAST(@dtmDateFrom AS FLOAT)) AS DATETIME)	
ELSE 			  
	SET @dtmDateFrom = CAST(-53690 AS DATETIME)
	
TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , strCustomerInfo
	 , intEntityCustomerId
	 , dblCreditLimit
	 , dblTotalAR
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblTotalDue
	 , dblAmountPaid
	 , dblCredits
	 , dblPrepayments
	 , dblPrepaids
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
)
EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateFrom = @dtmDateFrom
										, @dtmDateTo = @dtmDateTo
										, @strSalesperson = @strSalesperson
										, @strSourceTransaction = @strSourceTransaction
										, @strCustomerName	= @strCustomerName
EXEC dbo.uspARGLAccountReport @dtmDateTo

DELETE FROM tblARCustomerAgingStagingTable WHERE dblTotalAR = 0

IF @strAgedBalances = 'Current'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl0Days, 0) = 0
END
ELSE IF @strAgedBalances = '1-10 Days'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl10Days, 0) = 0
END
ELSE IF @strAgedBalances = '11-30 Days'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl30Days, 0) = 0
END
ELSE IF @strAgedBalances = '31-60 Days'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl60Days, 0) = 0
END
ELSE IF @strAgedBalances = '61-90 Days'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl90Days, 0) = 0
END
ELSE IF @strAgedBalances = 'Over 90 Days'
	BEGIN DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dbl91Days, 0) = 0
END

IF ISNULL(@ysnPrintOnlyOverCreditLimit, 0) = 1
	BEGIN
		DELETE FROM tblARCustomerAgingStagingTable WHERE ISNULL(dblCreditLimit, 0) > ISNULL(dblTotalAR, 0)
									    OR (ISNULL(dblCreditLimit, 0) = 0 AND ISNULL(dblTotalAR, 0) = 0)
										OR ISNULL(dblCreditLimit, 0) = 0
	END

SELECT * FROM tblARCustomerAgingStagingTable
