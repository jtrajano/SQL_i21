/*
	Remove the a set of chars from the right side of the string. 
	Ex:

	dbo.fnRTrim('199.9900', '0') will result to '199.99'.  

*/

CREATE FUNCTION fnRTrim(@String VARCHAR(MAX), @Char VARCHAR(1))
RETURNS VARCHAR(MAX)
BEGIN
  RETURN REVERSE(
			SUBSTRING(
				REVERSE(@String)
				,PATINDEX(
					'%[^' + @Char + ']%'
					,REVERSE(@String)
				)
				,DATALENGTH(@String)
			)
		)
END