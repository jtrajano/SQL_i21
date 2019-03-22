CREATE PROCEDURE [dbo].[uspQMGetTemplateNumber]
	@intItemId INT
	,@intControlPointId INT
	,@intSampleTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intProductId INT
DECLARE @intCategoryId INT

SET @intProductId = (
		SELECT P.intProductId
		FROM tblQMProduct AS P
		JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
		WHERE P.intProductTypeId = 2 -- Item
			AND P.intProductValueId = @intItemId
			AND PC.intSampleTypeId = @intSampleTypeId
			AND P.ysnActive = 1
		)

IF @intProductId IS NULL
BEGIN
	SET @intCategoryId = (
			SELECT intCategoryId
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId
			)
	SET @intProductId = (
			SELECT P.intProductId
			FROM tblQMProduct AS P
			JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
			WHERE P.intProductTypeId = 1 -- Item Category
				AND P.intProductValueId = @intCategoryId
				AND PC.intSampleTypeId = @intSampleTypeId
				AND P.ysnActive = 1
			)
END

IF @intProductId IS NULL
	SELECT 0 AS intProductId
ELSE
	SELECT @intProductId AS intProductId
