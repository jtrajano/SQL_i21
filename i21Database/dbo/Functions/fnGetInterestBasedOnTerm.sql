CREATE FUNCTION [dbo].[fnGetInterestBasedOnTerm]
(
	@transactionAmount	DECIMAL(18,6),
	@transactionDate	DATETIME,
	@dateToCompute		DATETIME,
	@termId				INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @interest DECIMAL(18,6) = 0.00;
	DECLARE @interestPercentage DECIMAL(18,6);
	DECLARE @isDue BIT = 0;
	SELECT @interestPercentage = ISNULL(dblAPR,0) FROM tblSMTerm WHERE intTermID = @termId;

	SET @isDue = dbo.fnIsDue(@transactionDate, @dateToCompute, @termId);

	IF @isDue = 1 SET @interest = @transactionAmount * (@interestPercentage / 100);

	RETURN @interest;
END
