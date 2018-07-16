/*
	This function holds all the sql-related error message under Inventory module. 
	By passing an id, it will return the string value of the error messsage. 

	This is used in conjunction with uspICRaiseError. 
*/
CREATE FUNCTION fnICFormatErrorMessage (
  @msgIdOrString SQL_VARIANT,
  @p1 SQL_VARIANT = null,
  @p2 SQL_VARIANT = null,
  @p3 SQL_VARIANT = null,
  @p4 SQL_VARIANT = null,
  @p5 SQL_VARIANT = null,
  @p6 SQL_VARIANT = null,
  @p7 SQL_VARIANT = null,
  @p8 SQL_VARIANT = null,
  @p9 SQL_VARIANT = null,
  @p10 SQL_VARIANT = null
)
RETURNS NVARCHAR(MAX) 
AS 
BEGIN 
	DECLARE @msgString NVARCHAR(MAX)
			, @msgId INT 
			, @pos INT
			, @pId INT 
	DECLARE @p SQL_VARIANT
			,@value NVARCHAR(MAX) 
	
	SELECT @msgId = CASE WHEN SQL_VARIANT_PROPERTY(@msgIdOrString, 'BaseType') = 'int' THEN CAST(@msgIdOrString AS INT) ELSE NULL END 
	
	IF SQL_VARIANT_PROPERTY(@msgIdOrString, 'BaseType') = 'int' 
	BEGIN 
		SET @msgId = CAST(@msgIdOrString AS INT)
		SELECT @msgString = dbo.fnICGetErrorMessage(@msgId) 
	END 
	ELSE 
	BEGIN 
		SET @msgString = COALESCE(@msgString, CAST(@msgIdOrString AS NVARCHAR(MAX))) 
	END 

	SET @pos = 0	
	SET @pos = CHARINDEX('%', @msgString, @pos)
	SET @pId = 1 
	WHILE (@pId <= 10)
	BEGIN 
		SET @pos = CHARINDEX('%', @msgString, @pos)
	
		SELECT @p = 
			CASE	WHEN @pId = 1 THEN @p1 
					WHEN @pId = 2 THEN @p2 
					WHEN @pId = 3 THEN @p3
					WHEN @pId = 4 THEN @p4 
					WHEN @pId = 5 THEN @p5 
					WHEN @pId = 6 THEN @p6 
					WHEN @pId = 7 THEN @p7 
					WHEN @pId = 8 THEN @p8 
					WHEN @pId = 9 THEN @p9 
					WHEN @pId = 10 THEN @p10 
			end 

		SET @value = NULL 
		SELECT @value = 
			CASE 
				WHEN SUBSTRING(@msgString, @pos, 2) = '%i' THEN 
					CAST(COALESCE(CAST(@p AS INT),'<null>') AS NVARCHAR(20)) 
				WHEN SUBSTRING(@msgString, @pos, 2) = '%s' THEN 
					COALESCE(CAST(@p AS NVARCHAR(MAX)),'<null>')
				WHEN SUBSTRING(@msgString, @pos, 2) = '%d' THEN 
					COALESCE(CONVERT(NVARCHAR(30), CAST(@p AS DATETIME), 101),'<null>')
				WHEN SUBSTRING(@msgString, @pos, 2) = '%f' THEN 
					COALESCE (							
						CASE 
							WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 2) = 0 THEN 'zero' 
							WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 2) > 0.01 THEN CONVERT(NVARCHAR, CAST(@p AS MONEY), 1) -- Format the float value as two decimal. 
							WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 6) < 0.000001 THEN REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(38, 20)) AS NVARCHAR(50)), '0', ' ')), ' ' , '0') -- Format the float value as 20 decimal. 
							ELSE REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(18, 6)) AS NVARCHAR(50)) , '0', ' ')), ' ', '0') -- Format the float value as 6 decimal. 
						END 
						,'<null>'
					)					
			END 
		WHERE @pos > 0
				
		SELECT @msgString = 
			CASE 
				WHEN @value IS NOT NULL THEN 
					STUFF(@msgString, @pos, 2, @value) 
				ELSE 
					@msgString
			END 
		
		SET @pos = @pos + LEN(ISNULL(@value, 0)) 
		SET @pId += 1 	
	END 
		
	RETURN @msgString
END 