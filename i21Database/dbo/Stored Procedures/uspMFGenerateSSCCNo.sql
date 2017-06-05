CREATE PROCEDURE uspMFGenerateSSCCNo (
	@strOrderManifestId NVARCHAR(MAX)
	,@intNoOfLabel INT = 1
	,@intCustomerLabelTypeId INT
	)
AS
BEGIN
	DECLARE @intOrderManifestId INT
		,@intEntityCustomerId INT
		,@strPackageType NVARCHAR(1)
		,@strManufacturerCode NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@strSSCCNo NVARCHAR(50)
	DECLARE @strCheckString VARCHAR(8000)
		,@intOdd INT
		,@intEven INT
		,@intCheckDigit INT
	DECLARE @strSplitString TABLE (intChar INT)
	DECLARE @tblMFGenerateSSNo TABLE (intOrderManifestId INT)

	INSERT INTO @tblMFGenerateSSNo
	SELECT *
	FROM dbo.fnSplitString(@strOrderManifestId, '^')
	WHERE Item <> ''

	SELECT @intOrderManifestId = min(intOrderManifestId)
	FROM @tblMFGenerateSSNo

	SELECT @intEntityCustomerId = S.intEntityCustomerId
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	WHERE intOrderManifestId = @intOrderManifestId

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFItemOwner
			WHERE intOwnerId = @intEntityCustomerId
				AND intCustomerLabelTypeId = @intCustomerLabelTypeId
			)
		RETURN

	SELECT TOP 1 @strPackageType = strPackageType
		,@strManufacturerCode = strManufacturerCode
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId = @intCustomerLabelTypeId

	WHILE @intOrderManifestId IS NOT NULL
	BEGIN
		SELECT @intOdd = NULL
			,@intEven = NULL
			,@intCheckDigit = NULL
			,@strSSCCNo = ''

		IF @intCustomerLabelTypeId = 1 -- Pallet Label
		BEGIN
			SELECT @strSSCCNo = strSSCCNo
			FROM tblMFOrderManifestLabel
			WHERE intOrderManifestId = @intOrderManifestId
				AND intCustomerLabelTypeId = @intCustomerLabelTypeId

			IF ISNULL(@strSSCCNo, '') <> ''
			BEGIN
				UPDATE tblMFOrderManifestLabel
				SET ysnPrinted = 0
				WHERE intOrderManifestId = @intOrderManifestId
					AND intCustomerLabelTypeId = @intCustomerLabelTypeId

				SELECT @intOrderManifestId = MIN(intOrderManifestId)
				FROM @tblMFGenerateSSNo
				WHERE intOrderManifestId > @intOrderManifestId

				CONTINUE
			END
			ELSE
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = NULL
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 119
					,@ysnProposed = 0
					,@strPatternString = @strBatchId OUTPUT

				SELECT @strCheckString = @strManufacturerCode + Ltrim(@strBatchId) -- Will be 16 digit (Eg: 0718908 562723189)

				DELETE
				FROM @strSplitString

				INSERT INTO @strSplitString
				SELECT TOP (LEN(@strCheckString)) ROW_NUMBER() OVER (
						ORDER BY (
								SELECT NULL
								)
						)
				FROM (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) a(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) b(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) c(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) d(intChar)

				SELECT @intOdd = SUM(CONVERT(INT, SUBSTRING(@strCheckString, intChar, 1))) * 3
				FROM @strSplitString
				WHERE intChar % 2 <> 0

				SELECT @intEven = SUM(CONVERT(INT, SUBSTRING(@strCheckString, intChar, 1)))
				FROM @strSplitString
				WHERE intChar % 2 = 0

				SELECT @intCheckDigit = (@intOdd + @intEven) % 10

				IF @intCheckDigit > 0
					SELECT @intCheckDigit = 10 - @intCheckDigit

				SELECT @strSSCCNo = '(00) ' + @strPackageType + ' ' + @strManufacturerCode + ' ' + LTRIM(@strBatchId) + ' ' + LTRIM(@intCheckDigit)

				INSERT INTO tblMFOrderManifestLabel (
					intConcurrencyId
					,intOrderManifestId
					,intCustomerLabelTypeId
					,strSSCCNo
					,ysnPrinted
					)
				VALUES (
					1
					,@intOrderManifestId
					,@intCustomerLabelTypeId
					,@strSSCCNo
					,0
					)
			END
		END
		ELSE IF @intCustomerLabelTypeId = 2 -- Case Label
		BEGIN
			WHILE @intNoOfLabel > 0
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = NULL
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 119
					,@ysnProposed = 0
					,@strPatternString = @strBatchId OUTPUT

				SELECT @strCheckString = @strManufacturerCode + Ltrim(@strBatchId) -- Will be 16 digit (Eg: 0718908 562723189)

				DELETE
				FROM @strSplitString

				INSERT INTO @strSplitString
				SELECT TOP (LEN(@strCheckString)) ROW_NUMBER() OVER (
						ORDER BY (
								SELECT NULL
								)
						)
				FROM (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) a(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) b(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) c(intChar)
				CROSS JOIN (
					VALUES (0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
						,(0)
					) d(intChar)

				SELECT @intOdd = SUM(CONVERT(INT, SUBSTRING(@strCheckString, intChar, 1))) * 3
				FROM @strSplitString
				WHERE intChar % 2 = 0

				SELECT @intEven = SUM(CONVERT(INT, SUBSTRING(@strCheckString, intChar, 1)))
				FROM @strSplitString
				WHERE intChar % 2 <> 0

				SELECT @intCheckDigit = (@intOdd + @intEven) % 10

				IF @intCheckDigit > 0
					SELECT @intCheckDigit = 10 - @intCheckDigit

				SELECT @strSSCCNo = '(00) ' + @strPackageType + ' ' + @strManufacturerCode + ' ' + LTRIM(@strBatchId) + ' ' + LTRIM(@intCheckDigit)

				INSERT INTO tblMFOrderManifestLabel (
					intConcurrencyId
					,intOrderManifestId
					,intCustomerLabelTypeId
					,strSSCCNo
					,ysnPrinted
					)
				VALUES (
					1
					,@intOrderManifestId
					,@intCustomerLabelTypeId
					,@strSSCCNo
					,0
					)

				SELECT @intNoOfLabel = @intNoOfLabel - 1
			END
		END

		SELECT @intOrderManifestId = MIN(intOrderManifestId)
		FROM @tblMFGenerateSSNo
		WHERE intOrderManifestId > @intOrderManifestId
	END
END
