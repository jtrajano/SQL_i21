CREATE PROCEDURE usp_GLBuildTempCOASegment
	
AS
BEGIN
	--CREATE DYNAMIC ACCOUNT STRUCTURE
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tempDASTable') DROP TABLE tempDASTable 
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment') DROP TABLE tblGLTempCOASegment
	BEGIN
			DECLARE @Segments NVARCHAR(MAX)
			SELECT @Segments = ISNULL(SUBSTRING((SELECT '],[' + strStructureName FROM tblGLAccountStructure WHERE strType <> 'Divider' FOR XML PATH('')),3,200000) + ']','[Primary Account]')
			DECLARE @Query NVARCHAR(MAX)
			SET @Query = 
			'SELECT A.intAccountID, DAS.* INTO tblGLTempCOASegment FROM tblGLAccount A
			INNER JOIN (
			 SELECT *  FROM (
			   SELECT DISTINCT
			   A.strAccountID 
			   ,C.strCode
			   ,D.strStructureName
				from tblGLAccount A INNER JOIN tblGLAccountSegmentMapping B 
				  ON A.intAccountID = B.intAccountID
			   INNER JOIN tblGLAccountSegment C
				ON B.intAccountSegmentID = C.intAccountSegmentID
			   INNER JOIN  tblGLAccountStructure D 
				ON C.intAccountStructureID = D.intAccountStructureID
			  ) AS tempTable
			 PIVOT
			 (
			 MIN(strCode)
			 FOR strStructureName IN (' + @Segments + ')) AS PVT
			 ) AS DAS
			ON A.strAccountID = DAS.strAccountID
			'
			
			EXEC sp_executesql @Query
	END
			
			
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyu_GLDetailView') DROP VIEW vyu_GLDetailView
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment')
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyu_GLDetailView]
		AS
		SELECT		A.intGLDetailID, A.dtmDate, A.strBatchID, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strDescription AS GLDescription, A.strCode, 
					A.strTransactionID, A.strReference, A.strNum, A.ysnIsUnposted, A.intUserID, A.strTransactionForm, A.strUOMCode,             
					C.strAccountGroup, C.strAccountType, D.*            
		FROM         dbo.tblGLDetail AS A 
						INNER JOIN dbo.tblGLAccount AS B ON B.intAccountID = A.intAccountID 
						INNER JOIN dbo.tblGLAccountGroup AS C ON C.intAccountGroupID = B.intAccountGroupID
						LEFT JOIN dbo.tblGLTempCOASegment AS D ON D.intAccountID = B.intAccountID')
	END

	
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyu_GLAccountView') DROP VIEW vyu_GLAccountView
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment')
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyu_GLAccountView]
		AS
		SELECT     C.*, A.strDescription, B.strAccountGroup, B.strAccountType, A.intAccountGroupID, A.ysnIsUsed, A.ysnActive, A.dblOpeningBalance, A.intAccountUnitID
		FROM		dbo.tblGLAccount AS A 
					INNER JOIN dbo.tblGLAccountGroup AS B ON B.intAccountGroupID = A.intAccountGroupID
					LEFT JOIN dbo.tblGLTempCOASegment AS C ON C.intAccountID = A.intAccountID')
	END

				
END