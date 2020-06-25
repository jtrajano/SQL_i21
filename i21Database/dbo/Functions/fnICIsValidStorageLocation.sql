CREATE FUNCTION dbo.fnICIsValidStorageLocation (
	@intItemLocationId INT
	,@intSubLocationId INT 
	,@intStorageLocationId INT 
)
RETURNS BIT
AS 
BEGIN
	DECLARE @isValid AS BIT = 1

	IF @intStorageLocationId IS NOT NULL 
	BEGIN 
		SELECT @isValid = 0 
		FROM
			tblICStorageLocation sl
			OUTER APPLY (
				SELECT TOP 1 
					il.intLocationId
				FROM tblICItemLocation il
				WHERE 
					il.intItemLocationId = @intItemLocationId
			) itemLocation
			OUTER APPLY (
				SELECT TOP 1 
					sub.intCompanyLocationSubLocationId
					,sub.intCompanyLocationId
				FROM tblSMCompanyLocationSubLocation sub
				WHERE 
					sub.intCompanyLocationSubLocationId = @intSubLocationId
					AND sub.intCompanyLocationId = itemLocation.intLocationId
			) subLocation

		WHERE
			sl.intStorageLocationId = @intStorageLocationId
			AND (
				(sl.intLocationId <> itemLocation.intLocationId OR itemLocation.intLocationId IS NULL) 
				OR (sl.intSubLocationId <> subLocation.intCompanyLocationSubLocationId OR subLocation.intCompanyLocationSubLocationId IS NULL) 
			)			
	END
	
	RETURN @isValid
END