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
	,@intEntityId INT = NULL
	,@intShiftId INT = NULL
	,@dtmDate DATETIME = NULL
	,@strParentLotNumber NVARCHAR(50) = NULL
	,@intInventoryReceiptId INT = NULL
	,@intInventoryReceiptItemId INT = NULL
	,@intInventoryReceiptItemLotId INT = NULL
	,@intTransactionTypeId INT = NULL
	,@intCommodityId INT = NULL
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
		,@dtmBusinessDate DATETIME
		,@ysnPaddingZero BIT
		,@ysnMaxSize BIT
		,@intIRParentLotNumberPatternId INT
		,@intContractHeaderId int

	IF @strParentLotNumber IS NULL
	BEGIN
		SELECT @strParentLotNumber = ''
	END

	IF @intCategoryId IS NULL
		OR @intCommodityId IS NULL
	BEGIN
		SELECT @intCategoryId = intCategoryId
			,@intCommodityId = intCommodityId
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId
	END

	IF EXISTS (
			SELECT *
			FROM tblMFPatternByCategory
			WHERE intPatternCode = @intPatternCode
				AND intCategoryId = @intCategoryId
			)
	BEGIN
		SELECT @intPatternCode = intSubPatternCode
		FROM tblMFPatternByCategory
		WHERE intPatternCode = @intPatternCode
			AND intCategoryId = @intCategoryId
	END

	SELECT @intIRParentLotNumberPatternId = intIRParentLotNumberPatternId
	FROM tblMFCompanyPreference

	IF @dtmDate IS NULL
		AND @intTransactionTypeId = 4
	BEGIN
		SELECT @dtmDate = dtmReceiptDate
		FROM tblICInventoryReceipt
		WHERE intInventoryReceiptId = @intInventoryReceiptId
	END


	IF @intPatternCode = 78
		AND @intTransactionTypeId = 4
		AND @intIRParentLotNumberPatternId = 1
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFParentLotNumberPattern
				WHERE intInventoryReceiptId = @intInventoryReceiptId
				AND intCommodityId=@intCommodityId
				)
		BEGIN
			SELECT @strPatternString = strPatternString
			FROM tblMFParentLotNumberPattern
			WHERE intInventoryReceiptId = @intInventoryReceiptId
			AND intCommodityId=@intCommodityId

			RETURN
		END
	END

	IF @intPatternCode = 78
		AND @intTransactionTypeId = 4
		AND @intIRParentLotNumberPatternId = 2
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFParentLotNumberPattern
				WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
				)
		BEGIN
			SELECT @strPatternString = strPatternString
			FROM tblMFParentLotNumberPattern
			WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

			RETURN
		END

		Select @intContractHeaderId=intContractHeaderId
		from tblICInventoryReceiptItem
		Where intInventoryReceiptItemId = @intInventoryReceiptItemId
	END

	IF OBJECT_ID('tempdb..##tblMFRecord') IS NOT NULL
		DROP TABLE ##tblMFRecord

	CREATE TABLE [dbo].##tblMFRecord ([strRecordName] NVARCHAR(50))

	IF @dtmDate IS NULL
		SET @dtmCurrentDate = GetDate()
	ELSE
		SELECT @dtmCurrentDate = @dtmDate

	DECLARE @tblMFPatternDetail TABLE (
		intRecordId INT identity(1, 1)
		,intPatternDetailId INT
		,intSubPatternTypeId INT
		,intSubPatternSize INT
		,strSubPatternTypeDetail NVARCHAR(MAX)
		,strSubPatternFormat NVARCHAR(MAX)
		,ysnPaddingZero BIT
		,ysnMaxSize BIT
		)
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
		,ysnPaddingZero
		,ysnMaxSize
		)
	SELECT intSubPatternTypeId
		,intSubPatternSize
		,strSubPatternTypeDetail
		,strSubPatternFormat
		,ysnPaddingZero
		,ysnMaxSize
	FROM dbo.tblMFPatternDetail
	WHERE intPatternId = @intPatternId
	ORDER BY intOrdinalPosition
		,strSubPatternName

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFPatternDetail

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intSubPatternTypeId = intSubPatternTypeId
			,@intSubPatternSize = intSubPatternSize
			,@strSubPatternTypeDetail = strSubPatternTypeDetail
			,@strSubPatternFormat = strSubPatternFormat
			,@ysnPaddingZero = IsNULL(ysnPaddingZero, 1)
			,@ysnMaxSize = IsNULL(ysnMaxSize, 1)
		FROM @tblMFPatternDetail
		WHERE intRecordId = @intRecordId

		IF @intSubPatternTypeId IN (
				1
				,2
				,5
				)
		BEGIN
			SET @strPatternString = @strPatternString + Replace(@strSubPatternTypeDetail, '@strParentLotNumber', @strParentLotNumber)
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

			--INSERT INTO @tblMFFindPrimaryKeyColumn (
			--	strTable_Qualifier
			--	,strTable_Owner
			--	,strTable_Name
			--	,strColumn_Name
			--	,intKey_SQL
			--	,strPK_Name
			--	)
			--EXEC sp_pkeys @strTableName
			--SELECT @strPrimaryColumnName = strColumn_Name
			--FROM @tblMFFindPrimaryKeyColumn
			SELECT @strPrimaryColumnName = COLUMN_NAME
			FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
			WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
				AND TABLE_NAME = @strTableName
				AND TABLE_SCHEMA = 'dbo'

			DELETE
			FROM ##tblMFRecord

			IF @intShiftId IS NULL
				AND @strTableName = 'tblMFShift'
			BEGIN
				SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

				SELECT @intShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
						AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset
			END

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
					WHEN @strTableName = 'tblEMEntity'
						THEN @intEntityId
					WHEN @strTableName = 'tblMFShift'
						THEN @intShiftId
					WHEN @strTableName = 'tblICCommodity'
						THEN @intCommodityId
						WHEN @strTableName = 'tblCTContractHeader'
						THEN @intContractHeaderId
						WHEN @strTableName = 'tblICInventoryReceiptItemLot'
						THEN @intInventoryReceiptItemLotId
					END

			IF @intPrimaryColumnId IS NULL
				SELECT @intPrimaryColumnId = 0

			SELECT @strSQL = 'Select ' + @strColumnName + ' From ' + @strTableName + ' Where ' + @strPrimaryColumnName + ' = ' + LTRIM(@intPrimaryColumnId)

			DECLARE @a NVARCHAR(MAX) = 'INSERT INTO ##tblMFRecord ' + @strSQL

			EXEC sp_executesql @a

			SELECT @strValue = REPLACE(@strSubPatternFormat, '<?>', '''' + strRecordName + '''')
			FROM ##tblMFRecord

			DELETE
			FROM ##tblMFRecord

			IF @strValue IS NOT NULL
			BEGIN
				SET @a = 'INSERT INTO ##tblMFRecord SELECT ' + @strValue

				EXEC sp_executesql @a
			END

			SELECT @strPatternString = @strPatternString + strRecordName
			FROM ##tblMFRecord
		END

		IF @intSubPatternTypeId = 6
			OR @intSubPatternTypeId = 8
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
				IF @intSubPatternTypeId = 8
				BEGIN
					SELECT @strSequence = 64
				END
				ELSE
				BEGIN
					SELECT @strSequence = 0
				END

				IF @ysnPaddingZero = 1
					AND @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1))) > 0
				BEGIN
					SELECT @strSequence = replicate('0', @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1)))) + convert(VARCHAR(32), (@strSequence + 1))
				END
				ELSE
				BEGIN
					SELECT @strSequence = @strSequence + 1
				END

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
						,CASE 
							WHEN @ysnMaxSize = 1
								THEN 2147483647
							ELSE cast(REPLICATE('9', @intSubPatternSize) AS INT)
							END
						,0
						)
				END
			END
			ELSE
			BEGIN
				IF @ysnPaddingZero = 1
					AND @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1))) > 0
				BEGIN
					SELECT @strSequence = replicate('0', @intSubPatternSize - len(convert(VARCHAR(32), (@strSequence + 1)))) + convert(VARCHAR(32), (@strSequence + 1))
				END
				ELSE
				BEGIN
					SELECT @strSequence = @strSequence + 1
				END

				IF @ysnProposed = 0
				BEGIN
					UPDATE dbo.tblMFPatternSequence
					SET intSequenceNo = convert(INT, @strSequence)
						,intMaximumSequence = CASE 
							WHEN @ysnMaxSize = 1
								THEN 2147483647
							ELSE cast(REPLICATE('9', @intSubPatternSize) AS INT)
							END
					WHERE intPatternId = @intPatternId
						AND strPatternSequence = @strPatternString
				END
			END

			IF @intSubPatternTypeId = 8
			BEGIN
				SET @strPatternString = @strPatternString + (
						CASE 
							WHEN @strSequence BETWEEN 65
									AND 90
								THEN CHAR(@strSequence)
							ELSE @strSequence
							END
						)
			END
			ELSE
			BEGIN
				SET @strPatternString = @strPatternString + @strSequence
			END
		END

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFPatternDetail
		WHERE intRecordId > @intRecordId
	END

	IF @intPatternCode = 78
		AND @intTransactionTypeId = 4
		AND @intIRParentLotNumberPatternId = 1
	BEGIN
		IF NOT EXISTS (
				SELECT *
				FROM tblMFParentLotNumberPattern
				WHERE intInventoryReceiptId = @intInventoryReceiptId
				AND intCommodityId=@intCommodityId
				)
		BEGIN
			INSERT INTO tblMFParentLotNumberPattern (
				intInventoryReceiptId
				,strPatternString
				,intCommodityId
				)
			SELECT @intInventoryReceiptId
				,@strPatternString
				,@intCommodityId
		END
	END

	IF @intPatternCode = 78
		AND @intTransactionTypeId = 4
		AND @intIRParentLotNumberPatternId = 2
	BEGIN
		IF NOT EXISTS (
				SELECT *
				FROM tblMFParentLotNumberPattern
				WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId
				)
		BEGIN
			INSERT INTO tblMFParentLotNumberPattern (
				intInventoryReceiptItemId
				,strPatternString
				)
			SELECT @intInventoryReceiptItemId
				,@strPatternString
		END
	END
			--SELECT @strPatternString AS strPatternString
END
