CREATE FUNCTION [dbo].[fnCTConvertYNToBit]
(
	@strValue AS NVARCHAR(50),
	@ysnRetFalseIfNull BIT = 0
)
RETURNS BIT

AS 
BEGIN
	DECLARE @ysnValue BIT
		
	IF LTRIM(RTRIM(@strValue)) = 'Y'
		SET @ysnValue = 1
	ELSE IF LTRIM(RTRIM(@strValue)) = 'N'
		SET @ysnValue = 0
	ELSE
		IF @ysnRetFalseIfNull = 1
			SET @ysnValue = 0
		ELSE
			SET @ysnValue = NULL

	RETURN	@ysnValue	
END
