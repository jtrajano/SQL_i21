CREATE FUNCTION [dbo].[fnGetInterestBasedOnTerm]
(
	@transactionAmount	DECIMAL(18,6),
	@transactionDate	DATETIME,
	@dateToCompute		DATETIME,
	@termId				INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @interest DECIMAL(18,6) = 0.00;
	DECLARE @interestPercentage DECIMAL(18,6);
	DECLARE @isDue BIT = 0;
	DECLARE @monthDue INT;
	DECLARE @dueDate DATETIME;
	
	SET @isDue = dbo.fnIsDue(@transactionDate, @dateToCompute, @termId);

	IF @isDue = 1 
	BEGIN
		--GET the APR
		SELECT @interestPercentage = ISNULL(dblAPR,0) FROM tblSMTerm WHERE intTermID = @termId;
		--Compute the interest as APR (Annual Percentage Rate)
		SET @dueDate = dbo.fnGetDueDateBasedOnTerm(@transactionDate, @termId);
		--Determine the number of months where transaction is due
		SET @monthDue = DATEDIFF(MONTH, @dueDate, @dateToCompute);

		SET @interestPercentage = ((@interestPercentage / 100) / 12) * @monthDue;
		SET @interest = CAST((@transactionAmount * @interestPercentage) AS DECIMAL(18,2))
	END

	RETURN @interest;
END
