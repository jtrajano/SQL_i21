CREATE PROCEDURE [dbo].[uspQMProductPropertyDetails_Save]
	@strXml NVARCHAR(Max)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intProductPropertyId INT
	DECLARE @tblQMProductProperty TABLE (
		intProductPropertyId INT
		,intConcurrencyId INT
		,intProductId INT
		,intTestId INT
		,intPropertyId INT
		,strFormulaParser NVARCHAR(MAX)
		,strComputationMethod NVARCHAR(30)
		,intSequenceNo INT
		,intComputationTypeId INT
		,strFormulaField NVARCHAR(MAX)
		,strIsMandatory NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,intLastModifiedUserId INT
		,dtmLastModified DATETIME
		)
	DECLARE @tblQMProductPropertyValidityPeriod TABLE (
		intProductPropertyValidityPeriodId INT
		,intConcurrencyId INT
		,intProductPropertyId INT
		,dtmValidFrom DATETIME
		,dtmValidTo DATETIME
		,strPropertyRangeText NVARCHAR(MAX)
		,dblMinValue NUMERIC(18, 6)
		,dblMaxValue NUMERIC(18, 6)
		,dblLowValue NUMERIC(18, 6)
		,dblHighValue NUMERIC(18, 6)
		,intUnitMeasureId INT
		,strFormula NVARCHAR(MAX)
		,strFormulaParser NVARCHAR(MAX)
		,intCreatedUserId INT
		,dtmCreated DATETIME
		,intLastModifiedUserId INT
		,dtmLastModified DATETIME
		)
	DECLARE @tblQMConditionalProductProperty TABLE (
		intConditionalProductPropertyId INT
		,intProductPropertyId INT
		,intConcurrencyId INT
		,intOnSuccessPropertyId INT
		,intOnFailurePropertyId INT
		,intCreatedUserId INT
		,dtmCreated DATETIME
		,intLastModifiedUserId INT
		,dtmLastModified DATETIME
		)

	INSERT INTO @tblQMProductProperty (
		intProductPropertyId
		,intConcurrencyId
		,intProductId
		,intTestId
		,intPropertyId
		,strFormulaParser
		,strComputationMethod
		,intSequenceNo
		,intComputationTypeId
		,strFormulaField
		,strIsMandatory
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intProductPropertyId
		,intConcurrencyId
		,intProductId
		,intTestId
		,intPropertyId
		,strFormulaParser
		,strComputationMethod
		,intSequenceNo
		,intComputationTypeId
		,strFormulaField
		,strIsMandatory
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intProductPropertyId INT
			,intConcurrencyId INT
			,intProductId INT
			,intTestId INT
			,intPropertyId INT
			,strFormulaParser NVARCHAR(MAX)
			,strComputationMethod NVARCHAR(30)
			,intSequenceNo INT
			,intComputationTypeId INT
			,strFormulaField NVARCHAR(MAX)
			,strIsMandatory NVARCHAR(20)
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	INSERT INTO @tblQMProductPropertyValidityPeriod (
		intProductPropertyValidityPeriodId
		,intConcurrencyId
		,intProductPropertyId
		,dtmValidFrom
		,dtmValidTo
		,strPropertyRangeText
		,dblMinValue
		,dblMaxValue
		,dblLowValue
		,dblHighValue
		,intUnitMeasureId
		,strFormula
		,strFormulaParser
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intProductPropertyValidityPeriodId
		,intConcurrencyId
		,intProductPropertyId
		,dtmValidFrom
		,dtmValidTo
		,strPropertyRangeText
		,dblMinValue
		,dblMaxValue
		,dblLowValue
		,dblHighValue
		,intUnitMeasureId
		,strFormula
		,strFormulaParser
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/ProductPropertyValidityPeriod', 2) WITH (
			intProductPropertyValidityPeriodId INT
			,intConcurrencyId INT
			,intProductPropertyId INT
			,dtmValidFrom DATETIME
			,dtmValidTo DATETIME
			,strPropertyRangeText NVARCHAR(MAX)
			,dblMinValue NUMERIC(18, 6)
			,dblMaxValue NUMERIC(18, 6)
			,dblLowValue NUMERIC(18, 6)
			,dblHighValue NUMERIC(18, 6)
			,intUnitMeasureId INT
			,strFormula NVARCHAR(MAX)
			,strFormulaParser NVARCHAR(MAX)
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	INSERT INTO @tblQMConditionalProductProperty (
		intConditionalProductPropertyId
		,intProductPropertyId
		,intConcurrencyId
		,intOnSuccessPropertyId
		,intOnFailurePropertyId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intConditionalProductPropertyId
		,intProductPropertyId
		,intConcurrencyId
		,intOnSuccessPropertyId
		,intOnFailurePropertyId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/ProductConditionalProperty', 2) WITH (
			intConditionalProductPropertyId INT
			,intProductPropertyId INT
			,intConcurrencyId INT
			,intOnSuccessPropertyId INT
			,intOnFailurePropertyId INT
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	SELECT @intProductPropertyId = intProductPropertyId
	FROM @tblQMProductProperty

	BEGIN TRAN

	-- Product Property Updation
	UPDATE a
	SET a.intLastModifiedUserId = b.intLastModifiedUserId
		,a.dtmLastModified = b.dtmLastModified
		,a.strIsMandatory = b.strIsMandatory
	FROM tblQMProductProperty a
	JOIN @tblQMProductProperty b ON a.intProductPropertyId = b.intProductPropertyId
		AND a.strIsMandatory <> b.strIsMandatory

	-- Validity Period Deletion & Creation & Updation
	DELETE
	FROM tblQMProductPropertyValidityPeriod
	WHERE intProductPropertyId = @intProductPropertyId
		AND intProductPropertyValidityPeriodId NOT IN (
			SELECT intProductPropertyValidityPeriodId
			FROM @tblQMProductPropertyValidityPeriod
			)

	INSERT INTO tblQMProductPropertyValidityPeriod (
		intConcurrencyId
		,intProductPropertyId
		,dtmValidFrom
		,dtmValidTo
		,strPropertyRangeText
		,dblMinValue
		,dblMaxValue
		,dblLowValue
		,dblHighValue
		,intUnitMeasureId
		,strFormula
		,strFormulaParser
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intConcurrencyId
		,intProductPropertyId
		,dtmValidFrom
		,dtmValidTo
		,strPropertyRangeText
		,dblMinValue
		,dblMaxValue
		,dblLowValue
		,dblHighValue
		,intUnitMeasureId
		,strFormula
		,strFormulaParser
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM @tblQMProductPropertyValidityPeriod
	WHERE intProductPropertyValidityPeriodId = 0

	UPDATE a
	SET a.intConcurrencyId = b.intConcurrencyId
		,a.dtmValidFrom = b.dtmValidFrom
		,a.dtmValidTo = b.dtmValidTo
		,a.strPropertyRangeText = b.strPropertyRangeText
		,a.dblMinValue = b.dblMinValue
		,a.dblMaxValue = b.dblMaxValue
		,a.dblLowValue = b.dblLowValue
		,a.dblHighValue = b.dblHighValue
		,a.intUnitMeasureId = b.intUnitMeasureId
		,a.strFormula = b.strFormula
		,a.strFormulaParser = b.strFormulaParser
		,a.intLastModifiedUserId = b.intLastModifiedUserId
		,a.dtmLastModified = b.dtmLastModified
	FROM tblQMProductPropertyValidityPeriod a
	JOIN @tblQMProductPropertyValidityPeriod b ON b.intProductPropertyValidityPeriodId = a.intProductPropertyValidityPeriodId

	-- Conditional Property Deletion & Creation & Updation
	DELETE
	FROM tblQMConditionalProductProperty
	WHERE intProductPropertyId = @intProductPropertyId
		AND intConditionalProductPropertyId NOT IN (
			SELECT intConditionalProductPropertyId
			FROM @tblQMConditionalProductProperty
			)

	INSERT INTO tblQMConditionalProductProperty (
		intProductPropertyId
		,intConcurrencyId
		,intOnSuccessPropertyId
		,intOnFailurePropertyId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intProductPropertyId
		,intConcurrencyId
		,intOnSuccessPropertyId
		,intOnFailurePropertyId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM @tblQMConditionalProductProperty
	WHERE intConditionalProductPropertyId = 0

	UPDATE a
	SET a.intConcurrencyId = b.intConcurrencyId
		,a.intOnSuccessPropertyId = b.intOnSuccessPropertyId
		,a.intOnFailurePropertyId = b.intOnFailurePropertyId
		,a.intLastModifiedUserId = b.intLastModifiedUserId
		,a.dtmLastModified = b.dtmLastModified
	FROM tblQMConditionalProductProperty a
	JOIN @tblQMConditionalProductProperty b ON b.intConditionalProductPropertyId = a.intConditionalProductPropertyId

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
