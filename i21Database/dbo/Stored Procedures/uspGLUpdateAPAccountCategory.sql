--GL-3191 
CREATE PROCEDURE [dbo].[uspGLUpdateAPAccountCategory]
AS
DECLARE @intLength INT
DECLARE @apLength INT
DECLARE @strPad NVARCHAR(5)
DECLARE @intPrimary	INT
DECLARE @strMask NVARCHAR(3)

SELECT @intPrimary =intAccountStructureId,@strMask = strMask, @intLength = intLength FROM tblGLAccountStructure WHERE strType = 'Primary'

DECLARE @tblAP TABLE(strCode NVARCHAR(50) COLLATE Latin1_General_CI_AS)

INSERT INTO @tblAP	
SELECT SUBSTRING(CAST(apcbk_gl_ap as NVARCHAR(50)),0, CHARINDEX('.', apcbk_gl_ap))
FROM apcbkmst

SELECT TOP 1 @apLength = LEN(strCode) from @tblAP

IF @intLength > @apLength
BEGIN
	UPDATE @tblAP SET strCode = strCode +  REPLICATE(@strMask, @intLength - @apLength)
END
DECLARE @intPayablesGroup  INT
DECLARE @intPayablesCategory INT
DECLARE @intLiabilityGroup INT

SELECT @intLiabilityGroup = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Liability'
--SELECT @intPayablesGroup = intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = 'Payables'
SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'

UPDATE 
	Segment 
SET 
	--intAccountGroupId = @intPayablesGroup,	
	intAccountCategoryId = @intPayablesCategory
FROM 
	tblGLAccountSegment Segment 
	JOIN @tblAP B ON Segment.strCode = B.strCode 
	JOIN tblGLAccountStructure C ON Segment.intAccountStructureId = C.intAccountStructureId 
WHERE 
	Segment.intAccountGroupId = @intLiabilityGroup AND C.intAccountStructureId = @intPrimary

--UPDATE 
--	Account
--SET 
--	intAccountGroupId = @intPayablesGroup
--FROM 
--	tblGLAccount Account
--	JOIN tblGLCOACrossReference COA ON Account.intAccountId  = inti21Id
--	JOIN apcbkmst E ON E.apcbk_gl_ap = COA.strExternalId



