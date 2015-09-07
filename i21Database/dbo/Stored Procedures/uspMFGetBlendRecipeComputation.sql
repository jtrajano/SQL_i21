CREATE PROCEDURE [dbo].[uspMFGetBlendRecipeComputation]
	@strXml nVarchar(Max),
	@intTypeId int,
	@intProductId int
AS
	DECLARE @idoc int,
			@strMethod NVARCHAR(50),
			@intValidDate INT,
			@ysnEnableParentLot bit=0,
			@intProductTypeId int

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference

	If @ysnEnableParentLot=0
		Set @intProductTypeId=6 --Lot
	Else
		Set @intProductTypeId=11 --Parent Lot

	DECLARE @tblProductProperty AS TABLE
	   (
		 intRowNo INT IDENTITY(1, 1)
		,intPropertyId INT
		,strPropertyName NVARCHAR(50)
		,intProductId INT
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,intTestId INT
		,strTestName NVARCHAR(50)
		,intSequenceNo INT
	   )

	DECLARE @tblBlendManagement AS TABLE
	   (
	     intWorkOrderRecipeComputationId INT IDENTITY(1, 1)
	    ,intTestId INT
		,strTestName NVARCHAR(50)
		,intPropertyId INT
		,strPropertyName NVARCHAR(50)
		,dblComputedValue NUMERIC(18,6)
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,strMethodName NVARCHAR(50)
		,intMethodId INT
	   )

	DECLARE @tblBlendProduction AS TABLE
	   (
	     intRowNo INT IDENTITY(1, 1)
	    ,intTestId INT
		,strTestName NVARCHAR(50)
		,intPropertyId INT
		,strPropertyName NVARCHAR(50)
		,dblComputedValue NUMERIC(18,6)
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,strMethodName NVARCHAR(50)
		,intMethodId INT
	   )

		DECLARE @tblLot AS TABLE
	   (
		intLotId INT
		,dblQty NUMERIC(18,6)
	   )

	SET @intValidDate = (
		SELECT DATEPART(dy, GETDATE())
		)

	INSERT INTO @tblProductProperty
	SELECT DISTINCT PRT.intPropertyId
		,PRT.strPropertyName
		,PRD.intProductValueId
		,PPV.dblMinValue
		,PPV.dblMaxValue
		,TST.intTestId
		,TST.strTestName
		,PP.intSequenceNo
	FROM tblQMProduct PRD
	JOIN tblQMProductProperty PP ON PP.intProductId=PRD.intProductId
	JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
	JOIN tblQMProperty PRT ON PRT.intPropertyId = PP.intPropertyId
	JOIN tblQMTestProperty TP ON TP.intPropertyId=PRT.intPropertyId
	JOIN tblQMTest TST ON TST.intTestId = TP.intTestId
	WHERE PRD.intProductValueId = @intProductId AND PRD.intProductTypeId = 2
	AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
	AND DATEPART(dy, PPV.dtmValidTo)
	ORDER BY PP.intSequenceNo

	INSERT INTO @tblLot(intLotId,dblQty)
	SELECT intLotId,dblQty
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (intLotId INT,dblQty NUMERIC(18,6))

	SELECT @strMethod=strName FROM tblMFWorkOrderRecipeComputationMethod WHERE intMethodId=1

	--Blend Management
	IF ( @intTypeId=1 )
	BEGIN
			INSERT INTO @tblBlendManagement(intTestId,strTestName,intPropertyId,strPropertyName,dblComputedValue,dblMinValue,dblMaxValue,strMethodName,intMethodId)
			SELECT 
				 PP.intTestId
				,PP.strTestName
				,PP.intPropertyId
				,PP.strPropertyName
				,SUM(L.dblQty * ISNULL(TR.strPropertyValue, 0)) / SUM(L.dblQty) AS dblComputedValue
				,PP.dblMinValue
				,PP.dblMaxValue
				,MIN(@strMethod) AS strMethodName
				,1 AS intMethodId
			FROM @tblProductProperty PP
			JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId AND ISNUMERIC(TR.strPropertyValue) = 1
			JOIN @tblLot AS L ON L.intLotId = TR.intProductValueId
				AND TR.intProductTypeId = @intProductTypeId
				AND TR.intSampleId = (SELECT MAX(intSampleId) 
				FROM tblQMTestResult tr WHERE tr.intProductValueId = L.intLotId AND tr.intProductTypeId = @intProductTypeId)
			GROUP BY 
				 PP.intPropertyId
				,PP.strPropertyName
				,PP.intTestId
				,PP.strTestName
				,PP.dblMinValue
				,PP.dblMaxValue

		SELECT * FROM @tblBlendManagement
	END

	--Blend Production
	IF ( @intTypeId=2 )
	BEGIN
			INSERT INTO @tblBlendProduction(intTestId,strTestName,intPropertyId,strPropertyName,dblComputedValue,dblMinValue,dblMaxValue,strMethodName,intMethodId)
			SELECT 
				 PP.intTestId
				,PP.strTestName
				,PP.intPropertyId
				,PP.strPropertyName
				,SUM(L.dblQty * ISNULL(TR.strPropertyValue, 0)) / SUM(L.dblQty) AS dblComputedValue
				,PP.dblMinValue
				,PP.dblMaxValue
				,MIN(@strMethod) AS strMethodName
				,1 AS intMethodId
			FROM @tblProductProperty PP
			JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId AND ISNUMERIC(TR.strPropertyValue) = 1
			JOIN @tblLot AS L ON L.intLotId = TR.intProductValueId
				AND TR.intProductTypeId = @intProductTypeId
				AND TR.intSampleId = (SELECT MAX(intSampleId) 
				FROM tblQMTestResult tr WHERE tr.intProductValueId = L.intLotId AND tr.intProductTypeId = @intProductTypeId)
			GROUP BY 
				 PP.intPropertyId
				,PP.strPropertyName
				,PP.intTestId
				,PP.strTestName
				,PP.dblMinValue
				,PP.dblMaxValue

		SELECT * FROM @tblBlendProduction
	END

	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  