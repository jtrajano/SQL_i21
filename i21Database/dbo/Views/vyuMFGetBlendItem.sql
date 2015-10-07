CREATE VIEW vyuMFGetBlendItem
AS
SELECT strItemNo as strWIPItemNo
	,strDescription
FROM dbo.tblICItem
WHERE strType = 'Assembly/Blend'
