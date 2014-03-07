CREATE PROCEDURE uspCMCheckNumberAuditReport
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE	@CHK_NUM_STATUS_UNUSED AS INT = 1
		,@CHK_NUM_STATUS_USED AS INT = 2
		,@CHK_NUM_STATUS_PRINTED AS INT = 3
		,@CHK_NUM_STATUS_VOID AS INT = 4
		,@CHK_NUM_STATUS_WASTED AS INT = 5
		,@CHK_NUM_STATUS_FOR_PRINT_VERIFICATION AS INT = 6	
		
DECLARE	@CHK_NUM_STATUS_UNUSED_VALUE AS NVARCHAR(50) = 'Unused'
		,@CHK_NUM_STATUS_USED_VALUE AS NVARCHAR(50) = 'Used'
		,@CHK_NUM_STATUS_PRINTED_VALUE AS NVARCHAR(50) = 'Printed'
		,@CHK_NUM_STATUS_VOID_VALUE AS NVARCHAR(50) = 'Void'
		,@CHK_NUM_STATUS_WASTED_VALUE AS NVARCHAR(50) = 'Wasted'
		,@CHK_NUM_STATUS_FOR_PRINT_VERIFICATION_VALUE AS NVARCHAR(50) = 'For Print Verification'			

-- Sample XML string structure:
--SET @xmlparam = '
--<xmlparam>
--	<filters>
--		<filter>
--			<fieldname>intBankAccountId</fieldname>
--			<condition>Between</condition>
--			<from>1</from>
--			<to>1</to>
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>Int</datatype>
--		</filter>
--		<filter>
--			<fieldname>dtmStatementDate</fieldname>
--			<condition>Equal To</condition>
--			<from>02/14/2014</from>
--			<to />
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>DateTime</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE @intBankAccountIdFrom AS INT
		,@intBankAccountIdTo AS INT

		-- Declare the variables for the XML parameter
		,@xmlDocumentId AS INT
		
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
	, condition nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [begingroup] nvarchar(50)
	, [endgroup] nvarchar(50)
	, [datatype] nvarchar(50)
)

-- Gather the variables values from the xml table. 
SELECT	@intBankAccountIdFrom = [from]
		,@intBankAccountIdTo = [to]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intBankAccountId'
			
-- SANITIZE THE BANK ACCOUNT ID
SET @intBankAccountIdFrom = ISNULL(@intBankAccountIdFrom, 0)
SET @intBankAccountIdTo = ISNULL(@intBankAccountIdTo, @intBankAccountIdFrom)
IF @intBankAccountIdFrom > @intBankAccountIdTo
	SET @intBankAccountIdTo = @intBankAccountIdFrom

-- THE REPORT QUERY:
SELECT	intBankAccountId		= BankAccnt.intBankAccountId
		,intCheckNumberAuditId	= CheckNumberAudit.intCheckNumberAuditId
		,strCheckNo				= CheckNumberAudit.strCheckNo
		,intCheckNoStatus		= CheckNumberAudit.intCheckNoStatus
		,strCheckNoStatus		= CASE	WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_UNUSED		THEN @CHK_NUM_STATUS_UNUSED_VALUE
										WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_USED		THEN @CHK_NUM_STATUS_USED_VALUE
										WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_PRINTED	THEN @CHK_NUM_STATUS_PRINTED_VALUE
										WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_VOID		THEN @CHK_NUM_STATUS_VOID_VALUE
										WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_WASTED		THEN @CHK_NUM_STATUS_WASTED_VALUE
										WHEN CheckNumberAudit.intCheckNoStatus = @CHK_NUM_STATUS_FOR_PRINT_VERIFICATION		THEN @CHK_NUM_STATUS_FOR_PRINT_VERIFICATION_VALUE
								END
		,strRemarks				= CheckNumberAudit.strRemarks
		,strTransactionId		= CheckNumberAudit.strTransactionId
FROM	dbo.tblCMBankAccount BankAccnt RIGHT JOIN dbo.tblCMCheckNumberAudit CheckNumberAudit
			ON BankAccnt.intBankAccountId = CheckNumberAudit.intBankAccountId
WHERE	BankAccnt.intBankAccountId BETWEEN @intBankAccountIdFrom AND @intBankAccountIdTo

