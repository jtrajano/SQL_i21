CREATE FUNCTION [dbo].[fnIsDue]
(
	@transactionDate	DATETIME,
	@dateToCompute		DATETIME,
	@termId				INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @isDue BIT = 0;
	DECLARE @dueDate DATETIME;
	
	SET @dueDate = dbo.fnGetDueDateBasedOnTerm(@transactionDate, @termId);

	IF @dateToCompute >= @dueDate SET @isDue = 1;

	RETURN @isDue;
END
