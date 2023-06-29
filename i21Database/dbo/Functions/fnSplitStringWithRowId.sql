
/*
fnSplitString: This ia a genric function for splitting the string with any delimiter into a table of string field.
Eg. @Input = 'abc, S78, jk5L, 8900'
    @Character = ','

	Will return a table as shown below
	|Item	|
	|-------|
	|abc    |
	|S78	|
	|jk5L	|
	|8900	|
	
	You can use any delimeter insetad of "," such as "|", ":", ";", etc.
*/

CREATE FUNCTION [dbo].[fnSplitStringWithRowId]
(
	@Input NVARCHAR(MAX),
    @Character CHAR(1)
)
RETURNS @Output TABLE
(
    RowId SMALLINT IDENTITY(1,1),
	Item NVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS
)
AS
BEGIN
	DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
   
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
            INSERT INTO @Output(Item)
            SELECT LTRIM(RTRIM(SUBSTRING(@Input, @StartIndex, @EndIndex - 1)))
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END
