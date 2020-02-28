CREATE PROCEDURE [dbo].[uspCMBankReconReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
DECLARE @intBankAccountId AS INT
		,@dtmStatementDate AS DATETIME

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
SELECT	@intBankAccountId = [from]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intBankAccountId'

SELECT	@dtmStatementDate = CAST([from] AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmStatementDate'
		
-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmStatementDate IS NOT NULL
	SET @dtmStatementDate = CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)
	
-- SANITIZE THE BANK ACCOUNT ID
--SET @intBankAccountIdFrom = ISNULL(@intBankAccountIdFrom, 0)
--SET @intBankAccountIdTo = ISNULL(@intBankAccountIdTo, @intBankAccountIdFrom)
--IF @intBankAccountIdFrom > @intBankAccountIdTo
--	SET @intBankAccountIdTo = @intBankAccountIdFrom

;WITH DEBIT_CREDIT AS(
	SELECT 
	strDescription,
	sum(dblAmount) totalAmount
	FROM 
	[dbo].[fnCMGetBankReconDebitCreditValues] (@intBankAccountId, @dtmStatementDate, 'All')
	GROUP BY strDescription
)
SELECT	intBankAccountId				= BankAccnt.intBankAccountId
		,dtmStatementDate				= @dtmStatementDate
		,strCbkNo						= BankAccnt.strCbkNo
		,strBankName					= Bank.strBankName
		,strGLAccountId					= GL.strAccountId
		,dblGLBalance					= isnull([dbo].[fnGetBankGLBalance](BankAccnt.intBankAccountId, @dtmStatementDate),0)
		,dblBankAccountBalance			= isnull([dbo].[fnCMGetBankBalance](BankAccnt.intBankAccountId, @dtmStatementDate),0)
		,dblPriorReconEndingBalance		= isnull([dbo].[fnGetBankBeginningBalance](BankAccnt.intBankAccountId, @dtmStatementDate),0)
		,dblClearedPayments				= isnull(ClearedPayment.totalAmount,0)
		,dblClearedDeposits				= isnull(ClearedDeposit.totalAmount,0)
		,dblBankStatementEndingBalance	= isnull([dbo].[fnGetBankCurrentEndingBalance](BankAccnt.intBankAccountId, @dtmStatementDate),0)
		,dblUnclearedPayments			= isnull(UnClearedPayment.totalAmount,0)
		,dblUnclearedPaymentsNotVoidYet	= isnull(UnClearedPaymentNotVoidYet.totalAmount,0)
		,dblUnclearedDeposits			= isnull(UnClearedDeposit.totalAmount,0)
		,strCompanyName
FROM	dbo.tblCMBankAccount BankAccnt INNER JOIN dbo.tblCMBank Bank
			ON BankAccnt.intBankId = Bank.intBankId
		INNER JOIN dbo.tblGLAccount GL
			ON BankAccnt.intGLAccountId = GL.intAccountId
		LEFT JOIN tblSMCompanySetup COMPANY 
			ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup)
OUTER APPLY (
	SELECT totalAmount FROM DEBIT_CREDIT WHERE strDescription = 'PaymentClearedNotVoid'
)ClearedPayment
OUTER APPLY (
	SELECT totalAmount FROM DEBIT_CREDIT WHERE strDescription = 'DepositClearedNotVoid'
)ClearedDeposit
OUTER APPLY (
	SELECT totalAmount FROM DEBIT_CREDIT WHERE strDescription = 'PaymentNotClearedNotVoid'
)UnClearedPayment
OUTER APPLY (
	SELECT totalAmount FROM DEBIT_CREDIT WHERE strDescription = 'DepositNotClearedNotVoid'
)UnClearedDeposit

OUTER APPLY (
	SELECT totalAmount FROM DEBIT_CREDIT WHERE strDescription = 'PaymentNotClearedNotVoidYet'
)UnClearedPaymentNotVoidYet
WHERE	BankAccnt.intBankAccountId = @intBankAccountId
		AND @dtmStatementDate IS NOT NULL