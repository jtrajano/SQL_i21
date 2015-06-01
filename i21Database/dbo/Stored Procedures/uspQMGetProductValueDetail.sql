CREATE PROCEDURE uspQMGetProductValueDetail
	@intProductTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intProductTypeId = 1
BEGIN
	SELECT intCategoryId AS intProductValueId
		,strCategoryCode AS strProductValue
		,strDescription
	FROM tblICCategory
	ORDER BY strCategoryCode
END
ELSE IF @intProductTypeId = 2
BEGIN
	SELECT intItemId AS intProductValueId
		,strItemNo AS strProductValue
		,strDescription
	FROM tblICItem
	WHERE strStatus = 'Active'
	ORDER BY strItemNo
END
