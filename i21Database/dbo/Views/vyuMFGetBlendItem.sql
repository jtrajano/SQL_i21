CREATE VIEW vyuMFGetBlendItem
AS
SELECT strItemNo
	,strDescription
FROM dbo.tblICItem
WHERE strType = 'Blend'
