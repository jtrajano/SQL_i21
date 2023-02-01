CREATE VIEW [dbo].[vyuTRGetQuoteDetailSurcharge]
	AS
	
SELECT QD.intQuoteDetailId
	, intItemId = Pref.intItemForFreightId
	, Item.strItemNo
	, dblSurcharge = ISNULL(QD.dblSurcharge, 0)
FROM tblTRQuoteDetail QD
JOIN tblTRCompanyPreference Pref ON ISNULL(Pref.intSurchargeItemId, '') <> ''
LEFT JOIN tblICItem Item ON Item.intItemId = Pref.intSurchargeItemId
WHERE ISNULL(QD.dblSurcharge, 0) <> 0