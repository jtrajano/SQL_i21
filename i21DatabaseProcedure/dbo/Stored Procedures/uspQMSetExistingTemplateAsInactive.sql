CREATE PROCEDURE uspQMSetExistingTemplateAsInactive
     @intProductId INT
	,@intProductTypeId INT
	,@intProductValueId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intProductTypeId = 1
	OR @intProductTypeId = 2
BEGIN
	UPDATE P
	SET P.ysnActive = 0
	FROM tblQMProduct P
	JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
	WHERE P.intProductTypeId = @intProductTypeId
		AND P.intProductValueId = @intProductValueId
		AND P.intProductId <> @intProductId
		AND PC.intSampleTypeId IN (
			SELECT PC1.intSampleTypeId
			FROM tblQMProductControlPoint PC1
			WHERE PC1.intProductId = @intProductId
			)
END
ELSE
BEGIN
	UPDATE P
	SET P.ysnActive = 0
	FROM tblQMProduct P
	JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
	WHERE P.intProductTypeId = @intProductTypeId
		AND P.intProductId <> @intProductId
		AND PC.intSampleTypeId IN (
			SELECT PC1.intSampleTypeId
			FROM tblQMProductControlPoint PC1
			WHERE PC1.intProductId = @intProductId
			)
END
