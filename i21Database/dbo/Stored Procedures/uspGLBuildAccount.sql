
	CREATE PROCEDURE  [dbo].[uspGLBuildAccount]
			@intUserId INT,
			@intCurrencyId INT = NULL
	AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON

	-- +++++ INSERT ACCOUNT Id +++++ --
	-- IF @intCurrencyId = 0
	-- 	SELECT TOP 1 @intCurrencyId=intDefaultCurrencyId FROM tblSMCompanyPreference A JOIN tblSMCurrency B on A.intDefaultCurrencyId = B.intCurrencyID
	-- IF ISNULL(@intCurrencyId, 0)= 0
	-- BEGIN
	-- 	RAISERROR('Functional Currency is not setup properly. Please set it up in Company Configuration Screen.', 16, 1);
	-- END
	IF @intCurrencyId = 0 SET @intCurrencyId = NULL
	
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
			@actionType = 'Created',              
			@changeDescription = @changeDescription,
			@fromValue = '',
			@toValue = @_strAccountId
                                
		DELETE FROM @tblAccount WHERE strAccountId = @_strAccountId
	END
	
	-- +++++ INSERT CROSS REFERENCE +++++ --
	DECLARE @strType NVARCHAR(20), @updateCrossReference BIT = 1
	SELECT TOP 1 @strType = strType FROM tblGLAccountStructure ORDER BY intSort -- check if primary is the first segment

	IF @strType <> 'Primary'
		SET @updateCrossReference = 0

	IF @updateCrossReference = 1 		
	BEGIN
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
	END

	EXEC uspGLInsertSegmentMappingAfterAccountBuild @intUserId

	--DELETE FROM tblGLTempAccount WHERE intUserId = @intUserId
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
		EXEC uspGLAccountOriginSync @intUserId
		
	EXEC dbo.uspGLUpdateAccountLocationId
	EXEC uspGLBuildTempCOASegment