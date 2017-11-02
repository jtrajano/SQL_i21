CREATE VIEW [dbo].[vyuICItemLicense]
	AS
SELECT	ItemLic.intItemLicenseId,
		ItemLic.intItemId,
		Item.strItemNo,
		strItemDescription = Item.strDescription,
		LicType.intLicenseTypeId,
		LicType.strCode,
		strCodeDescription = LicType.strDescription,
		ItemLic.intConcurrencyId
FROM tblICItemLicense ItemLic
INNER JOIN tblICItem Item
	ON Item.intItemId = ItemLic.intItemId
INNER JOIN tblSMLicenseType LicType
	ON LicType.intLicenseTypeId = ItemLic.intLicenseTypeId