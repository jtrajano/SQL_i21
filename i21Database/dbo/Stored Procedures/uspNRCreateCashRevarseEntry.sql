CREATE PROCEDURE [dbo].[uspNRCreateCashRevarseEntry]
@intNoteTransId Int
AS
BEGIN

	DECLARE @strParam NVARCHAR(MAX), @strCheckNumber nvarchar(100), @dblTransAmount decimal(18,6), @intNotePaymentId Int, @userId Int
	, @intEntityId int, @intNoteId int, @strTransactionId nvarchar(50)
	SELECT @strCheckNumber = strCheckNumber, @dblTransAmount = dblTransAmount, @userId = intLastModifiedUserId , @intNoteId = intNoteId
	FROM dbo.tblNRNoteTransaction Where intNoteTransId = @intNoteTransId
	SELECT @strParam = strTransComments FROM dbo.tblNRNoteTransaction Where strCheckNumber = @strCheckNumber AND intNoteTransTypeId = 4 AND dblTransAmount = (@dblTransAmount * (-1))
	
	SELECT @intEntityId = C.[intEntityId]	
		From dbo.tblNRNote N
		JOIN dbo.tblARCustomer C On N.intCustomerId = C.[intEntityId]
		Where N.intNoteId = @intNoteId
		
	--SET @strParam = '1,2,3,4,5'
	
		-- Creating the temp table:       
	DECLARE  @tblNRCMBankTransaction TABLE(rownum int identity(1,1), strTransactionId NVARCHAR(40)) 

	--INSERT INTO #tmpPostBillData 
	INSERT INTO @tblNRCMBankTransaction
	SELECT * FROM [dbo].fnSplitString(@strParam, ',')
	
		-- Get the number of rows in the looping table
	DECLARE @RowCount INT
	SET @RowCount = (SELECT COUNT(strTransactionId) FROM @tblNRCMBankTransaction) 


	-- Declare an iterator
	DECLARE @I INT
	-- Initialize the iterator
	SET @I = 1


	-- Loop through the rows of a table @myTable
	WHILE (@I <= @RowCount)
	BEGIN
		Select @strTransactionId = strTransactionId From @tblNRCMBankTransaction Where rownum = @I
	
		DECLARE @ysnPost Bit, @ysnRecap Bit, @isSuccessful Bit, @message_id int
		SET @ysnPost = 0 --for Unpost	1 Post, 
		SET @ysnRecap = 0 -- Recap
		EXEC dbo.uspCMPostBankDeposit @ysnPost, @ysnRecap, @strTransactionId, NULL, @userId, @intEntityId, @isSuccessful, @message_id
	
		SET @I = @I + 1

	END

	
END