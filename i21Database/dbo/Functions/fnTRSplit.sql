CREATE FUNCTION [dbo].fnTRSplit (
      @InputString                  VARCHAR(max),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      Item   VARCHAR(max) COLLATE Latin1_General_CI_AS
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','



      DECLARE @Item                 VARCHAR(max) 
      DECLARE @ItemList       VARCHAR(max)
      DECLARE @DelimIndex     INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)

          
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END 

      IF @Item IS NOT NULL 
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END

      
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END 
GO
