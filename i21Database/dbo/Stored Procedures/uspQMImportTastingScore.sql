CREATE PROCEDURE uspQMImportTastingScore
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

    -- Validate Foreign Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Colour
    LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season' AND COLOUR.strDescription = IMP.strColour
    -- Size
    LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
    -- Style
    LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
    -- Tealingo Item
    LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage = 
            CASE WHEN (COLOUR.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '') THEN 'COLOUR, ' ELSE '' END
            + CASE WHEN (SIZE.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '') THEN 'SIZE, ' ELSE '' END
            + CASE WHEN (STYLE.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '') THEN 'STYLE, ' ELSE '' END
            + CASE WHEN (ITEM.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '') THEN 'TEALINGO ITEM, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        (COLOUR.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '')
        OR (SIZE.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '')
        OR (STYLE.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '')
        OR (ITEM.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '')
    )
    -- End Validation

    DECLARE
        @intImportCatalogueId INT
        ,@intSampleTypeId INT
        ,@intColourId INT
        ,@strColour NVARCHAR(50)
        ,@intBrandId INT -- Size
        ,@strBrand NVARCHAR(50)
        ,@strComments NVARCHAR(MAX)
        ,@intSampleId INT
        ,@intValuationGroupId INT -- Style
        ,@strValuationGroup NVARCHAR(50)
        ,@strMusterLot NVARCHAR(50)
	    ,@strMissingLot NVARCHAR(50)
        ,@strComments2 NVARCHAR(MAX)
        ,@intItemId INT
        ,@intCategoryId INT
        ,@dtmDateCreated DATETIME
        ,@intEntityUserId INT
        -- Test Properties
        ,@strAppearance NVARCHAR(MAX)
        ,@strHue NVARCHAR(MAX)
        ,@strIntensity NVARCHAR(MAX)
        ,@strTaste NVARCHAR(MAX)
        ,@strMouthFeel NVARCHAR(MAX)

    DECLARE @intValidDate INT

    SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

    SELECT TOP 1
        @intItemId = [intDefaultItemId]
        ,@intCategoryId = I.intCategoryId
    FROM tblQMCatalogueImportDefaults CID
    INNER JOIN tblICItem I ON I.intItemId = CID.intDefaultItemId

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportCatalogueId = IMP.intImportCatalogueId
            ,intSampleTypeId = S.intSampleTypeId
            ,intColourId = COLOUR.intCommodityAttributeId
            ,strColour = COLOUR.strDescription
            ,intBrandId = SIZE.intBrandId
            ,strBrand = SIZE.strBrandCode
            ,strComments = IMP.strRemarks
            ,intSampleId = S.intSampleId
            ,intValuationGroupId = STYLE.intValuationGroupId
            ,strValuationGroup = STYLE.strName
            ,strMusterLot = IMP.strMusterLot
            ,strMissingLot = IMP.strMissingLot
            ,strComments2 = IMP.strTastersRemarks
            ,intItemId = ITEM.intItemId
            ,intCategoryId = ITEM.intCategoryId
            ,dtmDateCreated = IL.dtmImportDate
            ,intEntityUserId = IL.intEntityId
            -- Test Properties
            ,strAppearance = IMP.strAppearance
            ,strHue = IMP.strHue
            ,strIntensity = IMP.strIntensity
            ,strTaste = IMP.strTaste
            ,strMouthFeel = IMP.strMouthfeel
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = A.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN (
            tblQMImportCatalogue IMP INNER JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
            INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
            -- Colour
            LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season' AND COLOUR.strDescription = IMP.strColour
            -- Size
            LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
            -- Style
            LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
            -- Tealingo Item
            LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
        )
            ON S.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.intSaleNumber = IMP.intSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND V.strVendorAccountNum = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        WHERE IMP.intImportLogId = @intImportLogId
            AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO
		@intImportCatalogueId
        ,@intSampleTypeId
        ,@intColourId
        ,@strColour
        ,@intBrandId
        ,@strBrand
        ,@strComments
        ,@intSampleId
        ,@intValuationGroupId
        ,@strValuationGroup
        ,@strMusterLot
	    ,@strMissingLot
        ,@strComments2
        ,@intItemId
        ,@intCategoryId
        ,@dtmDateCreated
        ,@intEntityUserId
        -- Test Properties
        ,@strAppearance
        ,@strHue
        ,@strIntensity
        ,@strTaste
        ,@strMouthFeel
	WHILE @@FETCH_STATUS = 0
	BEGIN

        UPDATE S
        SET
            intConcurrencyId = S.intConcurrencyId + 1
            ,intSeasonId = @intColourId
            ,strSeason = @strColour
            ,intBrandId = @intBrandId
            ,strBrandCode = @strBrand
            ,intValuationGroupId = @intValuationGroupId
            ,strValuationGroupName = @strValuationGroup
            ,strMusterLot = @strMusterLot
            ,strMissingLot = @strMissingLot
            ,strComments2 = @strComments2
            ,intItemId = @intItemId
            ,intLastModifiedUserId = @intEntityUserId
            ,dtmLastModified = @dtmDateCreated
        FROM tblQMSample S
        WHERE S.intSampleId = @intSampleId

        UPDATE A
        SET
            intConcurrencyId = A.intConcurrencyId + 1
            ,intSeasonId = @intColourId
            ,strSeason = @strColour
            ,intBrandId = @intBrandId
            ,strBrand = @strBrand
            ,intValuationGroupId = @intValuationGroupId
            ,strValuationGroupName = @strValuationGroup
            ,strMusterLot = @strMusterLot
            ,strMissingLot = @strMissingLot
            ,strComments2 = @strComments2
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        WHERE S.intSampleId = @intSampleId

        DECLARE @intProductId INT
        -- Template
        IF (ISNULL(@intItemId, 0) > 0 AND ISNULL(@intSampleTypeId, 0) > 0)
        BEGIN
            SELECT @intProductId = (
                    SELECT P.intProductId
                    FROM tblQMProduct AS P
                    JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
                    WHERE P.intProductTypeId = 2 -- Item
                        AND P.intProductValueId = @intItemId
                        AND PC.intSampleTypeId = @intSampleTypeId
                        AND P.ysnActive = 1
                    )

            IF (@intProductId IS NULL AND ISNULL(@intCategoryId, 0) > 0)
                SELECT @intProductId = (
                        SELECT P.intProductId
                        FROM tblQMProduct AS P
                        JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
                        WHERE P.intProductTypeId = 1 -- Item Category
                            AND P.intProductValueId = @intCategoryId
                            AND PC.intSampleTypeId = @intSampleTypeId
                            AND P.ysnActive = 1
                        )
        END

        -- Clear test properties of the default item
        IF EXISTS(SELECT 1 FROM tblQMSample WHERE intSampleId = @intSampleId AND intItemId <> @intItemId)
        BEGIN
            DELETE FROM tblQMTestResult WHERE intSampleId = @intSampleId
            -- Insert Test Result
            INSERT INTO tblQMTestResult (
                intConcurrencyId
                ,intSampleId
                ,intProductId
                ,intProductTypeId
                ,intProductValueId
                ,intTestId
                ,intPropertyId
                ,strPanelList
                ,strPropertyValue
                ,dtmCreateDate
                ,strResult
                ,ysnFinal
                ,strComment
                ,intSequenceNo
                ,dtmValidFrom
                ,dtmValidTo
                ,strPropertyRangeText
                ,dblMinValue
                ,dblPinpointValue
                ,dblMaxValue
                ,dblLowValue
                ,dblHighValue
                ,intUnitMeasureId
                ,strFormulaParser
                ,dblCrdrPrice
                ,dblCrdrQty
                ,intProductPropertyValidityPeriodId
                ,intPropertyValidityPeriodId
                ,intControlPointId
                ,intParentPropertyId
                ,intRepNo
                ,strFormula
                ,intListItemId
                ,strIsMandatory
                ,dtmPropertyValueCreated
                ,intCreatedUserId
                ,dtmCreated
                ,intLastModifiedUserId
                ,dtmLastModified
                )
            SELECT DISTINCT 1
                ,@intSampleId
                ,@intProductId
                ,2 -- Item
                ,@intItemId
                ,PP.intTestId
                ,PP.intPropertyId
                ,''
                ,''
                ,@dtmDateCreated
                ,''
                ,0
                ,''
                ,PP.intSequenceNo
                ,PPV.dtmValidFrom
                ,PPV.dtmValidTo
                ,PPV.strPropertyRangeText
                ,PPV.dblMinValue
                ,PPV.dblPinpointValue
                ,PPV.dblMaxValue
                ,PPV.dblLowValue
                ,PPV.dblHighValue
                ,PPV.intUnitMeasureId
                ,PP.strFormulaParser
                ,NULL
                ,NULL
                ,PPV.intProductPropertyValidityPeriodId
                ,NULL
                ,PC.intControlPointId
                ,NULL
                ,0
                ,PP.strFormulaField
                ,NULL
                ,PP.strIsMandatory
                ,NULL
                ,@intEntityUserId
                ,@dtmDateCreated
                ,@intEntityUserId
                ,@dtmDateCreated
            FROM tblQMProduct AS PRD
            JOIN tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
            JOIN tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
            JOIN tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
                AND PT.intProductId = PRD.intProductId
            JOIN tblQMTest AS T ON T.intTestId = PP.intTestId
                AND T.intTestId = PT.intTestId
            JOIN tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
                AND TP.intTestId = PP.intTestId
                AND TP.intTestId = T.intTestId
                AND TP.intTestId = PT.intTestId
            JOIN tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
                AND PRT.intPropertyId = TP.intPropertyId
            JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
            WHERE PRD.intProductId = @intProductId
                AND PC.intSampleTypeId = @intSampleTypeId
                AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom) AND DATEPART(dy, PPV.dtmValidTo)
            ORDER BY PP.intSequenceNo
        END

        -- Begin Update Actual Test Result

        -- Appearance
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strAppearance) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strAppearance END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strAppearance, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Appearance'

        -- Hue
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strHue) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strHue END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strHue, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Hue'

        -- Intensity
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strIntensity) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strIntensity END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strIntensity, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Intensity'

        -- Taste
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strTaste) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strTaste END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strTaste, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Taste'

        -- Mouth Feel
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strMouthFeel) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strMouthFeel END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strMouthFeel, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Mouth Feel'

		-- Calculate and update formula property value
        DECLARE @FormulaProperty TABLE (
            intTestResultId INT
            ,strFormula NVARCHAR(MAX)
            ,strFormulaParser NVARCHAR(MAX)
		)

        DECLARE @intTestResultId INT
            ,@strFormula NVARCHAR(MAX)
            ,@strFormulaParser NVARCHAR(MAX)
            ,@strPropertyValue NVARCHAR(MAX)

		DELETE FROM @FormulaProperty

		INSERT INTO @FormulaProperty
		SELECT intTestResultId
			,strFormula
			,strFormulaParser
		FROM tblQMTestResult
		WHERE intSampleId = @intSampleId
			AND ISNULL(strFormula, '') <> ''
			AND ISNULL(strFormulaParser, '') <> ''
		ORDER BY intTestResultId

		SELECT @intTestResultId = MIN(intTestResultId) FROM @FormulaProperty

		WHILE (ISNULL(@intTestResultId, 0) > 0)
		BEGIN
			SELECT @strFormula = NULL
				,@strFormulaParser = NULL
				,@strPropertyValue = ''

			SELECT @strFormula = strFormula
				,@strFormulaParser = strFormulaParser
			FROM @FormulaProperty
			WHERE intTestResultId = @intTestResultId

			SELECT @strFormula = REPLACE(REPLACE(REPLACE(@strFormula, @strFormulaParser, ''), '{', ''), '}', '')

			IF @strFormulaParser = 'MAX'
			BEGIN
				SELECT @strPropertyValue = MAX(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'MIN'
			BEGIN
				SELECT @strPropertyValue = MIN(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'AVG'
			BEGIN
				SELECT @strPropertyValue = AVG(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'SUM'
			BEGIN
				SELECT @strPropertyValue = SUM(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END

			IF @strPropertyValue <> ''
			BEGIN
				UPDATE tblQMTestResult
				SET strPropertyValue = dbo.fnRemoveTrailingZeroes(@strPropertyValue)
				WHERE intTestResultId = @intTestResultId
			END

			SELECT @intTestResultId = MIN(intTestResultId)
			FROM @FormulaProperty
			WHERE intTestResultId > @intTestResultId
		END

		-- Setting result for formula properties and the result which is not sent in excel
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(TR.strResult, '') = ''

		-- Setting correct date format
		UPDATE tblQMTestResult
		SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
			AND P.intDataTypeId = 12

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        FETCH NEXT FROM @C INTO
            @intImportCatalogueId
            ,@intSampleTypeId
            ,@intColourId
            ,@strColour
            ,@intBrandId
            ,@strBrand
            ,@strComments
            ,@intSampleId
            ,@intValuationGroupId
            ,@strValuationGroup
            ,@strMusterLot
            ,@strMissingLot
            ,@strComments2
            ,@intItemId
            ,@intCategoryId
            ,@dtmDateCreated
            ,@intEntityUserId
            -- Test Properties
            ,@strAppearance
            ,@strHue
            ,@strIntensity
            ,@strTaste
            ,@strMouthFeel
    END
    CLOSE @C
	DEALLOCATE @C

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH