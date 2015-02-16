CREATE PROCEDURE [dbo].[uspNRCreateCashRevarseEntry]
@intNoteTransId Int
AS
BEGIN

	DECLARE @strParam NVARCHAR(MAX), @strCheckNumber nvarchar(100), @dblTransAmount decimal(18,6), @intNotePaymentId Int, @userId Int
	SELECT @strCheckNumber = strCheckNumber, @dblTransAmount = dblTransAmount, @userId = intLastModifiedUserId FROM dbo.tblNRNoteTransaction Where intNoteTransId = @intNoteTransId
	SELECT @strParam = strTransComments FROM dbo.tblNRNoteTransaction Where strCheckNumber = @strCheckNumber AND intNoteTransTypeId = 4 AND dblTransAmount = @dblTransAmount
	--SET @strParam = '1,2,3,4,5'

	If @strParam = ''
		Return

	DECLARE @isSuccessful BIT
	       
	-- Creating the temp table:       
	CREATE TABLE #tmpCMBankTransaction (
	strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
	UNIQUE (strTransactionId))

	--INSERT INTO #tmpPostBillData 
	INSERT INTO #tmpCMBankTransaction
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@strParam)

	--select * from #tmpCMBankTransaction
	-- Calling the stored procedure
	EXEC uspCMBankTransactionReversal @userId, @isSuccessful OUTPUT


END