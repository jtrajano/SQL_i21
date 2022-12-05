CREATE PROCEDURE [dbo].[uspGLImportCOAFromCSV]
(
	@strGUID     NVARCHAR(40),
	@intEntityId INT,
    @strVersion  NVARCHAR(100),
    @importLogId INT OUT
)
AS
	IF Object_id('tblGLCOAImportStaging2') IS NOT NULL
      DROP TABLE dbo.tblGLCOAImportStaging2

	DECLARE @tblImport TABLE
	(
		[intRowId]              INT NOT NULL,
		[strAccountPartition]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,  
		[intPartitionType]		INT NOT NULL,  
		[strPartitionGroup]		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[strRawString]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strSegmentType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
		[strError]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[intAccountSegmentId]	INT NULL
	)
	INSERT INTO @tblImport
	(
		[intRowId],
		[strAccountPartition],
		[intPartitionType],
		[strPartitionGroup],
		[strRawString],
		[strSegmentType]
	)
	SELECT 
		ROW_NUMBER() OVER (ORDER BY (select 1))
		,REPLACE(LTRIM(RTRIM([strAccountPartition])), '"', '')
		,[intPartitionType]
		,REPLACE(LTRIM(RTRIM([strPartitionGroup])), '"', '')
		,strRawString
		,ST.strSegmentType
	FROM   tblGLCOAImportStaging
	LEFT JOIN tblGLSegmentType ST
		ON ST.intSegmentTypeId = intPartitionType
	WHERE  strGUID = @strGUID

	DECLARE @strAccount NVARCHAR(40) = NULL

	CREATE TABLE tblGLCOAImportStaging2
	(
		[intAccountId]		INT NULL,
		[strAccountId]		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[intPrimarySegmentId] INT NULL,
		[intAccountUnitId]	INT NULL,
		[strDescription]	NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
		[strPartitionGroup]	NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[strError]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strRawString]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[intLineNumber]		INT NULL,
		[ysnProcessed]		BIT DEFAULT (0) NOT NULL,
		[ysnInvalid]		BIT DEFAULT (0) NOT NULL
	)
	INSERT INTO tblGLCOAImportStaging2
	(
		[intLineNumber],
		[strPartitionGroup],
		[strRawString],
		[ysnProcessed],
		[ysnInvalid]
	)
	SELECT DISTINCT
		intLineNumber,
		strPartitionGroup,
		strRawString,
		0,
		0
	FROM tblGLCOAImportStaging
	WHERE  strGUID = @strGUID
	ORDER BY intLineNumber

	DECLARE @separator NCHAR(1) = ''
	SELECT @separator = strMask
	FROM   tblGLAccountStructure
	WHERE  strType = 'Divider'

	WHILE EXISTS(SELECT TOP 1 1 FROM tblGLCOAImportStaging2 WHERE ysnProcessed = 0)
	BEGIN
		DECLARE @strGroup NVARCHAR(40)
		SELECT TOP 1 @strGroup = strPartitionGroup FROM tblGLCOAImportStaging2 WHERE ysnProcessed = 0 ORDER BY intLineNumber

		-- Validate each segment
		UPDATE A
		SET 
			A.strError = CASE WHEN AcctSeg.strCode IS NULL THEN 'Error: Missing or invalid ' + A.strSegmentType + ' Segment' ELSE NULL END,
			A.intAccountSegmentId = AcctSeg.intAccountSegmentId
		FROM @tblImport A
		LEFT JOIN tblGLAccountSegment AcctSeg
			ON AcctSeg.strCode = A.strAccountPartition
		WHERE A.strPartitionGroup = @strGroup
			AND A.intPartitionType > 0

		IF EXISTS(SELECT TOP 1 1 FROM @tblImport WHERE strPartitionGroup = @strGroup AND strError IS NOT NULL)
		BEGIN
			DECLARE @strSegmentError NVARCHAR(MAX)
			SELECT @strSegmentError = COALESCE(@strSegmentError + ' | ', '') + strError
			FROM @tblImport
			WHERE strPartitionGroup = @strGroup AND strError IS NOT NULL
			
			SELECT @strSegmentError
			UPDATE tblGLCOAImportStaging2 SET strError = @strSegmentError, ysnInvalid = 1 WHERE strPartitionGroup = @strGroup
		END
		ELSE
		BEGIN
			-- Build GL Account from partitioned segments
			DECLARE @intPrimarySegmentId INT = NULL, @strPrimarySegment NVARCHAR(20) = NULL
			SELECT @strAccount = COALESCE(@strAccount + @separator, '') + strAccountPartition FROM @tblImport WHERE strPartitionGroup = @strGroup AND intPartitionType > 0 ORDER BY intRowId
			SELECT @intPrimarySegmentId = intAccountSegmentId, @strPrimarySegment = strAccountPartition FROM @tblImport WHERE strPartitionGroup = @strGroup AND intPartitionType = 1

			-- Validate if built account already exists
			UPDATE A
			SET 
				A.strAccountId = CASE WHEN Acc.strAccountId IS NOT NULL THEN NULL ELSE @strAccount END,
				A.strError = CASE WHEN Acc.strAccountId IS NOT NULL THEN 
					CASE WHEN ISNULL(A.strError, '') = '' THEN 'Error: GL Account already exists' ELSE A.strError + ' | Error: GL Account already exists' END 
						ELSE A.strError END,
				A.intPrimarySegmentId = CASE WHEN Acc.strAccountId IS NOT NULL THEN NULL ELSE @intPrimarySegmentId END,
				A.ysnInvalid = CASE WHEN Acc.strAccountId IS NOT NULL THEN 1 ELSE 0 END
			FROM tblGLCOAImportStaging2 A
			LEFT JOIN tblGLAccount Acc
				ON Acc.strAccountId = @strAccount
			WHERE strPartitionGroup = @strGroup

			-- Get Account Description
			DECLARE @strDescription	NVARCHAR(500) = NULL
			SELECT @strDescription = strAccountPartition FROM @tblImport WHERE strPartitionGroup = @strGroup AND intPartitionType = 0
			IF (@strDescription IS NULL)
			BEGIN
				SELECT @strDescription = COALESCE(@strDescription + @separator, '') + ISNULL(AccSeg.strChartDesc, '') 
				FROM @tblImport A
				JOIN tblGLAccountSegment AccSeg
					ON AccSeg.intAccountSegmentId = A.intAccountSegmentId
				WHERE A.strPartitionGroup = @strGroup AND A.intPartitionType > 0
			END
			UPDATE tblGLCOAImportStaging2 SET strDescription = @strDescription WHERE strPartitionGroup = @strGroup
		
			-- Get Account UOM
			DECLARE @strUOM NVARCHAR(20) = NULL
			SELECT @strUOM = strAccountPartition FROM @tblImport WHERE strPartitionGroup = @strGroup AND intPartitionType = -1
			UPDATE A
			SET 
				A.intAccountUnitId = AU.intAccountUnitId,
				A.strError = CASE WHEN AU.strUOMCode IS NULL THEN
					CASE WHEN ISNULL(A.strError, '') = '' THEN 'Warning: Missing or invalid UOM Code' ELSE A.strError + ' | Warning: Missing or invalid UOM Code' END 
						ELSE A.strError END
			FROM tblGLCOAImportStaging2 A
			LEFT JOIN tblGLAccountUnit AU
				ON LOWER(AU.strUOMCode) COLLATE LATIN1_GENERAL_CI_AS =
					LOWER(RTRIM(
					LTRIM(ISNULL(@strUOM, '')))) COLLATE LATIN1_GENERAL_CI_AS
			WHERE strPartitionGroup = @strGroup

			-- Check for errors again
			IF NOT EXISTS(SELECT TOP 1 1 FROM @tblImport WHERE strPartitionGroup = @strGroup AND strError IS NOT NULL)
			BEGIN

				DECLARE @strNoPrimarySegment NVARCHAR(100)
				SELECT @strNoPrimarySegment = COALESCE(@strNoPrimarySegment, '') + strAccountPartition FROM @tblImport WHERE strPartitionGroup = @strGroup AND intPartitionType > 1

				 --Insert new account
				INSERT INTO tblGLAccount
				(
					[strAccountId]
					,[strDescription]
					,[intAccountGroupId]
					,[ysnSystem]
					,[ysnActive]
					,[intCurrencyID]
					,[intAccountUnitId]
					,[intConcurrencyId]
					,[intEntityIdLastModified]
				)
				SELECT 
					A.strAccountId
					,A.strDescription
					,SG.intAccountGroupId
					,0
					,1
					,3
					,intAccountUnitId
					,1
					,@intEntityId
				FROM   tblGLCOAImportStaging2 A
				JOIN tblGLAccountSegment SG
					ON SG.intAccountSegmentId = A.[intPrimarySegmentId]
				WHERE  A.strPartitionGroup = @strGroup AND ysnInvalid = 0

				UPDATE A
				SET A.intAccountId = B.intAccountId
				FROM tblGLCOAImportStaging2 A
				JOIN tblGLAccount B
					ON B.strAccountId = A.strAccountId
				WHERE A.strPartitionGroup = @strGroup

				-- Insert Account Segment Mapping
				INSERT INTO tblGLAccountSegmentMapping
				(
					intAccountId
					,intAccountSegmentId
					,intConcurrencyId
				)
				SELECT
					G.intAccountId
					,I.intAccountSegmentId
					,1
				FROM   @tblImport I
				JOIN tblGLCOAImportStaging2 G
					ON G.strPartitionGroup = I.strPartitionGroup
				WHERE  G.strPartitionGroup = @strGroup
					AND I.intPartitionType > 0

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType > 3)
				BEGIN
				-- Check COA Cross Reference
				INSERT INTO tblGLCOACrossReference
						([inti21Id],
						 [stri21Id],
						 [strExternalId],
						 [strCurrentExternalId],
						 [strCompanyId],
						 [intConcurrencyId])
				SELECT B.intAccountId		AS inti21Id,
				   B.strAccountId			AS stri21Id,
				   CAST(CAST(@strPrimarySegment AS INT) AS NVARCHAR(50))
				   + '.' + REPLICATE('0', (SELECT 8 - Sum(intLength) FROM
				   tblGLAccountStructure
				   WHERE strType = 'Segment'))
				   + @strNoPrimarySegment	AS strExternalId,

				   @strPrimarySegment
				   + REPLICATE('0', (SELECT 8 - Sum(intLength) FROM
				   tblGLAccountStructure
				   WHERE
				   strType = 'Segment')) + '-'
				   + REPLICATE('0', (SELECT 8 - Sum(intLength) FROM
				   tblGLAccountStructure
				   WHERE
				   strType = 'Segment'))
				   + @strNoPrimarySegment	AS strCurrentExternalId,

				   'Legacy'					AS strCompanyId,
				   1
				FROM tblGLCOAImportStaging2 B
					JOIN tblGLAccount A
						ON A.intAccountId = B.intAccountId
				WHERE B.strPartitionGroup = @strGroup
					AND A.strAccountId NOT IN (SELECT stri21Id
											  FROM   tblGLCOACrossReference
											  WHERE  strCompanyId = 'Legacy')
				END
			END
		END
	
		SET @strAccount = NULL
		SET @strNoPrimarySegment = NULL
		SET @strDescription = NULL
		SET @strUOM = NULL
		UPDATE tblGLCOAImportStaging2 SET ysnProcessed = 1 WHERE strPartitionGroup = @strGroup
	END

	EXEC dbo.uspGLUpdateAccountLocationId

	IF EXISTS (SELECT TOP 1 1
				FROM   sys.objects
				WHERE  object_id = object_id(N'[dbo].[glactmst]')
						AND type IN ( N'U' ))
	BEGIN
		SET ANSI_WARNINGS OFF 
		EXEC dbo.uspGLAccountOriginSync @intEntityId 
		EXEC('UPDATE G set glact_desc = LEFT( D.strDescription, 30)    
		FROM tblGLCOACrossReference C JOIN tblGLAccount A ON A.intAccountId = C.inti21Id     
		JOIN [tblGLCOAImportStaging2] D  ON D.intAccountId = A.intAccountId    
		JOIN glactmst G ON G.A4GLIdentity = C.intLegacyReferenceId    
		WHERE D.ysnInvalid = 0 AND ISNULL(D.strDescription, '''') <> '''' ');

		SET ANSI_WARNINGS ON
	END

	DECLARE @intInvalidCount INT = 0,
			@intValidCount   INT = 0,
			@intStagedCount  INT = 0

	SELECT @intStagedCount = MAX(intLineNumber) FROM tblGLCOAImportStaging WHERE strGUID = @strGUID
	SELECT @intInvalidCount = COUNT(1) FROM tblGLCOAImportStaging2 WHERE ysnInvalid = 1
	SELECT @intValidCount = COUNT(1)
	FROM tblGLCOAImportStaging2 A
	JOIN tblGLAccount B
		ON B.intAccountId = A.intAccountId
	WHERE A.ysnInvalid = 0

	DECLARE @m NVARCHAR(MAX)

	IF @intValidCount > 0
		AND @intInvalidCount > 0
		SET @m = 'Importing GL Accounts with Errors.'

	IF @intValidCount > 0
		AND @intInvalidCount = 0
		SET @m = 'Successfully imported GL Accounts.'

	IF @intValidCount = 0
		AND @intInvalidCount > 0
		SET @m = 'Importing GL Accounts Failed.'

	IF @intValidCount = 0
		AND @intInvalidCount = 0
		SET @m = 'No GL Accounts was imported.'

	INSERT INTO tblGLCOAImportLog
	(strEvent,
		intEntityId,
		intConcurrencyId,
		intUserId,
		dtmDate,
		intErrorCount,
		intSuccessCount,
		strIrelySuiteVersion,
		strJournalType)
	SELECT @m,
		@intEntityId,
		1,
		@intEntityId,
		Getdate(),
		@intInvalidCount,
		@intValidCount,
		@strVersion,
		'glaccount'

	SELECT @importLogId = Scope_identity()

	INSERT INTO tblGLCOAImportLogDetail
	(
		intImportLogId,
		strEventDescription,
		strRawString,
		strExternalId,
		strLineNumber
	)
	SELECT 
		@importLogId,
		strError,
		strRawString,
		strAccountId,
		CAST([intLineNumber] AS NVARCHAR(4))
	FROM tblGLCOAImportStaging2 

	DELETE tblGLCOAImportStaging WHERE strGUID = @strGUID
	