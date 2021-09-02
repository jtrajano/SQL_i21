CREATE FUNCTION [dbo].[fnCronDayOfWeek]
(
  @ysnSunday BIT = NULL
  ,@ysnMonday BIT = NULL
  ,@ysnTuesday BIT = NULL 
  ,@ysnWednesday BIT = NULL
  ,@ysnThursday BIT = NULL 
  ,@ysnFriday BIT = NULL 
  ,@ysnSaturday BIT = NULL 
)
RETURNS NVARCHAR(20)
BEGIN 
	DECLARE @dayOfWeek AS NVARCHAR(20) = '?'

	IF (@ysnSunday = 1 OR @ysnMonday = 1 OR @ysnTuesday = 1 OR @ysnWednesday = 1 OR @ysnThursday = 1 OR @ysnFriday = 1 OR @ysnSaturday = 1)
	AND NOT (@ysnSunday = 1 AND @ysnMonday = 1 AND @ysnTuesday = 1 AND @ysnWednesday = 1 AND @ysnThursday = 1 AND @ysnFriday = 1 AND @ysnSaturday = 1)
	BEGIN 
		SET @dayOfWeek = ''
		IF @ysnSunday = 1 SET @dayOfWeek = '0,'
		IF @ysnMonday = 1 SET @dayOfWeek += '1,' 
		IF @ysnTuesday = 1 SET @dayOfWeek += '2,'
		IF @ysnWednesday = 1 SET @dayOfWeek += '3,' 
		IF @ysnThursday = 1 SET @dayOfWeek += '4,' 
		IF @ysnFriday = 1 SET @dayOfWeek += '5,' 
		IF @ysnSaturday = 1 SET @dayOfWeek += '6,' 

		SET @dayOfWeek = REVERSE(@dayOfWeek) 
		SET @dayOfWeek = SUBSTRING(@dayOfWeek, 2, LEN(@dayOfWeek) - 1) 
		SET @dayOfWeek = REVERSE(@dayOfWeek) 		
	END 
	 
	RETURN @dayOfWeek
END 