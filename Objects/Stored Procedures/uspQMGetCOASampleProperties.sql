CREATE PROCEDURE uspQMGetCOASampleProperties
     @intLotId INT
	,@intItemId INT
	,@strItemNo NVARCHAR(50)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @ysnEnableParentLot BIT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT

	SET @intProductTypeId = 6
	SET @intProductValueId = @intLotId

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM dbo.tblQMCompanyPreference

	IF @ysnEnableParentLot = 1
	BEGIN
		SET @intProductTypeId = 11

		SELECT @intProductValueId = intParentLotId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId
	END

	SELECT DISTINCT P.intPropertyId
		,PRD.intProductId
		,P.strPropertyName
		,@strItemNo AS strTemplate
		,'' AS strTestType
		,CAST(0 AS BIT) AS ysnIsRequired
		,'' AS strTestMethodName
		,'' AS strSpecification
	FROM dbo.tblQMTestResult TR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		AND TR.intProductTypeId = @intProductTypeId
	JOIN dbo.tblQMProduct PRD ON PRD.intProductId = TR.intProductId
		AND PRD.ysnActive = 1
		AND TR.intProductValueId = @intProductValueId
END
