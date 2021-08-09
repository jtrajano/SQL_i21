
CREATE PROCEDURE uspCMGetRPAccountIdByLocation
(
	@intAccountId int,
	@strLocationSegment NVARCHAR(40),
	@intAccountIdNew INT OUT,
	@strError NVARCHAR(MAX) OUT
)
AS

DECLARE @intStructCount INT
SELECT @intStructCount = COUNT(*) FROM tblGLAccountStructure
DECLARE @tblAccountId TABLE (strAccountId NVARCHAR(40)) 
DECLARE @strAccountIdNew nvarchar(40)

IF @intStructCount = 3
	INSERT INTO @tblAccountId EXEC ('select  [Primary Account]  + ''-'' + ' + '  ''' + @strLocationSegment +  '''  FROM tblGLTempCOASegment where intAccountId =' + @intAccountId )
IF @intStructCount = 4
	INSERT INTO @tblAccountId EXEC ('select  [Primary Account]  + ''-'' + ' + '  ''' + @strLocationSegment +  '''  + ''-'' + LOB FROM tblGLTempCOASegment where intAccountId =' + @intAccountId )

SELECT TOP 1 @strAccountIdNew = strAccountId FROM @tblAccountId

DECLARE @strAccountCategory NVARCHAR(40)

SELECT TOP  1 @intAccountIdNew =intAccountId,    @strAccountCategory = strAccountCategory FROM vyuGLAccountDetail 
WHERE strAccountId = @strAccountIdNew --AND strAccountCategory in  ('General', 'Sales Tax Account', 'Sales Account'))

IF @intAccountIdNew IS NULL
	SET @strError = @strAccountIdNew +  ' is not yet built as a GL Account'
ELSE
	IF @strAccountCategory NOT IN ('General', 'Sales Tax Account', 'Sales Account')
		SET @strError = @strAccountIdNew +  ' is not in valid category'






