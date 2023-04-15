
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

	-- +++++ INSERT ACCOUNT Id +++++ --
	INSERT INTO tblGLAccount ([strAccountId],[strDescription],[intAccountGroupId], [intAccountUnitId],[ysnSystem],[ysnActive],intCurrencyID)
		SELECT strAccountId,
			   strDescription,
			   intAccountGroupId,
			   intAccountUnitId,
			   ysnSystem,
			   ysnActive,
			   @intCurrencyId
		FROM tblGLTempAccount
		WHERE intUserId = @intUserId and strAccountId NOT IN (SELECT strAccountId FROM tblGLAccount)	
		ORDER BY strAccountId

	-- +++++ DELETE LEGACY COA TABLE AT 1st BUILD +++++ --
	--IF NOT EXISTS(SELECT 1 FROM tblGLCOACrossReference)
	--      BEGIN
	--          IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst_bak]') AND type IN (N'U'))
	--              DROP TABLE glactmst_bak
	--          SELECT * INTO glactmst_bak FROM glactmst
	--          DELETE FROM glactmst
	--      END
	--      IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst_bak]') AND type IN (N'U'))
	--      	SELECT * INTO glactmst_bak FROM glactmst

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

	