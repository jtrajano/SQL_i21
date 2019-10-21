CREATE PROCEDURE [dbo].[uspAPGetStartingNumber]
	-- Add the parameters for the stored procedure here
	@intTransactionType int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @RC int
	DECLARE @intStartingNumberId int
	DECLARE @strID nvarchar(40)
	DECLARE @intCompanyLocationId int = null

	DECLARE @strTransactionType NVARCHAR(30)
	SELECT @strTransactionType =
		CASE WHEN @intTransactionType = 1 THEN 'Bill'
			 WHEN @intTransactionType = 2 THEN 'Vendor Prepayment' 
			 WHEN @intTransactionType = 3 THEN 'Debit Memo'
			 WHEN @intTransactionType = 9 THEN '1099 Adjustment' 
			 WHEN @intTransactionType = 11 THEN 'Claim' 
			 WHEN @intTransactionType = 13 THEN 'Basis Advance' 
		ELSE ''
		END


	SELECT TOP 1 @intStartingNumberId= intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = @strTransactionType
	

	EXECUTE @RC = [dbo].[uspSMGetStartingNumber] 
		@intStartingNumberId
		,@strID OUTPUT
		,@intCompanyLocationId
	
	SELECT @strID

END

