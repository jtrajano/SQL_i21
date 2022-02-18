CREATE FUNCTION dbo.fnICIsUpcExists2(
	@strLongUPCCode AS NVARCHAR(50)
	,@intItemUOMId AS INT
	,@intModifier AS INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnExists BIT = 0

	IF  (@strLongUPCCode IS NULL OR LTRIM(RTRIM(@strLongUPCCode)) = '') 
		OR @intItemUOMId IS NULL 
	BEGIN 
		RETURN @ysnExists;
	END

	DECLARE @intUpcCode AS BIGINT 
	SET @intUpcCode = 
			CASE 
				WHEN 
					@strLongUPCCode IS NOT NULL 
					AND ISNUMERIC(RTRIM(LTRIM(@strLongUPCCode))) = 1 
					AND NOT (@strLongUPCCode LIKE '%.%' OR @strLongUPCCode LIKE '%e%' OR @strLongUPCCode LIKE '%E%') 
				THEN 				
					CAST(RTRIM(LTRIM(@strLongUPCCode)) AS BIGINT) 
				ELSE 
					CAST(NULL AS BIGINT) 
			END

	IF EXISTS (
		SELECT TOP 1 1 
		FROM tblICItemUOM 
		WHERE 
			(
				strLongUPCCode = @strLongUPCCode 
				OR intUpcCode = @intUpcCode
			)
			AND intModifier = @intModifier
			AND intItemUOMId <> @intItemUOMId
			AND strLongUPCCode IS NOT NULL 
	)
	BEGIN 
		SET @ysnExists = 1
	END 

	RETURN @ysnExists; 	
END 
