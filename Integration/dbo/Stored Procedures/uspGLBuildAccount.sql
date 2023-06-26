GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLBuildAccount'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLBuildAccount];
	')

	EXEC('
		CREATE PROCEDURE  [dbo].[uspGLBuildAccount]
			@intUserId INT,
			@intCurrencyId INT = NULL
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON

		-- +++++ INSERT ACCOUNT Id +++++ --
		IF @intCurrencyId = 0 SET @intCurrencyId = NULL


		DECLARE @tblAuditLogAccount  TABLE ( strAccountId NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL )
		
		INSERT INTO @tblAuditLogAccount (strAccountId)
		SELECT strAccountId
		FROM tblGLTempAccount
			WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT strAccountId FROM tblGLAccount)	
			ORDER BY strAccountId


		-- +++++ INSERT ACCOUNT Id +++++ --
		INSERT INTO tblGLAccount ([strAccountId],[strDescription],[intAccountGroupId], [intAccountUnitId],[ysnSystem],[ysnActive],intCurrencyID)
			SELECT A.strAccountId,
				strDescription,
				intAccountGroupId,
				intAccountUnitId,
				ysnSystem,
				ysnActive,
				@intCurrencyId
		FROM tblGLTempAccount A JOIN @tblAuditLogAccount B ON A.strAccountId = B.strAccountId
		ORDER BY A.strAccountId


		DECLARE @_intAccountId NVARCHAR(50) , @_strAccountId NVARCHAR(50),@changeDescription NVARCHAR(100)
		WHILE EXISTS (SELECT 1 FROM  @tblAuditLogAccount )
		BEGIN
			SELECT TOP 1 @_intAccountId=CAST(intAccountId AS NVARCHAR(50)), @_strAccountId = A.strAccountId FROM tblGLAccount A 
			JOIN @tblAuditLogAccount B ON A.strAccountId = B.strAccountId WHERE A.strAccountId = B.strAccountId
			SET @changeDescription =N''Build Account '' + @_strAccountId 
			EXEC uspSMAuditLog
			@keyValue = @_intAccountId,                                          -- Primary Key Value
			@screenName = ''GeneralLedger.view.EditAccount'',            -- Screen Namespace
			@entityId = @intUserId,                                              -- Entity Id.
			@actionType = ''Build'',                   
			@changeDescription = @changeDescription,
			@fromValue = '''',
			@toValue = @_strAccountId

			DELETE FROM @tblAuditLogAccount WHERE strAccountId = @_strAccountId
		END
	
		-- +++++ DELETE LEGACY COA TABLE AT 1st BUILD +++++ --
		IF NOT EXISTS(SELECT 1 FROM tblGLCOACrossReference WHERE strCompanyId = ''Legacy'')
        BEGIN
            IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[glactmst_bak]'') AND type IN (N''U''))
                DROP TABLE glactmst_bak
            SELECT * INTO glactmst_bak FROM glactmst
            DELETE FROM glactmst
        END
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[glactmst_bak]'') AND type IN (N''U''))
        	SELECT * INTO glactmst_bak FROM glactmst

		-- +++++ INSERT CROSS REFERENCE +++++ --
		IF (select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'') <= 8
		BEGIN
			INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
			SELECT (SELECT TOP 1 intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				   B.strAccountId as stri21Id,
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50))  + ''.'' + REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) + B.strSegment as strExternalId , 	   
				   B.strPrimary + ''-'' + REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) + B.strSegment as strCurrentExternalId,
				   ''Legacy'' as strCompanyId,
				   1
			FROM tblGLTempAccount B
			WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference WHERE strCompanyId = ''Legacy'')	
			ORDER BY strAccountId
		END
		ELSE
		BEGIN
			-- HANDLE OUT OF STANDARD ACCOUNT STRUCTURE (e.i REPowell)
			INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
			SELECT (SELECT TOP 1 intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				   B.strAccountId as stri21Id,
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort)) + ''.'' + 
						REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Segment'' order by intSort))) +  
						SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) as strExternalId , 	   								
				   CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort)) + ''-'' + 
						REPLICATE(''0'',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = ''Segment'' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Segment'' order by intSort))) +  
						SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = ''Segment''  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')) as strCurrentExternalId,
				   ''Legacy'' as strCompanyId,
				   1
			FROM tblGLTempAccount B
			WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference WHERE strCompanyId = ''Legacy'')	
			ORDER BY strAccountId
		END

		DECLARE @tblAccount TABLE (intAccountId INT)

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
					UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)

					SET @segmentcodes = SUBSTRING(@segmentcodes, LEN(@segmentId + '';'') + 1, LEN(@segmentcodes))
				END
				ELSE
				BEGIN
					SET @segmentId = @segmentcodes
					SET @segmentcodes = NULL
			
					INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@accountId, @segmentId)
					UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)
					
				END
				
				INSERT INTO @tblAccount Values(@accountId)

				DELETE FROM tblGLTempAccount WHERE cntId = @Id
			END
		END


		EXEC dbo.uspGLUpdateAccountLocationId
		EXEC uspGLAccountOriginSync @intUserId
		EXEC dbo.uspGLInsertOriginCrossReferenceMapping

		UPDATE account
		SET account.strOldAccountId = cref.strOldAccountId
		FROM tblGLAccount account 
		JOIN @tblAccount temp ON temp.intAccountId = account.intAccountId
		CROSS APPLY (
			SELECT TOP 1 intDefaultVisibleOldAccountSystemId FROM tblGLCompanyPreferenceOption
		)pref
		CROSS APPLY(
			SELECT TOP 1 strOldAccountId FROM tblGLCrossReferenceMapping WHERE intAccountId = account.intAccountId
			AND intAccountSystemId = pref.intDefaultVisibleOldAccountSystemId
			AND ysnInbound = 1
		)cref


		EXEC uspGLBuildTempCOASegment
	')
END