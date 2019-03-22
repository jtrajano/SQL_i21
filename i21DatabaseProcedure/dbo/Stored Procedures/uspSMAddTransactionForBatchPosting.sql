CREATE PROCEDURE [dbo].[uspSMAddTransactionForBatchPosting]
@param NVARCHAR (MAX),
@batchId NVARCHAR (50),
@entityId INT
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#tmpTransactions') IS NOT NULL 
	DROP TABLE #tmpTransactions

	CREATE TABLE  #tmpTransactions(strTransactionId NVARCHAR (10))
	
	INSERT INTO #tmpTransactions EXEC (@param)

	INSERT INTO tblSMForBatchPosting ([strBatchId], [strTransactionType], [strTransactionId], [intTransactionId], [dblAmount], [strVendorInvoiceNumber], [intEntityVendorId], [intEntityId], [strUserName], [strDescription], [dtmDate])
	SELECT @batchId, strTransactionType, strTransactionId, intTransactionId, dblAmount, strVendorInvoiceNumber, intEntityVendorId, @entityId, strUserName, strDescription, dtmDate 
	FROM vyuSMBatchPosting
	WHERE strTransactionId COLLATE Latin1_General_CI_AS IN (SELECT strTransactionId FROM #tmpTransactions)

END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
GO
