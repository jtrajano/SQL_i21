CREATE FUNCTION [dbo].[fnMonthName] (
	  @intMonth INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
	RETURN 
		CASE 
			 WHEN @intMonth = 1 THEN 'January'
			 WHEN @intMonth = 2 THEN 'February'
			 WHEN @intMonth = 3 THEN 'March'
			 WHEN @intMonth = 4 THEN 'April'
			 WHEN @intMonth = 5 THEN 'May'
			 WHEN @intMonth = 6 THEN 'June'
			 WHEN @intMonth = 7 THEN 'July'
			 WHEN @intMonth = 8 THEN 'August'
			 WHEN @intMonth = 9 THEN 'September'
			 WHEN @intMonth = 10 THEN 'October'
			 WHEN @intMonth = 11 THEN 'November'
			 WHEN @intMonth = 12 THEN 'December'
			 ELSE 
				NULL
		END 
END
