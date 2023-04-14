CREATE VIEW [dbo].[vyuCTGetQualityCodes]
AS
SELECT 
	IB.intItemId,
	I.strItemNo strQualityCode, 
	I.strDescription strQualityCodeDesc, 
	IB.strItemNo strQualityDescNo, 
	IB.strDescription strQualityDesc, 
	IB.strShortName,
	CA.strDescription strProductType,
	strCurrency = CASE WHEN CA.strDescription = 'Arabica' THEN
								'USC'
						WHEN CA.strDescription = 'Robusta' THEN
								'USD'
						ELSE ''
				   END,
	strUOM  = CASE WHEN CA.strDescription = 'Arabica' THEN
								'LBS'
						WHEN CA.strDescription = 'Robusta' THEN
								'MT'
						ELSE ''
				   END,
	STUFF((SELECT 
				strTemp = CASE WHEN B.strBook = 'Israel' THEN
									B.strBook + '-' + SB.strSubBook
								ELSE
									B.strBook
								 END + ', ' 
				FROM tblICItemBook BB JOIN tblCTBook B ON B.intBookId = BB.intBookId AND BB.intItemId = IB.intItemId
									LEFT JOIN tblCTSubBook SB ON SB.intBookId = BB.intBookId AND SB.intSubBookId = BB.intSubBookId
										FOR XML PATH('')
											,TYPE
										).value('.', 'varchar(max)'), 1, 0, '') strBook
FROM tblICItemBundle BI
JOIN tblICItem I ON I.intItemId = BI.intItemId
JOIN tblICItem IB ON IB.intItemId = BI.intBundleItemId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IB.intProductTypeId AND CA.strType='ProductType'
WHERE IB.strStatus IN ('Active', 'Phased Out')
GO


