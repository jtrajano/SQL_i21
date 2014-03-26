/*
	This stored procedure is used as data source in the Voucher Check Middle Sub Report
*/
CREATE PROCEDURE uspCMVoucherCheckMiddleSubReport
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
--			<fieldname>intTransactionId</fieldname>
--			<condition>Between</condition>
--			<from>14973</from>
--			<to>14973</to>
--			<join>And</join>
--			<begingroup>0</begingroup>
--			<endgroup>0</endgroup>
--			<datatype>String</datatype>
--		</filter>
--	</filters>
--	<options />
--</xmlparam>'

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
	SET @xmlParam = NULL 

-- Declare the variables.
DECLARE @intTransactionIdFrom AS INT
		,@intTransactionIdTo AS INT

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
SELECT	@intTransactionIdFrom = [from]
		,@intTransactionIdTo = [to]
FROM	@temp_xml_table 
WHERE	[fieldname] = 'intTransactionId'

-- Sanitize the parameters
SET @intTransactionIdFrom = CASE WHEN ISNULL(@intTransactionIdFrom, 0) = 0 THEN NULL ELSE @intTransactionIdFrom END
SET @intTransactionIdTo = CASE WHEN ISNULL(@intTransactionIdTo, 0) = 0 THEN NULL ELSE @intTransactionIdTo END

-- Report Query:
SELECT	TOP 15 
		BD.intTransactionDetailId
		,BD.intTransactionId
		,Accnt.strAccountID
		,BD.strDescription
		,E.strName
		,BD.dblDebit
		,BD.dblCredit
FROM	[dbo].[tblCMBankTransactionDetail] BD INNER JOIN [dbo].[tblGLAccount] Accnt
			ON BD.intGLAccountId = Accnt.intAccountID
		LEFT JOIN [dbo].[tblEntity] E
			ON BD.intEntityId = E.intEntityId
WHERE	BD.intTransactionId >= ISNULL(@intTransactionIdFrom, BD.intTransactionId)
		AND BD.intTransactionId <= ISNULL(@intTransactionIdTo, BD.intTransactionId)
