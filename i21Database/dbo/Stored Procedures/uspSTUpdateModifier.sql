CREATE PROCEDURE [dbo].[uspSTUpdateModifier]
	@intItemId AS INT,
	@strFamily AS VARCHAR(100),
	@strClass AS VARCHAR(100)
AS

BEGIN
	--Merge Family and Class to item Location 
	--To Sync on Item Quick Entry screen 
	--This will update all location Family and Class from what is selected on Item Quick Entry screen
	UPDATE tblICItemLocation
	SET intFamilyId = CASE WHEN @strFamily = '' THEN null ELSE (SELECT intSubcategoryId 
																	FROM tblSTSubcategory 
																	WHERE strSubcategoryType = 'F'
																	AND strSubcategoryId = @strFamily) END,
		intClassId = CASE WHEN @strClass = '' THEN null ELSE (SELECT intSubcategoryId 
																	FROM tblSTSubcategory 
																	WHERE strSubcategoryType = 'C'
																	AND strSubcategoryId = @strClass) END
	WHERE intItemId = @intItemId

END
			