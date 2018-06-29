CREATE PROCEDURE uspQMGetProductValueDetail
	@intProductTypeId INT
	,@intProductValueId INT
	,@strProductValue NVARCHAR(50)
	,@intCount INT = 0 OUTPUT
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
	WHERE intCategoryId = (
			CASE 
				WHEN @intProductValueId > 0
					THEN @intProductValueId
				ELSE intCategoryId
				END
			)
		AND strCategoryCode LIKE '%' + @strProductValue + '%'
	ORDER BY strCategoryCode

	SELECT @intCount = COUNT(*)
	FROM tblICCategory
	WHERE intCategoryId = (
			CASE 
				WHEN @intProductValueId > 0
					THEN @intProductValueId
				ELSE intCategoryId
				END
			)
		AND strCategoryCode LIKE '%' + @strProductValue + '%'
END
ELSE IF @intProductTypeId = 2
BEGIN
	SELECT intItemId AS intProductValueId
		,strItemNo AS strProductValue
		,strDescription
	FROM tblICItem
	WHERE strStatus = 'Active'
		AND intItemId = (
			CASE 
				WHEN @intProductValueId > 0
					THEN @intProductValueId
				ELSE intItemId
				END
			)
		AND strItemNo LIKE '%' + @strProductValue + '%'
	ORDER BY strItemNo

	SELECT @intCount = COUNT(*)
	FROM tblICItem
	WHERE strStatus = 'Active'
		AND intItemId = (
			CASE 
				WHEN @intProductValueId > 0
					THEN @intProductValueId
				ELSE intItemId
				END
			)
		AND strItemNo LIKE '%' + @strProductValue + '%'
END
