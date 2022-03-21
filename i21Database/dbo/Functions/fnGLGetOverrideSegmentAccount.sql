CREATE FUNCTION fnGLGetOverrideSegmentAccount(
    @intAccountSegmentId INT, -- used to override
    @strAccountId  NVARCHAR(40)) -- will be overriden      
RETURNS NVARCHAR(40)
AS
BEGIN

        DECLARE @intStart INT
        , @intEnd INT
        , @intLength INT
        , @intDividerCount INT
        , @strSegment NVARCHAR(10) 
        , @intStructureType INT

        SELECT TOP 1 
        @strSegment =  strCode,
        @intStructureType = intStructureType
        FROM tblGLAccountSegment A JOIN tblGLAccountStructure B 
        ON A.intAccountStructureId = B.intAccountStructureId
        WHERE intAccountSegmentId = @intAccountSegmentId 

        SELECT @intDividerCount = COUNT(1)  FROM tblGLAccountStructure 
        WHERE strType <> 'Divider' and intStructureType < @intStructureType

        SELECT @intStart = SUM(intLength) + @intDividerCount FROM tblGLAccountStructure 
        WHERE strType <> 'Divider' and intStructureType < @intStructureType -- location

        SELECT @intLength = intLength FROM tblGLAccountStructure WHERE intStructureType = @intStructureType -- lob
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

        RETURN @str
END
