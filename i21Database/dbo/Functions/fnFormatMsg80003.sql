
/**
* This function will format the company location name, sub location, and storage location names on error message 80003. 
* 
*/
CREATE FUNCTION fnFormatMsg80003 (@intItemLocationId AS INT, @intSubLocationId AS INT, @intStorageLocationId AS INT)
RETURNS NVARCHAR(2000)
AS
BEGIN 
	DECLARE @intCompanyLocationId AS INT
			,@CompanyLocationName AS NVARCHAR(50)
			,@SubLocationName AS NVARCHAR(50)
			,@StorageLocationName AS NVARCHAR(50)
			,@ReturnValue AS NVARCHAR(2000)


	SELECT	@CompanyLocationName = tblSMCompanyLocation.strLocationName 
			,@intCompanyLocationId = tblSMCompanyLocation.intCompanyLocationId
	FROM	dbo.tblICItemLocation INNER JOIN dbo.tblSMCompanyLocation 
				ON tblICItemLocation.intLocationId = tblSMCompanyLocation.intCompanyLocationId
	WHERE	tblICItemLocation.intItemLocationId = @intItemLocationId

	SELECT	@SubLocationName = strSubLocationName
	FROM	dbo.tblSMCompanyLocationSubLocation
	WHERE	intCompanyLocationSubLocationId = @intSubLocationId
	
	SELECT	@StorageLocationName = strName
	FROM	dbo.tblICStorageLocation
	WHERE	intStorageLocationId = @intStorageLocationId

	SELECT	@ReturnValue = 
				CASE	WHEN RTRIM(LTRIM(@CompanyLocationName)) = '' THEN 
							'(Company id: ' + CAST(@intCompanyLocationId AS NVARCHAR(50)) + ')'
						ELSE 
							@CompanyLocationName 
				
				END
				+ CASE	WHEN @SubLocationName IS NULL THEN 
							'' 						
						WHEN @SubLocationName IS NOT NULL AND @StorageLocationName IS NULL THEN 
							' and ' + @SubLocationName 
						ELSE 
							', ' + @SubLocationName 
				
				END
				+ CASE	WHEN @StorageLocationName IS NULL THEN 
							'' 						
						ELSE  
							', and ' + @StorageLocationName
				
				END
	WHERE	@CompanyLocationName IS NOT NULL 

	RETURN @ReturnValue;
END 


GO