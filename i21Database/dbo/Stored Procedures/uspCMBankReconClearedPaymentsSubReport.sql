CREATE PROCEDURE uspCMBankReconClearedPaymentsSubReport
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20

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
SELECT	@intBankAccountIdFrom = [from]
		,@intBankAccountIdTo = [to]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intBankAccountId'

SELECT	@dtmStatementDate = CAST([from] AS DATETIME)
FROM	@temp_xml_table 
WHERE	[fieldname] = 'dtmStatementDate'
		
-- SANITIZE THE DATE AND REMOVE THE TIME.
IF @dtmStatementDate IS NOT NULL
	SET @dtmStatementDate = CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)		
	
-- SANITIZE THE BANK ACCOUNT ID
SET @intBankAccountIdFrom = ISNULL(@intBankAccountIdFrom, 0)
SET @intBankAccountIdTo = ISNULL(@intBankAccountIdTo, @intBankAccountIdFrom)
IF @intBankAccountIdFrom > @intBankAccountIdTo
	SET @intBankAccountIdTo = @intBankAccountIdFrom
		
SELECT	intBankAccountId = BankTrans.intBankAccountId
		,dtmStatementDate = @dtmStatementDate
		,strCbkNo = BankAccnt.strCbkNo
		,ysnClr = BankTrans.ysnClr
		,dtmDate = BankTrans.dtmDate
		,dtmDateReconciled = BankTrans.dtmDateReconciled
		,strReferenceNo = BankTrans.strReferenceNo
		,strPayee = BankTrans.strPayee
		,strMemo = BankTrans.strMemo
		,strRecordNo = BankTrans.strTransactionId
		,dblPayment = ABS(BankTrans.dblAmount)
		,dblDeposit = 0
		,intBankTransactionTypeId = BankTrans.intBankTransactionTypeId
		,strBankTransactionTypeName = BankTypes.strBankTransactionTypeName
FROM	[dbo].[tblCMBankTransaction] BankTrans INNER JOIN [dbo].[tblCMBankAccount] BankAccnt
			ON BankTrans.intBankAccountId = BankAccnt.intBankAccountId
		INNER JOIN [dbo].[tblCMBank] Bank
			ON BankAccnt.intBankId = Bank.intBankId
		INNER JOIN [dbo].[tblCMBankTransactionType] BankTypes
			ON BankTrans.intBankTransactionTypeId = BankTypes.intBankTransactionTypeId
			
WHERE	BankTrans.ysnPosted = 1
		AND BankTrans.ysnClr = 1
		AND BankTrans.intBankAccountId BETWEEN @intBankAccountIdFrom AND @intBankAccountIdTo
		AND BankTrans.dblAmount <> 0		
		AND CAST(FLOOR(CAST(BankTrans.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, BankTrans.dtmDate) AS FLOAT)) AS DATETIME)
		AND (
			-- Filter date reconciled. 
			-- 1. Include only bank transaction if not permanently reconciled. 
			-- 2. Or if the bank transaction is reconciled on the provided statement date. 
			BankTrans.dtmDateReconciled IS NULL 
			OR CAST(FLOOR(CAST(BankTrans.dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(@dtmStatementDate AS FLOAT)) AS DATETIME)
		)
		AND (
			-- Filter for all the bank payments and debits:
			BankTrans.intBankTransactionTypeId IN (@BANK_WITHDRAWAL, @MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL, @ORIGIN_WIRE, @AP_PAYMENT, @AP_ECHECK)
			OR ( BankTrans.dblAmount < 0 AND BankTrans.intBankTransactionTypeId = @BANK_TRANSACTION )
		)