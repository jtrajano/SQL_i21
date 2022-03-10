CREATE FUNCTION fnCMOverrideARRevalueAccounts
 (
     @PostGLEntries RecapTableType READONLY
 )
RETURNS 
 @tbl TABLE(
    intId int IDENTITY(1,1),
    intOverrideLocationAccountId INT,
    intOverrideLOBAccountId INT,
    intOrigAccountId INT,
    intNewGLAccountId INT NULL,
    strMessage NVARCHAR(MAX),
     strOverrideLocationAccountId NVARCHAR(40),
     strOverrideLOBAccountId NVARCHAR(40),
     strOrigAccountId NVARCHAR(40),
    ysnOverriden BIT
)
AS
BEGIN

DECLARE @ysnHasLOB BIT
SELECT @ysnHasLOB = 1 FROM tblGLAccountStructure A join tblGLSegmentType B on A.intStructureType = B.intSegmentTypeId 
    WHERE B.strSegmentType = 'Line Of Business'

IF NOT EXISTS (SELECT 1 FROM @PostGLEntries WHERE intOverrideLocationAccountId IS NOT NULL AND (intOverrideLOBAccountId IS NOT NULL AND @ysnHasLOB = 1))
    RETURN

INSERT INTO @tbl (intOverrideLocationAccountId,intOverrideLOBAccountId,intOrigAccountId, ysnOverriden, strOverrideLocationAccountId,strOverrideLOBAccountId,strOrigAccountId )
SELECT intOverrideLocationAccountId,intOverrideLOBAccountId,intAccountId , 0,
X.strAccountId,CASE WHEN @ysnHasLOB =1 THEN Y.strAccountId ELSE '' END,Z.strAccountId
FROM @PostGLEntries A
 OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intOverrideLocationAccountId
    ) X
        OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intOverrideLOBAccountId
    ) Y
        OUTER APPLY(
        SELECT TOP 1 strAccountId from tblGLAccount WHERE intAccountId = A.intAccountId
    ) Z
 WHERE intOverrideLocationAccountId IS NOT NULL AND (intOverrideLOBAccountId IS NOT NULL AND @ysnHasLOB = 1)
GROUP BY intOverrideLocationAccountId, intOverrideLOBAccountId,intAccountId, X.strAccountId, Y.strAccountId, Z.strAccountId

DECLARE @strMessage NVARCHAR(MAX)=''
DECLARE @intId INT,@strOverrideLocationAccountId NVARCHAR(30),@strOverrideLOBAccountId NVARCHAR(30), @strOrigAccountId NVARCHAR(30), @newStrAccountId NVARCHAR(30),
@intOverrideLocationAccountId INT, @intOverrideLOBAccountId INT, @intOrigAccountId INT
WHILE EXISTS (SELECT 1 FROM @tbl WHERE ysnOverriden = 0)
BEGIN
    SELECT TOP 1 
    @intId=intId,
    @strOverrideLocationAccountId = strOverrideLocationAccountId,
    @strOverrideLOBAccountId=strOverrideLocationAccountId,
    @strOrigAccountId = strOrigAccountId ,
    @intOverrideLocationAccountId = A.intOverrideLocationAccountId,
    @intOverrideLOBAccountId = A.intOverrideLOBAccountId,
    @intOrigAccountId= A.intOrigAccountId
    FROM @tbl A
    WHERE ysnOverriden =0

    SELECT @newStrAccountId= dbo.fnGLGetOverrideAccount(3,@strOverrideLocationAccountId,@strOrigAccountId)

    IF @newStrAccountId IS NULL 
        UPDATE @tbl SET strMessage = 'Error overriding ' + @strOrigAccountId + ' using ' + @strOverrideLocationAccountId , ysnOverriden = 1
              WHERE intId = @intId
    ELSE
    BEGIN
        IF @ysnHasLOB = 1 AND @newStrAccountId IS NOT NULL
            SELECT @newStrAccountId= dbo.fnGLGetOverrideAccount(5,@strOverrideLOBAccountId,@newStrAccountId)
        
        IF @newStrAccountId IS NULL
             UPDATE @tbl SET strMessage = 'Error overriding ' + @strOrigAccountId + ' using ' + @strOverrideLOBAccountId , ysnOverriden = 1
              WHERE intId = @intId
    END

    IF NOT EXISTS(SELECT 1 FROM tblGLAccount WHERE strAccountId = @newStrAccountId)
    BEGIN
        UPDATE @tbl SET strMessage = @newStrAccountId + ' is not an existing Account Id for override', ysnOverriden = 1   WHERE intId = @intId
        
    END
    ELSE
    BEGIN
        IF @strMessage <> ''
            UPDATE @tbl SET intNewGLAccountId =  (SELECT intAccountId from tblGLAccount WHERE strAccountId = @newStrAccountId),
            ysnOverriden = 1 
            WHERE intId = @intId
    END
END

RETURN

END
