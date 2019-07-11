﻿CREATE FUNCTION [dbo].[fnGetInterestBasedOnTerm]
(
	@transactionAmount	DECIMAL(18,6),
	@transactionDate	DATETIME,
	@dateToCompute		DATETIME,
	@lastDateInterest	DATETIME = NULL,
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
	DECLARE @daysDue INT = 0;
	DECLARE @year AS INT = YEAR(GETDATE())
	DECLARE @lastInterestDateApplied DATETIME = @lastDateInterest;
	DECLARE @daysInYear INT;

	--handle leap year
	SELECT @daysInYear =  DATEDIFF(d,CAST(CONCAT('01/01/',@year) AS DATETIME),CAST(CONCAT('12/31/',@year) AS DATETIME) + 1)

	SET @isDue = dbo.fnIsDue(@transactionDate, @dateToCompute, @termId);

	IF @isDue = 1 
	BEGIN
		--GET the APR
		SELECT @interestPercentage = ISNULL(dblAPR,0) FROM tblSMTerm WHERE intTermID = @termId;
		--Compute the interest as APR (Annual Percentage Rate)
		SET @dueDate = dbo.fnGetDueDateBasedOnTerm(@transactionDate, @termId);
		SET @daysDue = DATEDIFF(DAY, ISNULL(@lastInterestDateApplied,@dueDate), @dateToCompute);
		--Determine the number of months where transaction is due
		-- SET @monthDue = DATEDIFF(MONTH, @dueDate, @dateToCompute);
		-- IF @monthDue = 0
		-- BEGIN
		-- 	SET @daysDue = DATEDIFF(DAY, @dueDate, @dateToCompute);
		-- 	IF @daysDue > 0 SET @monthDue = 1
		-- END
		SET @interestPercentage = ((@interestPercentage / 100) / @daysInYear) * @daysDue;
		SET @interest = CAST((@transactionAmount * @interestPercentage) AS DECIMAL(18,2));
	END

	RETURN @interest;
END
