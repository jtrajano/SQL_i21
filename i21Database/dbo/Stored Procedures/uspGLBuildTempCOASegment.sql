CREATE PROCEDURE [dbo].[uspGLBuildTempCOASegment]
	
AS
BEGIN
	--CREATE DYNAMIC ACCOUNT STRUCTURE
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tempDASTable') 
	BEGIN 
		EXEC ('DROP TABLE tempDASTable ');
	END

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment') 
	BEGIN 
		EXEC ('DROP TABLE tblGLTempCOASegment');
	END 

	BEGIN
	PRINT 'Begin updating of Account Structure to Location'
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure)
	BEGIN
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (1, N'Primary Account', N'Primary', 5, N'0', 0, 1, 1, 4, NULL, NULL)
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (2, N'Hypen/Separator', N'Divider', 1, N'-', 1, 0, 1, 0, NULL, NULL)
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (3, N'Location', N'Segment', 4, N'0', 2, 1, 1, 5, NULL, NULL)
	END
	ELSE
	BEGIN	
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = N'Segment' and (strStructureName = N'Location' OR strStructureName LIKE N'Profit Center%'))
		BEGIN
			INSERT tblGLAccountStructure ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (3, N'Location', N'Segment', 4, N'0', 2, 1, 1, 5, NULL, NULL)
			PRINT 'No Location and Profit Center segment. Inserted Location Segment'
		END
		ELSE
		BEGIN
		
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType  = N'Segment' and strStructureName = N'Location')
			BEGIN
				UPDATE tblGLAccountStructure SET strStructureName = 'Location' WHERE  intAccountStructureId = (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment')
				PRINT 'Updated Profit Center Segment to Location'
			END
			ELSE
				PRINT 'Location Segment is already existing. No update needed'
		END
	END
	PRINT 'End updating of Account Structure to Location'		



			DECLARE @Segments NVARCHAR(MAX)
			SELECT @Segments = ISNULL(SUBSTRING((SELECT '],[' + strStructureName FROM tblGLAccountStructure WHERE strType <> 'Divider' FOR XML PATH('')),3,200000) + ']','[Primary Account]')
			DECLARE @Query NVARCHAR(MAX)
			SET @Query = 
			'SELECT A.intAccountId, DAS.* INTO tblGLTempCOASegment FROM tblGLAccount A
			INNER JOIN (
			 SELECT *  FROM (
			   SELECT DISTINCT
			   A.strAccountId 
			   ,C.strCode
			   ,D.strStructureName
				from tblGLAccount A INNER JOIN tblGLAccountSegmentMapping B 
				  ON A.intAccountId = B.intAccountId
			   INNER JOIN tblGLAccountSegment C
				ON B.intAccountSegmentId = C.intAccountSegmentId
			   INNER JOIN  tblGLAccountStructure D 
				ON C.intAccountStructureId = D.intAccountStructureId
			  ) AS tempTable
			 PIVOT
			 (
			 MIN(strCode)
			 FOR strStructureName IN (' + @Segments + ')) AS PVT
			 ) AS DAS
			ON A.strAccountId = DAS.strAccountId
			'
			
			EXEC sp_executesql @Query
	END
			
			
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuGLDetailView') 
	BEGIN 
		EXEC ('DROP VIEW vyuGLDetailView');
	END 

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment')
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyuGLDetailView]
		AS
		SELECT		A.intGLDetailId, A.dtmDate, A.strBatchId, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strDescription AS GLDescription, A.strCode, 
					A.strTransactionId, A.strReference, A.ysnIsUnposted, A.intUserId, A.intEntityId, A.strTransactionForm, B.strDescription, C.strAccountGroup, C.strAccountType, D.*, E.strUOMCode, E.dblLbsPerUnit            
		FROM         dbo.tblGLDetail AS A 
						INNER JOIN dbo.tblGLAccount AS B ON B.intAccountId = A.intAccountId 
						INNER JOIN dbo.tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
						LEFT JOIN dbo.tblGLTempCOASegment AS D ON D.intAccountId = B.intAccountId
						LEFT JOIN dbo.tblGLAccountUnit AS E ON E.intAccountUnitId = B.intAccountUnitId')
	END

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuGLSummary') 
	BEGIN 
		EXEC ('DROP VIEW vyuGLSummary');
	END 

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment')
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyuGLSummary]
		AS
		SELECT		A.dtmDate, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strCode, B.strDescription, C.strAccountGroup, C.strAccountType, D.*, E.strUOMCode, E.dblLbsPerUnit            
		FROM         dbo.tblGLSummary AS A 
						INNER JOIN dbo.tblGLAccount AS B ON B.intAccountId = A.intAccountId 
						INNER JOIN dbo.tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId
						LEFT JOIN dbo.tblGLTempCOASegment AS D ON D.intAccountId = B.intAccountId
						LEFT JOIN dbo.tblGLAccountUnit AS E ON E.intAccountUnitId = B.intAccountUnitId')
	END

	
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuGLAccountView') 
	BEGIN 
		EXEC ('DROP VIEW vyuGLAccountView');
	END 

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment')
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyuGLAccountView]
		AS
		SELECT     C.*, A.strDescription, B.strAccountGroup, B.strAccountType, A.intAccountGroupId, A.ysnIsUsed, A.ysnActive, A.dblOpeningBalance, A.intAccountUnitId
		FROM		dbo.tblGLAccount AS A 
					INNER JOIN dbo.tblGLAccountGroup AS B ON B.intAccountGroupId = A.intAccountGroupId
					LEFT JOIN dbo.tblGLTempCOASegment AS C ON C.intAccountId = A.intAccountId')
	END

				
END