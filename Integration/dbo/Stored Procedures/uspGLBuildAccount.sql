GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLBuildAccount'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLBuildAccount];
	')

	EXEC('
		CREATE PROCEDURE  [dbo].[uspGLBuildAccount]
		@intUserId nvarchar(50)
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON

		-- +++++ INSERT ACCOUNT Id +++++ --
		INSERT INTO tblGLAccount ([strAccountId],[strDescription],[intAccountGroupId],[intAccountUnitId],[ysnSystem],[ysnActive])
		SELECT strAccountId, 
			   strDescription,
			   intAccountGroupId,
			   intAccountUnitId,
			   ysnSystem,
			   ysnActive
		FROM tblGLTempAccount
		WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT strAccountId FROM tblGLAccount)	
		ORDER BY strAccountId

		-- +++++ DELETE LEGACY COA TABLE AT 1st BUILD +++++ --
		IF NOT EXISTS(SELECT 1 FROM tblGLCOACrossReference)
		BEGIN
			DELETE glactmst	
		END

		-- +++++ INSERT CROSS REFERENCE +++++ --
		IF (select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'') <= 8
		BEGIN
			INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
			SELECT (SELECT intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				   B.strAccountId as stri21Id,
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50))  + ''.'' + REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) + B.strSegment as strExternalId , 	   
				   B.strPrimary + ''-'' + REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) + B.strSegment as strCurrentExternalId,
				   ''Legacy'' as strCompanyId,
				   1
			FROM tblGLTempAccount B
			WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference)	
			ORDER BY strAccountId
		END
		ELSE
		BEGIN
			-- HANDLE OUT OF STANDARD ACCOUNT STRUCTURE (e.i REPowell)
			INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
			SELECT (SELECT intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				   B.strAccountId as stri21Id,
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort)) + ''.'' + 
						REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Segment'' order by intSort))) +  
						SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) as strExternalId , 	   								
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort)) + ''-'' + 
						REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Segment'' order by intSort))) +  
						SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) as strCurrentExternalId,
				   ''Origin'' as strCompanyId,
				   1
			FROM tblGLTempAccount B
			WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference)	
			ORDER BY strAccountId
		END

		-- +++++ INSERT SEGMENT MAPPING +++++ --
		WHILE EXISTS(SELECT 1 FROM tblGLTempAccount WHERE intUserId = @intUserId)
		BEGIN
			Declare @Id INT = (SELECT TOP 1 cntId FROM tblGLTempAccount WHERE intUserId = @intUserId)
			Declare @segmentcodes varchar(200) = (SELECT TOP 1 strAccountSegmentId FROM tblGLTempAccount WHERE intUserId = @intUserId)
			Declare @segmentId varchar(200) = null
			Declare @accountId INT = (SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = (SELECT TOP 1 strAccountId FROM tblGLTempAccount WHERE intUserId = @intUserId))

			WHILE LEN(@segmentcodes) > 0
			BEGIN
				IF PATINDEX(''%;%'',@segmentcodes) > 0
				BEGIN
					SET @segmentId = SUBSTRING(@segmentcodes, 0, PATINDEX(''%;%'',@segmentcodes))
			
					INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@accountId, @segmentId)
					UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentId = @segmentId
					UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)

					SET @segmentcodes = SUBSTRING(@segmentcodes, LEN(@segmentId + '';'') + 1, LEN(@segmentcodes))
				END
				ELSE
				BEGIN
					SET @segmentId = @segmentcodes
					SET @segmentcodes = NULL
			
					INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@accountId, @segmentId)
					UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentId = @segmentId
					UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)
					
				END
		
				DELETE FROM tblGLTempAccount WHERE cntId = @Id
			END
		END


		DELETE FROM tblGLTempAccount WHERE intUserId = @intUserId

		EXEC uspGLAccountOriginSync @intUserId
		EXEC uspGLBuildTempCOASegment
	')
END