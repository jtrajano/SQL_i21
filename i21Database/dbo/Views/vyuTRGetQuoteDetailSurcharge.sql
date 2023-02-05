CREATE VIEW [dbo].[vyuTRGetQuoteDetailSurcharge]
	AS
	
SELECT QD.intQuoteDetailId
	, intItemId = Pref.intItemForFreightId
	, strItemNo = Item.strItemNo + CASE WHEN ISNULL(QD.dblSurcharge, 0) <> 0 THEN ' - ' + CAST(FORMAT(((ISNULL(QD.dblSurcharge, 0) / ISNULL(QD.dblFreightRate, 0)) * 100), 'N2') AS NVARCHAR) + '%' END 
	, dblSurcharge = ISNULL(QD.dblSurcharge, 0)
FROM tblTRQuoteDetail QD
JOIN tblTRCompanyPreference Pref ON ISNULL(Pref.intSurchargeItemId, '') <> ''
LEFT JOIN tblICItem Item ON Item.intItemId = Pref.intSurchargeItemId
WHERE ISNULL(QD.dblSurcharge, 0) <> 0