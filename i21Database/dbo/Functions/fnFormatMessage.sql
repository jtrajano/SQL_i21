/*
	This function is similar to FORMATMESSAGE except it only formats from the provided string. 

	fnFormatMessage ( { ' msg_string ' } , [ param_value [ ,...n ] ] )  

	It edits the provided string by substituting the supplied parameter values. 
	Keywords for substitution are the following: 

	%s - replaces a string. 
	%i - replaces an integer value. 
	%d - replaces a date value. 
	%f - replaces a float value. 

	Up to 10 parameters for substitution are supported. 

	NOTE: FORMATMESSAGE('msg_string') does NOT work on SQL2008R2 and lower. This function will fill-in that gap. 
*/

CREATE FUNCTION [dbo].[fnFormatMessage]
(
  @msg NVARCHAR(MAX),
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
RETURNS NVARCHAR(2000)
BEGIN 
	DECLARE @pos INT
			, @pId INT 

	DECLARE @p SQL_VARIANT

	SET @pos = 0	
	SET @pos = CHARINDEX('%', @msg, @pos)
	SET @pId = 1 
	WHILE (@pId <= 10)
	BEGIN 
		SET @pos = CHARINDEX('%', @msg, @pos)
	
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

		SELECT @msg = 
			CASE 
				WHEN @pos > 0 AND SUBSTRING(@msg, @pos, 2) = '%i' THEN 
					STUFF(@msg, @pos, 2, COALESCE(CAST(@p AS INT),'<null>')) 
				WHEN @pos > 0 AND SUBSTRING(@msg, @pos, 2) = '%s' THEN 
					STUFF(@msg, @pos, 2, COALESCE(CAST(@p AS NVARCHAR(MAX)),'<null>')) 
				WHEN @pos > 0 AND SUBSTRING(@msg, @pos, 2) = '%d' THEN 
					STUFF(@msg, @pos, 2, COALESCE(CONVERT(NVARCHAR(30), CAST(@p AS DATETIME), 101),'<null>')) 
				WHEN @pos > 0 AND SUBSTRING(@msg, @pos, 2) = '%f' THEN 
					STUFF(
						@msg
						, @pos
						, 2
						, COALESCE (							
							CASE 
								WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 2) > 0.01 THEN CONVERT(NVARCHAR, CAST(@p AS MONEY), 1) -- Format the float value as two decimal. 
								WHEN ROUND(CAST(@p AS NUMERIC(18, 6)), 6) < 0.000001 THEN REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(38, 20)) AS NVARCHAR(50)), '0', ' ')), ' ' , '0') -- Format the float value as 20 decimal. 
								ELSE REPLACE(RTRIM(REPLACE(CAST(CAST(@p AS NUMERIC(18, 6)) AS NVARCHAR(50)) , '0', ' ')), ' ', '0') -- Format the float value as 6 decimal. 
							END 
							,'<null>'
						)
					) 
				ELSE 
					@msg
			END 
				
		SET @pId += 1 
	END 

	RETURN CAST(@msg AS NVARCHAR(2000)); 
END 