CREATE PROCEDURE [dbo].[uspMFGetErrorMessage]
(
	@intMessageId	INT
  , @p1				SQL_VARIANT = null
  , @p2				SQL_VARIANT = null
  , @p3				SQL_VARIANT = null
  , @p4				SQL_VARIANT = null
  , @p5				SQL_VARIANT = null
  , @p6				SQL_VARIANT = null
  , @p7				SQL_VARIANT = null
  , @p8				SQL_VARIANT = null
  , @p9				SQL_VARIANT = null
  ,	@p10			SQL_VARIANT = null
)
/****************************************************************
	Title: Manufacturing Error Messages (Staging)
	Description: This was created to have a flexible and standard error message format similar to Inventory Module.
	JIRA: MFG-5093
	Created By: Jonathan Valenzuela
	Date: 07/04/2023
*****************************************************************/
AS 
BEGIN
	DECLARE @strMessage NVARCHAR(MAX)

	
	DECLARE @msgString NVARCHAR(MAX)
			, @pos INT
			, @pId INT 
	DECLARE @p SQL_VARIANT
			,@value NVARCHAR(MAX) 
	
	
	SET @msgString = dbo.fnMFGetErrorMessage(@intMessageId); 
	
	/* Retrieve and Build Error Message */
	SET @pos = 0	
	SET @pos = CHARINDEX('%', @msgString, @pos)
	SET @pId = 1 

	WHILE (@pId <= 10)
		BEGIN 
			SET @pos = CHARINDEX('%', @msgString, @pos);
	
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

			SELECT @value = CASE WHEN SUBSTRING(@msgString, @pos, 2) = '%i' THEN CAST(COALESCE(CAST(@p AS INT),'<null>') AS NVARCHAR(20)) 
								 WHEN SUBSTRING(@msgString, @pos, 2) = '%s' THEN COALESCE(CAST(@p AS NVARCHAR(MAX)),'<null>')
								 WHEN SUBSTRING(@msgString, @pos, 2) = '%d' THEN COALESCE(CONVERT(NVARCHAR(30), CAST(@p AS DATETIME), 101),'<null>')
								 WHEN SUBSTRING(@msgString, @pos, 2) = '%f' THEN COALESCE (CASE WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 2) = 0 THEN 'zero' 
																								WHEN ABS(ROUND(CAST(@p AS NUMERIC(18, 6)), 2)) > 0.01 THEN CONVERT(NVARCHAR, CAST(@p AS MONEY), 1) -- Format the float value as two decimal. 
																								WHEN ABS(ROUND(CAST(@p AS NUMERIC(18, 6)), 6)) < 0.000001 THEN REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(38, 20)) AS NVARCHAR(50)), '0', ' ')), ' ' , '0') -- Format the float value as 20 decimal. 
																								ELSE REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(18, 6)) AS NVARCHAR(50)) , '0', ' ')), ' ', '0') -- Format the float value as 6 decimal. 
																						   END, '<null>')					
							END 
			WHERE @pos > 0
				
			SELECT @msgString = CASE WHEN @value IS NOT NULL THEN STUFF(@msgString, @pos, 2, @value) 
									 ELSE @msgString
								END 
		
			SET @pos = @pos + LEN(ISNULL(@value, 0)) 

			SET @pId += 1 	
		END 

	SET @strMessage = REPLACE(@msgString, '%', '%%')

	RAISERROR(@strMessage, 11, 1);
END