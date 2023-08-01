CREATE PROCEDURE [dbo].[uspARMainCustomerInquiryReport]
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
		
		SELECT * FROM tblARCustomerInquiryStagingTable
	END

-- Declare the variables.
DECLARE @dtmDate						DATETIME
	  , @intEntityUserId				INT	= NULL
	  , @strCustomerIds					NVARCHAR(MAX)
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
	  , @strReportLogId					NVARCHAR(MAX)
	  , @strCompanyName					NVARCHAR(MAX)
	  , @strCompanyAddress				NVARCHAR(MAX)
	  	
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	 [id]			INT IDENTITY(1,1)
	,[fieldname]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[condition]	NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[from]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[to]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
	,[begingroup]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
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

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
WITH (
	  [fieldname]  NVARCHAR(50)
	, [condition]  NVARCHAR(20)
	, [from]	   NVARCHAR(MAX)
	, [to]		   NVARCHAR(MAX)
	, [join]	   NVARCHAR(10)
	, [begingroup] NVARCHAR(50)
	, [endgroup]   NVARCHAR(50)
	, [datatype]   NVARCHAR(50)
)

WHILE EXISTS (SELECT TOP 1 NULL FROM @temp_xml_table WHERE [fieldname] = 'strCustomerName')
	BEGIN
		SELECT TOP 1 @condition = [condition]
				   , @from		= REPLACE(ISNULL([from], ''), '''''', '''')
				   , @to		= REPLACE(ISNULL([to], ''), '''''', '''')
				   , @fieldname = [fieldname]
				   , @id		= [id]
		FROM @temp_xml_table 
		WHERE [fieldname] = 'strCustomerName'

		IF UPPER(@condition) = UPPER('Equal To')
			BEGIN				
				IF @fieldname = 'strCustomerName'
					BEGIN
						SELECT @strCustomerIds = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
						FROM (
							SELECT DISTINCT CAST(C.intEntityCustomerId AS VARCHAR(200))  + ', '
							FROM vyuARCustomerSearch C
							INNER JOIN @temp_xml_table TT ON LTRIM(RTRIM(C.strName)) = REPLACE(ISNULL(TT.[from], ''), '''''', '''')
							WHERE TT.fieldname = 'strCustomerName'
							  AND TT.condition = 'Equal To'
							FOR XML PATH ('')
						) C (intEntityCustomerId)
					END
			END

		DELETE FROM @temp_xml_table WHERE [fieldname] = @fieldname
		SET @condition = NULL
		SET @from = NULL
		SET @to = NULL
		SET @fieldname = NULL
		SET @id =  NULL
	END

SELECT  @dtmDate   = CAST(CASE WHEN ISNULL([to], '') <> '' THEN [to] ELSE GETDATE() END AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmDate'

SELECT  @intEntityUserId = NULLIF(CAST(ISNULL([from], '') AS INT), 0)
FROM	@temp_xml_table
WHERE	[fieldname] = 'intSrCurrentUserId'

SELECT @strReportLogId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strReportLogId'

-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmDate IS NOT NULL
	SET @dtmDate = CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
ELSE 			  
	SET @dtmDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)

SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) COLLATE Latin1_General_CI_AS
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF NOT EXISTS(SELECT * FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
BEGIN
	INSERT INTO tblSRReportLog (strReportLogId, dtmDate)
	VALUES (@strReportLogId, GETDATE())

    DELETE FROM tblARCustomerInquiryStagingTable

    INSERT INTO tblARCustomerInquiryStagingTable (
          intEntityCustomerId
		, intEntityId
		, intTermsId
		, strCustomerName
		, strTerm
		, strCustomerNumber
		, strAddress
		, strZipCode
		, strCity
		, strState
		, strCountry
		, strEmail
		, strPhone1
		, strPhone2
		, strBusinessLocation
		, strInternalNotes
		, strBudgetStatus
		, strBillToAddress
		, strBillToCity
		, strBillToState
		, strBillToZipCode
		, dblYTDSales
		, dblYDTServiceCharge
		, dblHighestAR
		, dblHighestDueAR
		, dblLastPayment
		, dblLastYearSales
		, dblLastStatement
		, dblPendingInvoice
		, dblPendingPayment
		, dblCreditLimit
		, dblFuture
		, dbl0Days
		, dbl10Days
		, dbl30Days
		, dbl60Days
		, dbl90Days
		, dbl91Days
		, dblUnappliedCredits
		, dblPrepaids
		, dblTotalDue
		, dblBudgetAmount
		, dblThru
		, dblNextPaymentAmount
		, dblAmountPastDue
		, dbl31DaysAmountDue
		, intRemainingBudgetPeriods
		, intAveragePaymentDays
		, dtmNextPaymentDate
		, dtmLastPaymentDate
		, dtmLastStatementDate
		, dtmBudgetMonth
		, dtmHighestARDate
		, dtmHighestDueARDate
		, intRowId
    ) 
	EXEC dbo.uspARCustomerInquiryReport @intEntityCustomerId    = NULL
                                      , @intEntityUserId		= @intEntityUserId
	                                  , @dtmDate				= @dtmDate
	                                  , @page					= 1	
                                      , @limit				    = 99999
	                                  , @start				    = 1	
                                      , @strCustomerIds         = @strCustomerIds

	UPDATE tblARCustomerInquiryStagingTable
	SET strCompanyAddress = @strCompanyAddress
	  , strCompanyName = @strCompanyName

	UPDATE CIST
	SET strContact = dbo.fnARFormatCustomerAddress(CONTACT.strPhone, CONTACT.strEmail, CUSTOMER.strBillToLocationName, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, NULL, 0)
	FROM tblARCustomerInquiryStagingTable CIST
	INNER JOIN vyuARCustomerContacts CONTACT ON CIST.intEntityCustomerId = CONTACT.intEntityId AND CONTACT.ysnDefaultContact = 1
	INNER JOIN vyuARCustomerSearch CUSTOMER ON CIST.intEntityCustomerId = CUSTOMER.intEntityId
END

SELECT * FROM tblARCustomerInquiryStagingTable