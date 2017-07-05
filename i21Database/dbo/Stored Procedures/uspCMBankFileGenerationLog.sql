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

	END
END