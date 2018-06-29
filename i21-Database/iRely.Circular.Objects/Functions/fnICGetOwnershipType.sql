CREATE FUNCTION fnICGetOwnershipType(@intOwnershipType INT)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @strOwnershipType AS NVARCHAR(50);

	SET @strOwnershipType = 
		CASE 
			WHEN @intOwnershipType = 2 THEN 'Storage'
			WHEN @intOwnershipType = 3 THEN 'Consigned Purchase'
			ELSE 'Own'
	END

	RETURN @strOwnershipType;
END