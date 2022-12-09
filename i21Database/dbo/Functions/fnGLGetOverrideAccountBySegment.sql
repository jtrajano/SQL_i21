CREATE FUNCTION fnGLGetOverrideAccountBySegment
(
    @intAccountId INT,
    @intLocationSegmentId INT = NULL, -- used to override
    @intLOBSegmentId INT = NULL, -- used to override
    @intCompanySegmentId INT = NULL
    
) -- will be overriden      
RETURNS NVARCHAR(40)
AS
BEGIN
DECLARE @ysnOverrideLocation BIT = 1, @ysnOverrideLOB BIT = 1, @ysnOverrideCompany BIT = 1,
@strAccountId  NVARCHAR(40)

SELECT @strAccountId = strAccountId FROM tblGLAccount WHERE intAccountId = @intAccountId

IF ISNULL(@intLocationSegmentId,0) = 0 SET @ysnOverrideLocation = 0
IF ISNULL(@intLOBSegmentId,0) = 0 SET @ysnOverrideLOB = 0
IF ISNULL(@intCompanySegmentId,0) = 0 SET @ysnOverrideCompany = 0

WHILE @ysnOverrideLocation = 1
    OR @ysnOverrideLOB  =1 
    OR @ysnOverrideCompany =1

    BEGIN

        DECLARE @intStart INT
        , @intEnd INT
        , @intLength INT
        , @intDividerCount INT
        , @strSegment NVARCHAR(10) 
        , @intStructureType INT
        , @intAccountSegmentId INT


        IF @ysnOverrideLocation =1
		BEGIN
           SET @intStructureType = 3
		   SET @ysnOverrideLocation = 0
           SET @intAccountSegmentId = @intLocationSegmentId
		END
		ELSE
        
        IF @ysnOverrideLOB =1 
		BEGIN
           SET @intStructureType = 5
		   SET  @ysnOverrideLOB = 0
           SET @intAccountSegmentId = @intLOBSegmentId
		END
		ELSE

        IF @ysnOverrideCompany =1 
          	BEGIN
           SET @intStructureType = 6
		   SET  @ysnOverrideCompany = 0
           SET @intAccountSegmentId = @intCompanySegmentId
		END
        

        SELECT TOP 1 
        @strSegment =  strCode
        FROM tblGLAccountSegment A JOIN tblGLAccountStructure B 
        ON A.intAccountStructureId = B.intAccountStructureId
        WHERE intStructureType = @intStructureType 
        AND intAccountSegmentId= @intAccountSegmentId

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
            if @i > @intStart and @i <= @intEnd
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
    END

    RETURN @str
END
