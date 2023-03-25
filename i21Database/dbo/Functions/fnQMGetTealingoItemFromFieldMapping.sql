CREATE FUNCTION [dbo].[fnQMGetTealingoItemFromFieldMapping](
    @intSampleId INT
)
RETURNS INT
AS BEGIN
    DECLARE @intItemId INT

    SELECT TOP 1 @intItemId=ITEM.intItemId
    FROM tblQMSample S
    -- Sustainability / Rain Forest
    LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
    -- Origin
    LEFT JOIN (tblICCommodityAttribute CA INNER JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = CA.intCountryID) ON CA.intCommodityAttributeId = S.intCountryID
    -- Size
    LEFT JOIN tblICBrand SIZE ON SIZE.intBrandId = S.intBrandId
    -- Style
    LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
    LEFT JOIN tblICItem ITEM ON ITEM.strItemNo LIKE SIZE.strBrandCode -- Leaf Size
        -- TODO: To update filter once Sub Cluster is provided
        + '%' -- To be updated by sub cluster
        + STYLE.strName -- Leaf Style
        + ORIGIN.strISOCode -- Origin
        + (Case When SUSTAINABILITY.strDescription <> '' Then '-' + SUSTAINABILITY.strDescription Else '' End) -- Rain Forest / Sustainability
    WHERE S.intSampleId = @intSampleId
    Group by ITEM.intItemId
    ORDER BY COUNT(1) Desc
    
    RETURN @intItemId    
END