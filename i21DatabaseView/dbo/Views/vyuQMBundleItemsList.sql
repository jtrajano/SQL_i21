CREATE VIEW vyuQMBundleItemsList
AS
SELECT IB.intItemId AS intItemBundleId
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.strType
	,I.intOriginId
	,ICA.strDescription AS strOriginName
	,CAST(ROW_NUMBER() OVER (
			ORDER BY IB.intItemId
				,I.strItemNo
			) AS INT) AS intRowNo
FROM dbo.tblICItemBundle IB
JOIN dbo.tblICItem I ON I.intItemId = IB.intBundleItemId
LEFT JOIN dbo.tblICCommodityAttribute ICA ON ICA.intCommodityAttributeId = I.intOriginId
