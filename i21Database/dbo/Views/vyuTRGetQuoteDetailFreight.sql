CREATE VIEW [dbo].[vyuTRGetQuoteDetailFreight]
	AS
	
SELECT QD.intQuoteDetailId
	, intItemId = Pref.intItemForFreightId
	, Item.strItemNo
	, dblFreight = ISNULL(QD.dblFreightRate, 0)
FROM tblTRQuoteDetail QD
JOIN tblTRCompanyPreference Pref ON ISNULL(Pref.intItemForFreightId, '') <> ''
LEFT JOIN tblICItem Item ON Item.intItemId = Pref.intItemForFreightId
WHERE ISNULL(QD.dblFreightRate, 0) <> 0