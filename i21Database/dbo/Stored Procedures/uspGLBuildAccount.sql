﻿
	CREATE PROCEDURE  [dbo].[uspGLBuildAccount]
			@intUserId INT,
			@intCurrencyId INT = 0
	AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON

	-- +++++ INSERT ACCOUNT Id +++++ --
	IF @intCurrencyId = 0
		SELECT TOP 1 @intCurrencyId=intDefaultCurrencyId FROM tblSMCompanyPreference A JOIN tblSMCurrency B on A.intDefaultCurrencyId = B.intCurrencyID
	IF ISNULL(@intCurrencyId, 0)= 0
	BEGIN
		RAISERROR('Functional Currency is not setup properly. Please set it up in Company Configuration Screen.', 16, 1);
	END
	DECLARE  @tblAccount  TABLE ( strAccountId NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL )
	
	INSERT INTO @tblAccount (strAccountId)
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
		FROM tblGLTempAccount A JOIN @tblAccount B ON A.strAccountId = B.strAccountId
		ORDER BY A.strAccountId


	DECLARE @_intAccountId INT , @_strAccountId NVARCHAR(50),@changeDescription NVARCHAR(100)
	WHILE EXISTS (SELECT 1 FROM  @tblAccount )
	BEGIN
		SELECT TOP 1 @_intAccountId=intAccountId, @_strAccountId = A.strAccountId FROM tblGLAccount A 
		JOIN @tblAccount B ON A.strAccountId = B.strAccountId WHERE A.strAccountId = B.strAccountId

		set @changeDescription =N'Build Account ' + @_strAccountId 
		
			EXEC uspSMAuditLog
			@keyValue = @_intAccountId,                                          -- Primary Key Value
			@screenName = 'GeneralLedger.view.EditAccount',            -- Screen Namespace
			@entityId = @intUserId,                                              -- Entity Id.
			@actionType = 'Build',              
			@changeDescription = @changeDescription,
			@fromValue = '',
			@toValue = @_strAccountId
                                
		DELETE FROM @tblAccount WHERE strAccountId = @_strAccountId
	END

	
	-- +++++ INSERT CROSS REFERENCE +++++ --
	IF (select SUM(intLength) from tblGLAccountStructure where strType = 'Segment') <= 8
	BEGIN
		INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
		SELECT (SELECT intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				B.strAccountId as stri21Id,
				CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50))  + '.' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strExternalId , 	   
				B.strPrimary + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strCurrentExternalId,
				'Legacy' as strCompanyId,
				1
		FROM tblGLTempAccount B
		WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference WHERE strCompanyId='Legacy')	
		ORDER BY strAccountId
	END
	ELSE
	BEGIN
		-- HANDLE OUT OF STANDARD ACCOUNT STRUCTURE (e.i REPowell)
		INSERT INTO tblGLCOACrossReference ([inti21Id],[stri21Id],[strExternalId], [strCurrentExternalId], [strCompanyId], [intConcurrencyId])
		SELECT (SELECT intAccountId FROM tblGLAccount A WHERE A.strAccountId = B.strAccountId) as inti21Id,
				B.strAccountId as stri21Id,
				CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort)) + '.' + 
					REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = 'Segment' order by intSort))) +  
					SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) as strExternalId , 	   								
				CAST(CAST(B.strPrimary AS INT) AS NVARCHAR(50)) + SUBSTRING(B.strSegment,0,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort)) + '-' + 
					REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment' and intAccountStructureId <> (select TOP 1 intAccountStructureId from tblGLAccountStructure where strType = 'Segment' order by intSort))) +  
					SUBSTRING(B.strSegment,(select TOP 1 intLength + 1 from tblGLAccountStructure where strType = 'Segment'  order by intSort),(select SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) as strCurrentExternalId,
				'Legacy' as [strCompanyIdFrom],
				1
		FROM tblGLTempAccount B
		WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT stri21Id FROM tblGLCOACrossReference where strCompanyId = 'Legacy')	
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
			IF PATINDEX('%;%',@segmentcodes) > 0
			BEGIN
				SET @segmentId = SUBSTRING(@segmentcodes, 0, PATINDEX('%;%',@segmentcodes))
			
				INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@accountId, @segmentId)
				UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)

				SET @segmentcodes = SUBSTRING(@segmentcodes, LEN(@segmentId + ';') + 1, LEN(@segmentcodes))
			END
			ELSE
			BEGIN
				SET @segmentId = @segmentcodes
				SET @segmentcodes = NULL
			
				INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@accountId, @segmentId)
				UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountSegment WHERE intAccountSegmentId = @segmentId)
					
			END		
			DELETE FROM tblGLTempAccount WHERE cntId = @Id
		END
	END


	--DELETE FROM tblGLTempAccount WHERE intUserId = @intUserId
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
		EXEC uspGLAccountOriginSync @intUserId

	EXEC uspGLBuildTempCOASegment