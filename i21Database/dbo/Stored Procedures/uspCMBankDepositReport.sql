/*
	This stored procedure is used as data source in the Deposit Summary report. 
*/
CREATE PROCEDURE uspCMBankDepositReport
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IdENTIFIER OFF
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

-- Sample XML string structure:
--SET @xmlparam = '
--<xmlparam>
--	<filters>
--		<filter>
--			<fieldname>strTransactionId</fieldname>
--			<condition>Between</condition>
--			<from>BDEP-10003</from>
--			<to>BDEP-10003</to>
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>Int</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE @strTransactionIdFrom AS NVARCHAR(40)
		,@strTransactionIdTo AS NVARCHAR(40)

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
SELECT	@strTransactionIdFrom = [from]
		,@strTransactionIdTo = [to]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'strTransactionId'
	
-- Report Query:
-- NOTE: There are certain fields here in this SP that is in A/R but it is not yet available as of the time of the coding. 
-- You will need to add new fields in the undeposited funds table to fill-in the missing fields. 

SELECT  H.intBankAccountId
		,B.strBankName
		,H.intTransactionId
		,H.strTransactionId
		,dtmPostedDate = H.dtmDate
		,dtmDetailDate = D.dtmDate		
		,strDescription = D.strDescription
		,dblAmount = D.dblCredit
		,strCheckNo = '' -- TODO: This is the check number of the check deposited by a customer. Retrieve the check number from the undeposited funds table. 
		,strPaymentMethod = '' -- TODO: This is payment method used by the customer to pay a sales invoice. Retrieve it from the undeposited funds table. 
		,strReceivedFrom = ISNULL(ED.strName, ISNULL(EH.strName, H.strPayee))
		,strSourceTransactionId = ISNULL(UF.strTransactionId, H.strTransactionId)
FROM	[dbo].[tblCMBankTransaction] H INNER JOIN [dbo].[tblCMBankTransactionDetail] D
			ON H.intTransactionId = D.intTransactionId
		INNER JOIN [dbo].[tblCMBankAccount] BA
			ON H.intBankAccountId = BA.intBankAccountId
		INNER JOIN [dbo].[tblCMBank] B
			ON BA.intBankId = B.intBankId			
		LEFT JOIN [dbo].[tblEntities] EH
			ON H.intPayeeId = EH.intEntityId			
		LEFT JOIN [dbo].[tblEntities] ED
			ON D.intEntityId = ED.intEntityId
		LEFT JOIN [dbo].[tblCMUndepositedFund] UF
			ON D.intUndepositedFundId = UF.intUndepositedFundId
WHERE	H.intBankTransactionTypeId IN (@BANK_DEPOSIT)
		AND H.strTransactionId BETWEEN ISNULL(@strTransactionIdFrom, H.strTransactionId) AND ISNULL(@strTransactionIdTo, H.strTransactionId)
