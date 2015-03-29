GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN 
	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLAccountOriginSync'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLAccountOriginSync];
	')

	EXEC('
		CREATE PROCEDURE  [dbo].[uspGLAccountOriginSync]
		@intUserId INT
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON

		-- +++++ TO TEMP TABLE +++++ --
		SELECT * INTO #TempUpdateCrossReference
		FROM tblGLCOACrossReference WHERE intLegacyReferenceId IS NULL

		-- +++++ SYNC ACCOUNTS +++++ --
		WHILE EXISTS(SELECT 1 FROM #TempUpdateCrossReference)
		BEGIN
			DECLARE @Id_update INT = (SELECT TOP 1 inti21Id FROM #TempUpdateCrossReference)
			DECLARE @ACCOUNT_update varchar(200) = (SELECT TOP 1 REPLACE(strCurrentExternalId,''-'','''') FROM #TempUpdateCrossReference WHERE inti21Id = @Id_update)
			DECLARE @TYPE_update varchar(200) = (SELECT TOP 1 strAccountType FROM tblGLAccount LEFT JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId WHERE intAccountId = @Id_update)
			DECLARE @GROUP_update varchar(200) = (SELECT TOP 1 strAccountGroup FROM tblGLAccount LEFT JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId WHERE intAccountId = @Id_update)
			DECLARE @LegacyType_update varchar(200) = ''''
			DECLARE @LegacySide_update varchar(200) = ''''
	
			IF @GROUP_update = ''Cost of Goods Sold'' or @GROUP_update = ''Sales''
				BEGIN
					SET @TYPE_update = @GROUP_update
				END
			
			IF @TYPE_update = ''Asset''
				BEGIN
					SET @LegacyType_update = ''A''
					SET @LegacySide_update = ''D''
				END
			ELSE IF @TYPE_update = ''Liability''
				BEGIN
					SET @LegacyType_update = ''L''
					SET @LegacySide_update = ''C''
				END
			ELSE IF @TYPE_update = ''Equity''
				BEGIN
					SET @LegacyType_update = ''Q''
					SET @LegacySide_update = ''C''
				END
			ELSE IF @TYPE_update = ''Revenue''
				BEGIN
					SET @LegacyType_update = ''I''
					SET @LegacySide_update = ''C''
				END
			ELSE IF @TYPE_update = ''Expense''
				BEGIN
					SET @LegacyType_update = ''E''
					SET @LegacySide_update = ''D''
				END
			ELSE IF @TYPE_update = ''Cost of Goods Sold''
				BEGIN
					SET @LegacyType_update = ''C''
					SET @LegacySide_update = ''D''
				END
			ELSE IF @TYPE_update = ''Sales''
				BEGIN
					SET @LegacyType_update = ''I''
					SET @LegacySide_update = ''C''
				END
		
			IF EXISTS(SELECT TOP 1 1 FROM glactmst WHERE [glact_acct1_8] = CONVERT(INT, SUBSTRING(@ACCOUNT_update,1,8)) and [glact_acct9_16] = CONVERT(INT, SUBSTRING(@ACCOUNT_update,9,16)))
			BEGIN		
				UPDATE tblGLCOACrossReference SET intLegacyReferenceId = (SELECT TOP 1 A4GLIdentity FROM glactmst WHERE [glact_acct1_8] = CONVERT(INT, SUBSTRING(@ACCOUNT_update,1,8)) and [glact_acct9_16] = CONVERT(INT, SUBSTRING(@ACCOUNT_update,9,16))) 
						WHERE inti21Id = @Id_update		
			END
			ELSE
			BEGIN
				INSERT INTO glactmst (
					[glact_acct1_8],
					[glact_acct9_16],
					[glact_desc],
					[glact_type],
					[glact_normal_value],
					[glact_saf_cat],
					[glact_flow_cat],
					[glact_uom],
					[glact_verify_flag],
					[glact_active_yn],
					[glact_sys_acct_yn],
					[glact_desc_lookup],
					[glact_user_fld_1],
					[glact_user_fld_2],
					[glact_user_id],
					[glact_user_rev_dt]
					)
				SELECT 
					CONVERT(INT, SUBSTRING(@ACCOUNT_update,1,8)),
					CONVERT(INT, SUBSTRING(@ACCOUNT_update,9,16)),						
					(CASE WHEN (SELECT TOP 1 1 FROM tblGLAccountSegment WHERE intAccountSegmentId = (select intAccountSegmentId from tblGLAccountSegmentMapping where intAccountId = @Id_update AND intAccountSegmentId IN (select intAccountSegmentId from tblGLAccountSegment where intAccountStructureId = (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Primary'')))) > 0
								THEN (SELECT TOP 1 SUBSTRING(tblGLAccountSegment.strDescription,0,30) FROM tblGLAccountSegment WHERE intAccountSegmentId = (select intAccountSegmentId from tblGLAccountSegmentMapping where intAccountId = @Id_update AND intAccountSegmentId IN (select intAccountSegmentId from tblGLAccountSegment where intAccountStructureId = (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Primary''))))
							ELSE SUBSTRING(tblGLAccount.strDescription,0,30) END) as AccountDescription,
					@LegacyType_update,
					@LegacySide_update,
					'''',
					'''',
					(SELECT TOP 1 strUOMCode FROM tblGLAccountUnit WHERE tblGLAccountUnit.intAccountUnitId = tblGLAccount.intAccountUnitId), --glact_uom
					'''',
					(CASE WHEN ysnActive = 0 THEN ''N'' ELSE ''Y'' END) as glact_active_yn,
					(CASE WHEN ysnSystem = 0 THEN ''N'' ELSE ''Y'' END) as glact_sys_acct_yn,
					(CASE WHEN (SELECT TOP 1 1 FROM tblGLAccountSegment WHERE intAccountSegmentId = (select intAccountSegmentId from tblGLAccountSegmentMapping where intAccountId = @Id_update AND intAccountSegmentId IN (select intAccountSegmentId from tblGLAccountSegment where intAccountStructureId = (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Primary'')))) > 0
								THEN (SELECT TOP 1 SUBSTRING(tblGLAccountSegment.strDescription,0,9) FROM tblGLAccountSegment WHERE intAccountSegmentId = (select intAccountSegmentId from tblGLAccountSegmentMapping where intAccountId = @Id_update AND intAccountSegmentId IN (select intAccountSegmentId from tblGLAccountSegment where intAccountStructureId = (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = ''Primary''))))
							ELSE SUBSTRING(tblGLAccount.strDescription,0,9) END) as DescriptionLookUp,
					'''',
					'''',
					@intUserId,
					CONVERT(INT, CONVERT(VARCHAR(8), GETDATE(), 112))
				FROM tblGLAccount WHERE intAccountId = @Id_update
		
				UPDATE tblGLCOACrossReference SET intLegacyReferenceId = (SELECT TOP 1 A4GLIdentity FROM glactmst ORDER BY A4GLIdentity DESC) WHERE inti21Id = @Id_update		
			END
					
			DELETE FROM #TempUpdateCrossReference WHERE inti21Id = @Id_update
		END
	')
END 