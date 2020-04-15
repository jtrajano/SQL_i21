CREATE PROCEDURE [dbo].[uspARInsertPostResult]
	 @BatchNumber			NVARCHAR(100)
	,@TransactionType		NVARCHAR(100)
	,@Message				NVARCHAR(MAX)
	,@TransactionIDs		NVARCHAR(MAX)
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @TransactionTables AS TABLE(
	 intTransactionId INT UNIQUE
	,strTransactionNumber NVARCHAR(100)
	,strTransactionType NVARCHAR(100)
)

IF @TransactionType = 'Invoice'
	BEGIN
		INSERT INTO @TransactionTables
		SELECT
			 intInvoiceId
			,strInvoiceNumber
			,strTransactionType
		FROM
			tblARInvoice
		WHERE
			intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TransactionIDs))
	END
ELSE
	BEGIN
		INSERT INTO @TransactionTables
		SELECT
			 intPaymentId 
			,strRecordNumber
			,'Receive Payment'
		FROM
			tblARPayment
		WHERE
			intPaymentId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@TransactionIDs))
	END
	
WHILE EXISTS(SELECT TOP 1 NULL FROM @TransactionTables)
	BEGIN
		DECLARE @TransactionId INT
				,@TransactionNumber NVARCHAR(100)
				,@Type NVARCHAR(100)
				
		SELECT TOP 1
			 @TransactionId		= intTransactionId 
			,@TransactionNumber	= strTransactionNumber
			,@Type				= strTransactionType
		FROM
			@TransactionTables
			
		INSERT INTO [tblARPostResult](
			 [strMessage]
			,[strTransactionType]
			,[strTransactionId]
			,[strBatchNumber]
			,[intTransactionId]
			,[intConcurrencyId]
		)
		SELECT
			 [strMessage]			= @Message
			,[strTransactionType]	= @Type
			,[strTransactionId]		= @TransactionNumber
			,[strBatchNumber]		= @BatchNumber
			,[intTransactionId]		= @TransactionId
			,[intConcurrencyId]		= 0

		DELETE 
		FROM tblARPostingQueue
		WHERE intTransactionId = @TransactionId
		  AND strTransactionNumber = @TransactionNumber
			
		DELETE FROM @TransactionTables WHERE intTransactionId = @TransactionId
	END
    
END          
