GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPMoveToPayables')
	DROP PROCEDURE uspAPMoveToPayables
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
		EXEC ('
				CREATE PROCEDURE [dbo].[uspAPMoveToPayables]
				AS
				BEGIN

					UPDATE sgmnt
					SET intAccountGroupId = (SELECT top 1 intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = ''Payables'')
					FROM tblGLAccountSegment sgmnt
					INNER JOIN 
					(
					SELECT DISTINCT
						A.apcbk_gl_ap
						,B.inti21Id
						,C.intAccountGroupId
						,D.strCode
					FROM apcbkmst A
						INNER JOIN tblGLCOACrossReference B ON A.apcbk_gl_ap = B.strExternalId
						INNER JOIN tblGLAccount C ON B.inti21Id = C.intAccountId
						INNER JOIN tblGLAccountSegment D ON C.intAccountGroupId = D.intAccountGroupId
					) originAPAccount ON sgmnt.strCode = originAPAccount.strCode
					AND intAccountStructureId = (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Primary'')

					UPDATE A
					  SET A.intAccountGroupId = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountGroup = ''Payables'')
					FROM tblGLAccount A
					INNER JOIN 
					(
					SELECT DISTINCT
						A.apcbk_gl_ap
						,B.inti21Id
						,C.intAccountGroupId
						,D.strCode
					FROM apcbkmst A
						INNER JOIN tblGLCOACrossReference B ON A.apcbk_gl_ap = B.strExternalId
						INNER JOIN tblGLAccount C ON B.inti21Id = C.intAccountId
						INNER JOIN tblGLAccountSegment D ON C.intAccountGroupId = D.intAccountGroupId
					) originAPAccount ON A.intAccountId = originAPAccount.inti21Id

				END
				')
END
