CREATE PROCEDURE dbo.uspMFGeneratePatternId @intCategoryId INT
	,@intItemId INT
	,@intManufacturingId INT
	,@intSubLocationId INT
	,@intLocationId INT
	,@intOrderTypeId INT
	,@intBlendRequirementId INT
	,@intPatternCode INT
	,@ysnProposed BIT = 0
	,@strPatternString NVARCHAR(50) OUTPUT
AS
BEGIN
	DECLARE @intSubPatternTypeId INT
		,@intSubPatternSize INT
		,@strSubPatternTypeDetail NVARCHAR(MAX)
		,@strSubPatternFormat NVARCHAR(MAX)
		,@strErrMsg NVARCHAR(MAX)
		,@strTableName NVARCHAR(50)
		,@strColumnName NVARCHAR(50)
		,@strPrimaryColumnName NVARCHAR(50)
		,@intPrimaryColumnId INT
		,@strFormatedDate NVARCHAR(50)
		,@intLen INT
		,@strSubFormat NVARCHAR(50)
		,@intCnt INT
		,@strMM CHAR(2)
		,@strdd CHAR(2)
		,@stryy CHAR(2)
		,@stryyyy CHAR(4)
		,@dtmCurrentDate DATETIME
		,@strValue NVARCHAR(100)
		,@strSequence NVARCHAR(50)
		,@strSQL NVARCHAR(MAX)
		,@intRecordId INT
		,@intPatternId INT

	SET @dtmCurrentDate = GetDate()

	DECLARE @tblMFPatternDetail TABLE (
		intRecordId INT identity(1, 1)
		,intPatternDetailId INT
		,intSubPatternTypeId INT
		,intSubPatternSize INT
		,strSubPatternTypeDetail NVARCHAR(MAX)
		,strSubPatternFormat NVARCHAR(MAX)
		)
	DECLARE @tblMFRecord TABLE (strRecordName NVARCHAR(50))
	DECLARE @tblMFFindPrimaryKeyColumn TABLE (
		strTable_Qualifier NVARCHAR(50)
		,strTable_Owner NVARCHAR(50)
		,strTable_Name NVARCHAR(128)
		,strColumn_Name NVARCHAR(128)
		,intKey_SQL INT
		,strPK_Name NVARCHAR(128)
		)

	SELECT @intPatternId = intPatternId
	FROM dbo.tblMFPattern
	WHERE intPatternCode = @intPatternCode
		AND intLocationId = @intLocationId

	IF @intPatternId IS NULL
		SELECT @intPatternId = intPatternId
		FROM dbo.tblMFPattern
		WHERE intPatternCode = @intPatternCode

	IF @intPatternId IS NULL
	BEGIN
		EXEC dbo.uspSMGetStartingNumber @intPatternCode
			,@strPatternString OUTPUT
			,@intLocationId

		--SELECT @strPatternString AS strPatternString

		RETURN
	END

	SET @strPatternString = ''

	INSERT INTO @tblMFPatternDetail (
		intSubPatternTypeId
		,intSubPatternSize
		,strSubPatternTypeDetail
		,strSubPatternFormat
		)
	SELECT intSubPatternTypeId
		,intSubPatternSize
		,strSubPatternTypeDetail
		,strSubPatternFormat
	FROM dbo.tblMFPatternDetail
	WHERE intPatternId = @intPatternId
	ORDER BY intOrdinalPosition

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFPatternDetail

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intSubPatternTypeId = intSubPatternTypeId
			,@intSubPatternSize = intSubPatternSize
			,@strSubPatternTypeDetail = strSubPatternTypeDetail
			,@strSubPatternFormat = strSubPatternFormat
		FROM @tblMFPatternDetail
		WHERE intRecordId = @intRecordId

		IF @intSubPatternTypeId IN (
				1
				,2
				,5
				)
		BEGIN
			SET @strPatternString = @strPatternString + @strSubPatternTypeDetail
		END

		IF @intSubPatternTypeId = 3
		BEGIN
			IF @strSubPatternTypeDetail = 'Julian Date'
			BEGIN
				SET @strPatternString = @strPatternString + RIGHT(CAST(YEAR(@dtmCurrentDate) AS CHAR(4)), 2) + RIGHT('000' + CAST(DATEPART(dy, @dtmCurrentDate) AS VARCHAR(3)), 3)
			END
			ELSE
			BEGIN
				SET @strMM = 'MM'
				SET @strdd = 'dd'
				SET @stryy = 'yy'
				SET @stryyyy = 'yyyy'
				SET @intCnt = 1
				SET @intLen = LEN(@strSubPatternTypeDetail)
				SET @strSubFormat = ''

				WHILE @intLen > 0
				BEGIN
					SET @strSubFormat = @strSubFormat + SUBSTRING(@strSubPatternTypeDetail, @intCnt, 1)

					IF @strSubFormat = @strMM
						OR @strSubFormat = 'mm'
					BEGIN
						SET @strFormatedDate = CASE 
								WHEN LEN(convert(VARCHAR, datepart(MM, @dtmCurrentDate))) = 1
									THEN '0' + convert(VARCHAR, datepart(MM, @dtmCurrentDate))
								ELSE convert(VARCHAR, datepart(MM, @dtmCurrentDate))
								END
						SET @strSubFormat = ''
						SET @strPatternString = @strPatternString + @strFormatedDate
					END

					IF @strSubFormat = @strdd
					BEGIN
						SET @strFormatedDate = CASE 
								WHEN LEN(convert(VARCHAR, datepart(d, @dtmCurrentDate))) = 1
									THEN '0' + convert(VARCHAR, datepart(d, @dtmCurrentDate))
								ELSE convert(VARCHAR, datepart(d, @dtmCurrentDate))
								END
						SET @strSubFormat = ''
						SET @strPatternString = @strPatternString + @strFormatedDate
					END

					IF @strSubFormat = @stryy
						AND @intLen <= 2
					BEGIN
						SET @strFormatedDate = CASE 
								WHEN LEN(convert(VARCHAR, datepart(yy, @dtmCurrentDate))) = 4
									THEN SUBSTRING(convert(VARCHAR, datepart(yy, @dtmCurrentDate)), 3, 2)
								ELSE convert(VARCHAR, datepart(yy, @dtmCurrentDate))
								END
						SET @strSubFormat = ''
						SET @strPatternString = @strPatternString + @strFormatedDate
					END

					IF @strSubFormat = @stryyyy
					BEGIN
						SET @strFormatedDate = convert(VARCHAR, datepart(yy, @dtmCurrentDate))
						SET @strSubFormat = ''
						SET @strPatternString = @strPatternString + @strFormatedDate
					END

					SET @intCnt = @intCnt + 1
					SET @intLen = @intLen - 1
				END
			END
		END

		IF @intSubPatternTypeId = 4
		BEGIN
			SELECT @strTableName = NULL
				,@strColumnName = NULL
				,@strPrimaryColumnName = NULL
				,@intPrimaryColumnId = NULL

			SELECT @strTableName = SUBSTRING(@strSubPatternTypeDetail, 1, CHARINDEX('.', @strSubPatternTypeDetail) - 1)
				,@strColumnName = SUBSTRING(@strSubPatternTypeDetail, CHARINDEX('.', @strSubPatternTypeDetail) + 1, LEN(@strSubPatternTypeDetail))

			DELETE
			FROM @tblMFFindPrimaryKeyColumn

			INSERT INTO @tblMFFindPrimaryKeyColumn (
				strTable_Qualifier
				,strTable_Owner
				,strTable_Name
				,strColumn_Name
				,intKey_SQL
				,strPK_Name
				)
			EXEC sp_pkeys @strTableName

			SELECT @strPrimaryColumnName = strColumn_Name
			FROM @tblMFFindPrimaryKeyColumn

			DELETE
			FROM @tblMFRecord

			SELECT @intPrimaryColumnId = CASE 
					WHEN @strTableName = 'tblSMCompanyLocation'
						THEN @intLocationId
					WHEN @strTableName = 'tblSMCompanyLocationSubLocation'
						THEN @intSubLocationId
					WHEN @strTableName = 'tblICCategory'
						THEN @intCategoryId
					WHEN @strTableName = 'tblICItem'
						THEN @intItemId
					WHEN @strTableName = 'tblMFManufacturingCell'
						THEN @intManufacturingId
					WHEN @strTableName = 'tblWHOrderType'
						THEN @intOrderTypeId
					WHEN @strTableName = 'tblMFBlendRequirement'
						THEN @intBlendRequirementId
					END

			IF @intPrimaryColumnId IS NULL
				SELECT @intPrimaryColumnId = 0

			SELECT @strSQL = 'Select ' + @strColumnName + ' From ' + @strTableName + ' Where ' + @strPrimaryColumnName + ' = ' + LTRIM(@intPrimaryColumnId)

			INSERT INTO @tblMFRecord
			EXEC (@strSQL)

			SELECT @strValue = REPLACE(@strSubPatternFormat, '<?>', '''' + strRecordName + '''')
			FROM @tblMFRecord

			DELETE
			FROM @tblMFRecord

			IF @strValue IS NOT NULL
			BEGIN
				INSERT INTO @tblMFRecord
				EXEC ('Select ' + @strValue)
			END

			SELECT @strPatternString = @strPatternString + strRecordName
			FROM @tblMFRecord
		END

		IF @intSubPatternTypeId = 6
		BEGIN
			IF EXISTS (
					SELECT *
					FROM dbo.tblMFPatternSequence
					WHERE intPatternId = @intPatternId
						AND strPatternSequence = @strPatternString
						AND intMaximumSequence - intSequenceNo = 0
					)
			BEGIN
				SET @strErrMsg = 'The Lot ID for the sequence ' + @strPatternString + ' is reached the maximum limit. Please reset the sequence prefix.'

				RAISERROR (
						@strErrMsg
						,16
						,1
						,'WITH NOWAIT'
						)

				RETURN
			END

			SELECT @strSequence = convert(NVARCHAR, intSequenceNo)
			FROM dbo.tblMFPatternSequence
			WHERE intPatternId = @intPatternId
				AND strPatternSequence = @strPatternString

			IF @strSequence IS NULL
			BEGIN
				SELECT @strSequence = 0

				SELECT @strSequence = replicate('0', @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1)))) + convert(VARCHAR(32), (@strSequence + 1))

				IF @ysnProposed = 0
				BEGIN
					INSERT INTO dbo.tblMFPatternSequence (
						intPatternId
						,strPatternSequence
						,intSequenceNo
						,intMaximumSequence
						,ysnNotified
						)
					VALUES (
						@intPatternId
						,@strPatternString
						,convert(INT, @strSequence)
						,cast(REPLICATE('9', @intSubPatternSize) AS INT)
						,0
						)
				END
			END
			ELSE
			BEGIN
				SELECT @strSequence = replicate('0', @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1)))) + convert(VARCHAR(32), (@strSequence + 1))

				IF @ysnProposed = 0
				BEGIN
					UPDATE dbo.tblMFPatternSequence
					SET intSequenceNo = convert(INT, @strSequence)
						,intMaximumSequence = cast(REPLICATE('9', @intSubPatternSize) AS INT)
					WHERE intPatternId = @intPatternId
						AND strPatternSequence = @strPatternString
				END
			END

			SET @strPatternString = @strPatternString + @strSequence
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFPatternDetail
		WHERE intRecordId > @intRecordId
	END

	--SELECT @strPatternString AS strPatternString
END
