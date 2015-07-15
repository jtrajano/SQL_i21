CREATE PROCEDURE [dbo].[uspGLUpdateAPAccountCategory]
AS
DECLARE @intLength INT
DECLARE @apLength INT
DECLARE @strPad NVARCHAR(5)
DECLARE @intPrimary	INT
DECLARE @strMask NVARCHAR(3)

SELECT @intPrimary =intAccountStructureId,@strMask = strMask, @intLength = intLength FROM tblGLAccountStructure WHERE strType = 'Primary'

DECLARE @tblAP TABLE(strCOde NVARCHAR(10) COLLATE Latin1_General_CI_AS)

INSERT INTO @tblAP	SELECT CONVERT(NVARCHAR(10), CONVERT(NUMERIC, apcbk_gl_ap)) from apcbkmst
SELECT TOP 1 @apLength = LEN(strCOde) from @tblAP

IF @intLength > @apLength
BEGIN
	UPDATE @tblAP SET strCOde = strCOde +  REPLICATE(@strMask, @intLength - @apLength)
END
DECLARE @intPayablesGroup  INT
DECLARE @intPayablesCategory INT
DECLARE @intLiabilityGroup INT

SELECT @intLiabilityGroup = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Liability'
SELECT @intPayablesGroup = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Payables'
SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'

IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountSegment A INNER JOIN @tblAP B ON A.strCode = B.strCOde WHERE A.intAccountGroupId = @intLiabilityGroup)
BEGIN
	UPDATE A SET intAccountGroupId = @intPayablesGroup,	intAccountCategoryId = @intPayablesCategory
	FROM tblGLAccountSegment A INNER JOIN @tblAP B ON A.strCode = B.strCOde 
	INNER JOIN tblGLAccountStructure C ON A.intAccountStructureId = C.intAccountStructureId AND C.intAccountStructureId = @intPrimary
	WHERE A.intAccountGroupId = @intLiabilityGroup
	
	UPDATE A SET intAccountCategoryId = @intPayablesCategory , intAccountGroupId = @intPayablesGroup
	FROM tblGLAccount A 
	INNER JOIN tblGLAccountSegmentMapping B ON A.intAccountId = B.intAccountId
	INNER JOIN tblGLAccountSegment C ON B.intAccountSegmentId = C.intAccountSegmentId
	INNER JOIN @tblAP D ON C.strCode = D.strCOde
	INNER JOIN tblGLAccountStructure E ON C.intAccountStructureId = E.intAccountStructureId AND E.intAccountStructureId = @intPrimary
	WHERE A.intAccountGroupId = @intLiabilityGroup
END



