CREATE PROCEDURE [dbo].[uspARDeleteRecurrence]
	 @TransactionId		AS INT
	,@TransactionNumber	AS NVARCHAR(100)
	,@TransactionType	AS NVARCHAR(100)
	,@UserId			AS INT
	,@IsSucessfull		AS BIT		= NULL OUTPUT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


SET @IsSucessfull = 0;


DELETE 
FROM
	[tblSMRecurringTransaction]
WHERE
		[intTransactionId] = @TransactionId
	AND [strTransactionType] = @TransactionType
	AND [strTransactionNumber] = @TransactionNumber
	
	
SET @IsSucessfull = 1;

RETURN 1

END