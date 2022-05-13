CREATE FUNCTION [dbo].[fnGLGetOverrideAccountBySegment2]
(
    @intAccountId INT,
    @intAccountSegmentId INT
    
)    
RETURNS NVARCHAR(40)
AS
BEGIN
    DECLARE
        @strAccountId  NVARCHAR(40),
        @intStructureType INT

    SELECT @strAccountId = strAccountId FROM tblGLAccount WHERE intAccountId = @intAccountId

    DECLARE @intStart INT
    , @intEnd INT
    , @intLength INT
    , @intDividerCount INT
    , @strSegment NVARCHAR(10) 


    SELECT
        @strSegment =  strCode,
        @intStructureType = B.intStructureType
    FROM tblGLAccountSegment A
    JOIN tblGLAccountStructure B
        ON B.intAccountStructureId = A.intAccountStructureId
    WHERE intAccountSegmentId = @intAccountSegmentId

    SELECT @intDividerCount = COUNT(1)  FROM tblGLAccountStructure 
    WHERE strType <> 'Divider' and intStructureType < @intStructureType

    SELECT @intStart = SUM(intLength) + @intDividerCount FROM tblGLAccountStructure 
    WHERE strType <> 'Divider' and intStructureType < @intStructureType

    SELECT @intLength = intLength FROM tblGLAccountStructure WHERE intStructureType = @intStructureType
    SELECT @intEnd = @intStart + @intLength

        
    declare @intL int = len(@strAccountId)
    declare @str NVARCHAR(30)=''
    DECLARE @i int = 1
    WHILE @i <= @intL
    BEGIN
        if @i > @intStart and @i < @intEnd
        BEGIN
            SELECT @str+= @strSegment
            SET @i = @i + @intLength
        END
        ELSE
        BEGIN
            SELECT @str+= SUBSTRING(@strAccountId, @i, 1)
            SET @i=@i+1
        END
        
    END 

    SET @strAccountId = @str

    RETURN @str
END

