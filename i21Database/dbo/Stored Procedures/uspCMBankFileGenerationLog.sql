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