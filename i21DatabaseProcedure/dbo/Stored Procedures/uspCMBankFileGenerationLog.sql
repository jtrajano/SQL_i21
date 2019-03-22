CREATE PROCEDURE [dbo].[uspCMBankFileGenerationLog]
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@strFileName NVARCHAR(100) = NULL,
	@strProcessType NVARCHAR(50) = NULL,
	@intBankFileFormatId INT = NULL,
	@intEntityId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intBatchId INT = 0
SELECT TOP 1 @intBatchId =  ISNULL(MAX(intBatchId),0) + 1 from tblCMBankFileGenerationLog


IF (@strProcessType = 'ACH From Customer')
BEGIN
	DELETE FROM tblCMBankFileGenerationLog
	WHERE intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
	AND strProcessType = strProcessType

	 
	INSERT INTO tblCMBankFileGenerationLog
	(
	intBankAccountId
	,intTransactionId
	,strTransactionId
	,strProcessType
	,intBankFileFormatId
	,dtmGenerated
	,intBatchId
	,strFileName
	,ysnSent
	,dtmSent
	,intEntityId
	)
	SELECT
	 @intBankAccountId
	,intUndepositedFundId
	,strSourceTransactionId
	,@strProcessType
	,@intBankFileFormatId
	,GETDATE()
	,@intBatchId
	,@strFileName
	,0
	,null
	,@intEntityId
	FROM tblCMUndepositedFund
	WHERE intUndepositedFundId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))

END
ELSE
BEGIN

	IF (@strFileName != 'Not yet generated')
	BEGIN
		DELETE FROM tblCMBankFileGenerationLog
		WHERE intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
		AND strProcessType = strProcessType
	 
		INSERT INTO tblCMBankFileGenerationLog
		(
		intBankAccountId
		,intTransactionId
		,strTransactionId
		,strProcessType
		,intBankFileFormatId
		,dtmGenerated
		,intBatchId
		,strFileName
		,ysnSent
		,dtmSent
		,intEntityId
		)
		SELECT
		 @intBankAccountId
		,intTransactionId
		,strTransactionId
		,@strProcessType
		,@intBankFileFormatId
		,GETDATE()
		,@intBatchId
		,@strFileName
		,0
		,null
		,@intEntityId
		FROM tblCMBankTransaction
		WHERE intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))

		--Mark the transaction as printed
		UPDATE tblCMBankTransaction SET dtmCheckPrinted = GETDATE()
		WHERE  intTransactionId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds))
		AND dtmCheckPrinted IS NULL

	END
	ELSE
	BEGIN
	 
		INSERT INTO tblCMBankFileGenerationLog
		(
		intBankAccountId
		,intTransactionId
		,strTransactionId
		,strProcessType
		,intBankFileFormatId
		,dtmGenerated
		,intBatchId
		,strFileName
		,ysnSent
		,dtmSent
		,intEntityId
		)
		SELECT
		 @intBankAccountId
		,intTransactionId
		,strTransactionId
		,@strProcessType
		,@intBankFileFormatId
		,GETDATE()
		,0
		,@strFileName
		,0
		,null
		,@intEntityId
		FROM tblCMBankTransaction
		WHERE strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

		--Mark the transaction as printed
		UPDATE tblCMBankTransaction SET dtmCheckPrinted = GETDATE() WHERE strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

		-- Update the check number audit and mark it as printed
		UPDATE  tblCMCheckNumberAudit SET
			 strTransactionId = B.strTransactionId
			,intTransactionId = B.intTransactionId
			,intCheckNoStatus = 3 --@CHECK_NUMBER_STATUS_PRINTED
			,strRemarks = ''
			,intUserId = @intEntityId
			,dtmCheckPrinted = GETDATE()
		FROM tblCMCheckNumberAudit A
			INNER JOIN tblCMBankTransaction B ON A.strCheckNo = B.strReferenceNo
		WHERE A.intBankAccountId = @intBankAccountId
		AND B.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

		--Update the reference no of other module's transaction
		--AP
		UPDATE tblAPPayment SET strPaymentInfo = B.strReferenceNo 
		FROM tblAPPayment A
		INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
		WHERE B.intBankAccountId = @intBankAccountId 
			AND B.intBankTransactionTypeId = 16
			AND B.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		--PR
		UPDATE tblPRPaycheck SET strReferenceNo = B.strReferenceNo, ysnPrinted = 1 
		FROM tblPRPaycheck A
		INNER JOIN tblCMBankTransaction B ON A.strPaycheckId = B.strTransactionId
		WHERE B.intBankAccountId = @intBankAccountId 
			AND B.intBankTransactionTypeId = 21
			AND B.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

		--Insert to audit log
		INSERT INTO tblSMAuditLog (
			strActionType,
			strDescription,
			strJsonData,
			strRecordNo,
			strTransactionType,
			intEntityId,
			intConcurrencyId,
			dtmDate
		)	SELECT 
			(CASE WHEN intBankTransactionTypeId = 16 THEN  
					'Printed'
					WHEN intBankTransactionTypeId = 22 THEN
					'Generated'
					END)
			,''
			,'{"action":"'+ 
					(CASE WHEN intBankTransactionTypeId = 16 THEN  
					'Printed'
					WHEN intBankTransactionTypeId = 22 THEN
					'Generated'
					END) 
				+'","iconCls":"small-gear","children":[]}' 
			,intPaymentId
			,'AccountsPayable.view.PayVouchersDetail'
			,@intEntityId
			,1
			,GETUTCDATE()
		FROM tblAPPayment A
		INNER JOIN tblCMBankTransaction B ON A.strPaymentRecordNum = B.strTransactionId
		WHERE B.intBankAccountId = @intBankAccountId 
			AND B.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

		UNION ALL SELECT 
			(CASE WHEN intBankTransactionTypeId = 21 THEN  
					'Printed'
					WHEN intBankTransactionTypeId = 23 THEN
					'Generated'
					END)
			,''
			,'{"action":"'+ 
					(CASE WHEN intBankTransactionTypeId = 21 THEN  
					'Printed'
					WHEN intBankTransactionTypeId = 23 THEN
					'Generated'
					END) 
				+'","iconCls":"small-gear","children":[]}' 
			,intPaycheckId
			,'Payroll.view.Paycheck'
			,@intEntityId
			,1
			,GETUTCDATE()
		FROM tblPRPaycheck A
		INNER JOIN tblCMBankTransaction B ON A.strPaycheckId = B.strTransactionId
		WHERE B.intBankAccountId = @intBankAccountId 
			AND B.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))

	END
END