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
		,strPropertyName NVARCHAR(100)
		,intProductId INT
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,intTestId INT
		,strTestName NVARCHAR(50)
		,intSequenceNo INT
	   )

	DECLARE @tblComputedValue AS TABLE
	   (
	     intWorkOrderRecipeComputationId INT IDENTITY(1, 1)
	    ,intTestId INT
		,strTestName NVARCHAR(50)
		,intPropertyId INT
		,strPropertyName NVARCHAR(100)
		,dblComputedValue NUMERIC(18,6)
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,strMethodName NVARCHAR(50)
		,intMethodId INT
		,intSequenceNo int
	   )

		DECLARE @tblLot AS TABLE
	   (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQty NUMERIC(18,6)
	   )

	SET @intValidDate = (
		SELECT DATEPART(dy, GETDATE())
		)

	INSERT INTO @tblProductProperty
	SELECT DISTINCT PRT.intPropertyId
		,PRT.strPropertyName
		,PRD.intProductValueId
		,MIN(PPV.dblMinValue)
		,MAX(PPV.dblMaxValue)
		,TST.intTestId
		,TST.strTestName
		,PP.intSequenceNo
	FROM tblQMProduct PRD
	JOIN tblQMProductProperty PP ON PP.intProductId=PRD.intProductId
	JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
	JOIN tblQMProperty PRT ON PRT.intPropertyId = PP.intPropertyId
	JOIN tblQMTestProperty TP ON TP.intPropertyId=PRT.intPropertyId and PP.intTestId =TP.intTestId
	JOIN tblQMTest TST ON TST.intTestId = TP.intTestId
	WHERE PRD.intProductValueId = @intProductId AND PRD.intProductTypeId = 2
	AND PRD.ysnActive = 1
	AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
	AND DATEPART(dy, PPV.dtmValidTo)
	Group by PRT.intPropertyId
		,PRT.strPropertyName
		,PRD.intProductValueId
		,TST.intTestId
		,TST.strTestName
		,PP.intSequenceNo
	ORDER BY PP.intSequenceNo

	If @ysnEnableParentLot=0
		INSERT INTO @tblLot(intLotId,strLotNumber,dblQty)
		SELECT x.intLotId,l.strLotNumber,x.dblQty
		FROM OPENXML(@idoc, 'root/lot', 2) WITH (intLotId INT,dblQty NUMERIC(18,6)) x Join tblICLot l on x.intLotId=l.intLotId
	Else
		INSERT INTO @tblLot(intLotId,dblQty)
		SELECT intLotId,dblQty
		FROM OPENXML(@idoc, 'root/lot', 2) WITH (intLotId INT,dblQty NUMERIC(18,6))

	SELECT @strMethod=strName FROM tblMFWorkOrderRecipeComputationMethod WHERE intMethodId=1

	--Blend Management/Production
	IF ( @ysnEnableParentLot=0 )
	BEGIN
			INSERT INTO @tblComputedValue(intTestId,strTestName,intPropertyId,strPropertyName,dblComputedValue,dblMinValue,dblMaxValue,strMethodName,intMethodId,intSequenceNo)
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
				,MIN(TR.intSequenceNo)
			FROM @tblProductProperty PP
			JOIN tblQMTestResult AS TR ON PP.intPropertyId = TR.intPropertyId AND ISNUMERIC(TR.strPropertyValue) = 1
			JOIN tblICLot lt ON lt.intLotId=TR.intProductValueId
			JOIN @tblLot AS L ON L.strLotNumber = lt.strLotNumber
				AND TR.intProductTypeId = @intProductTypeId
				AND TR.intSampleId = (SELECT MAX(intSampleId) 
				FROM tblQMTestResult tr WHERE tr.intProductValueId = lt.intLotId AND tr.intProductTypeId = @intProductTypeId)
			GROUP BY 
				 PP.intPropertyId
				,PP.strPropertyName
				,PP.intTestId
				,PP.strTestName
				,PP.dblMinValue
				,PP.dblMaxValue
	END
	Else
	BEGIN
			INSERT INTO @tblComputedValue(intTestId,strTestName,intPropertyId,strPropertyName,dblComputedValue,dblMinValue,dblMaxValue,strMethodName,intMethodId,intSequenceNo)
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
				,MIN(TR.intSequenceNo)
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
	END

	SELECT * FROM @tblComputedValue Order by intSequenceNo

	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  