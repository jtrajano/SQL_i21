CREATE FUNCTION [dbo].[fnEMSplitWithGetByIdx]
(
	@Input			NVARCHAR(MAX),
	@Character		CHAR(1),
	@Index			INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @StartIndex INT, @EndIndex INT
	DECLARE @CurIndex INT
	DECLARE @Ret NVARCHAR(MAX)
	SET @CurIndex = 1
    SET @StartIndex = 1

	DECLARE @Output TABLE
	(
		Item		NVARCHAR(1000),
		idx			INT IDENTITY(1,1)
	)


    IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
    BEGIN
        SET @Input = @Input + @Character
    END
	
    WHILE CHARINDEX(@Character, @Input) > 0
    BEGIN
        SET @EndIndex = CHARINDEX(@Character, @Input)
        INSERT INTO @Output(Item)
        SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
        SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
    END
		
	SELECT @Ret = Item FROM @Output where idx = @Index 
	
	
	RETURN @Ret     
END
