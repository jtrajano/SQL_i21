CREATE FUNCTION dbo.fnICIsUpcExists(
	@strLongUPCCode AS NVARCHAR(50)
	,@intItemUOMId AS INT 
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnExists BIT = 0

	IF  (@strLongUPCCode COLLATE Latin1_General_CI_AS IS NULL OR LTRIM(RTRIM(@strLongUPCCode COLLATE Latin1_General_CI_AS)) = '') 
		OR @intItemUOMId IS NULL 
	BEGIN 
		RETURN @ysnExists;
	END

	DECLARE @intUpcCode AS BIGINT 
	SET @intUpcCode = 
			CASE 
				WHEN 
					@strLongUPCCode COLLATE Latin1_General_CI_AS IS NOT NULL 
					AND ISNUMERIC(RTRIM(LTRIM(@strLongUPCCode COLLATE Latin1_General_CI_AS))) = 1 
					AND NOT (@strLongUPCCode COLLATE Latin1_General_CI_AS LIKE '%.%' OR @strLongUPCCode COLLATE Latin1_General_CI_AS LIKE '%e%' OR @strLongUPCCode COLLATE Latin1_General_CI_AS LIKE '%E%') 
				THEN 				
					CAST(RTRIM(LTRIM(@strLongUPCCode COLLATE Latin1_General_CI_AS)) AS BIGINT) 
				ELSE 
					CAST(NULL AS BIGINT) 
			END

	IF EXISTS (
		SELECT TOP 1 1 
		FROM tblICItemUOM 
		WHERE 
			(
				strLongUPCCode = @strLongUPCCode COLLATE Latin1_General_CI_AS
				OR intUpcCode = @intUpcCode
			)
			AND intItemUOMId <> @intItemUOMId
			AND strLongUPCCode COLLATE Latin1_General_CI_AS IS NOT NULL 
	)
	BEGIN 
		SET @ysnExists = 1
	END 

	RETURN @ysnExists; 	
END 
