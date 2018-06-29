CREATE FUNCTION [dbo].[fnAPGetVoucherPrepayType]()
RETURNS @tblResult TABLE ( intId INT,  strText NVARCHAR(50))
AS
BEGIN

	-- Add the SELECT statement with parameter references here
	INSERT INTO @tblResult
	SELECT 1 , 'Standard' UNION
	SELECT 2 , 'Unit' UNION
	SELECT 3 , 'Percentage'
	RETURN;
END

GO

