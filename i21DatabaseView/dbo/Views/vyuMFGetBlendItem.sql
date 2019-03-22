CREATE VIEW vyuMFGetBlendItem
AS
SELECT I.strItemNo AS strWIPItemNo
	,I.strDescription
FROM dbo.tblICItem I
JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
WHERE C.strCategoryCode = 'Blend'
