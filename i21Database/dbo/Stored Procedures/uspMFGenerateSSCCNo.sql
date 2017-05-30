CREATE PROCEDURE uspMFGenerateSSCCNo (
	@strOrderManifestId NVARCHAR(MAX)
	,@intNoOfLabel INT = 1
	)
AS
BEGIN
	DECLARE @intOrderManifestId INT
		,@intEntityCustomerId INT
		,@intCustomerLabelTypeId INT
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

	SELECT @intOrderManifestId = min(intOrderManifestId)
	FROM @tblMFGenerateSSNo

	SELECT @intEntityCustomerId = S.intEntityCustomerId
	FROM tblMFOrderManifest OM
	JOIN tblMFOrderHeader OH ON OH.intOrderHeaderId = OM.intOrderHeaderId
	JOIN tblICInventoryShipment S ON S.strShipmentNumber = OH.strReferenceNo
	WHERE intOrderManifestId = @intOrderManifestId

	SELECT @intCustomerLabelTypeId = intCustomerLabelTypeId
		,@strPackageType = strPackageType
		,@strManufacturerCode = strManufacturerCode
	FROM tblMFItemOwner
	WHERE intOwnerId = @intEntityCustomerId
		AND intCustomerLabelTypeId IS NOT NULL

	WHILE @intOrderManifestId IS NOT NULL
	BEGIN
		IF @intCustomerLabelTypeId = 1 -- Pallet Label
		BEGIN
			SELECT @strSSCCNo = strSSCCNo
			FROM tblMFOrderManifest
			WHERE intOrderManifestId = @intOrderManifestId

			IF ISNULL(@strSSCCNo, '') <> ''
			BEGIN
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
					,@intPatternCode = 118
					,@ysnProposed = 0
					,@strPatternString = @strBatchId OUTPUT

				--SELECT @strCheckString = @strPackageType + @strManufacturerCode + Ltrim(@strBatchId)
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

				SELECT @intOdd = SUM(convert(INT, SUBSTRING(@strCheckString, intChar, 1))) * 3
				FROM @strSplitString
				WHERE intChar % 2 = 0

				SELECT @intEven = SUM(Convert(INT, SUBSTRING(@strCheckString, intChar, 1)))
				FROM @strSplitString
				WHERE intChar % 2 <> 0

				SELECT @intCheckDigit = (@intOdd + @intEven) % 10

				IF @intCheckDigit > 0
					SELECT @intCheckDigit = 10 - @intCheckDigit

				SELECT @strSSCCNo = '(00)-' + @strPackageType + @strManufacturerCode + Ltrim(@strBatchId) + Ltrim(@intCheckDigit)

				UPDATE tblMFOrderManifest
				SET strSSCCNo = @strSSCCNo
				WHERE intOrderManifestId = @intOrderManifestId
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
					,@intPatternCode = 118
					,@ysnProposed = 0
					,@strPatternString = @strBatchId OUTPUT

				--SELECT @strCheckString = @strPackageType + @strManufacturerCode + Ltrim(@strBatchId)
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

				SELECT @intOdd = SUM(convert(INT, SUBSTRING(@strCheckString, intChar, 1))) * 3
				FROM @strSplitString
				WHERE intChar % 2 = 0

				SELECT @intEven = SUM(Convert(INT, SUBSTRING(@strCheckString, intChar, 1)))
				FROM @strSplitString
				WHERE intChar % 2 <> 0

				SELECT @intCheckDigit = (@intOdd + @intEven) % 10

				IF @intCheckDigit > 0
					SELECT @intCheckDigit = 10 - @intCheckDigit

				SELECT @strSSCCNo = '(00)-' + @strPackageType + @strManufacturerCode + Ltrim(@strBatchId) + Ltrim(@intCheckDigit)

				UPDATE tblMFOrderManifest
				SET strSSCCNo = IsNULL(strSSCCNo, '') + CASE 
						WHEN strSSCCNo IS NULL
							THEN ''
						ELSE ','
						END + @strSSCCNo
				WHERE intOrderManifestId = @intOrderManifestId

				SELECT @intNoOfLabel = @intNoOfLabel - 1
			END
		END

		SELECT @intOrderManifestId = min(intOrderManifestId)
		FROM @tblMFGenerateSSNo
		WHERE intOrderManifestId > @intOrderManifestId
	END
END
