CREATE FUNCTION [dbo].[fnIsDiscountPastDue]
(
	@termId INT,
	@date DATETIME,
	@transactionDate DATETIME
)
RETURNS BIT
AS
BEGIN
	DECLARE @pastDue BIT = 0;
	DECLARE @discountDay INT;
	DECLARE @daysDiff INT;

	SELECT TOP 1
		@discountDay = term.intDiscountDay
	FROM tblSMTerm term
	WHERE term.intTermID = @termId

	SET @daysDiff = DATEDIFF(DAY, @transactionDate, @date);

	SET @pastDue = CASE WHEN (@daysDiff > @discountDay) THEN 1 ELSE 0 END

	RETURN @pastDue;
END
