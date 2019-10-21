CREATE FUNCTION [dbo].[fnQMGetTemplateNames]
	(@intTestId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strTemplateNames NVARCHAR(MAX)

	SET @strTemplateNames = ''

	SELECT @strTemplateNames = @strTemplateNames + ProductValueName + ', '
	FROM (
		SELECT I.strItemNo AS ProductValueName
		FROM tblQMProductTest PT
		JOIN tblQMProduct PRD ON PRD.intProductId = PT.intProductId
		JOIN tblICItem I ON I.intItemId = PRD.intProductValueId
		WHERE PRD.intProductTypeId = 2
			AND PT.intTestId = @intTestId
		
		UNION
		
		SELECT C.strCategoryCode AS ProductValueName
		FROM tblQMProductTest PT
		JOIN tblQMProduct PRD ON PRD.intProductId = PT.intProductId
		JOIN tblICCategory C ON C.intCategoryId = PRD.intProductValueId
		WHERE PRD.intProductTypeId = 1
			AND PT.intTestId = @intTestId
		
		UNION
		
		SELECT QPT.strProductTypeName AS ProductValueName
		FROM tblQMProductTest PT
		JOIN tblQMProduct PRD ON PRD.intProductId = PT.intProductId
		JOIN tblQMProductType QPT ON QPT.intProductTypeId = PRD.intProductTypeId
		WHERE PRD.intProductTypeId NOT IN (
				1
				,2
				)
			AND PT.intTestId = @intTestId
		) t

	IF LEN(@strTemplateNames) > 0
		SET @strTemplateNames = Left(@strTemplateNames, LEN(@strTemplateNames) - 1)

	RETURN @strTemplateNames
END
