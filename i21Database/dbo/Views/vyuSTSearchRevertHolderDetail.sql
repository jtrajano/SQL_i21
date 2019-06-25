CREATE VIEW [dbo].[vyuSTSearchRevertHolderDetail]
AS
SELECT 
	RHD.intRevertHolderDetailId
	, RHD.intRevertHolderId
	, RHD.strTableName
	, RHD.strTableColumnName
	, RHD.strTableColumnDataType
	, RHD.intPrimaryKeyId
	, RHD.intItemId
	, RHD.intItemUOMId
	, RHD.intItemLocationId
	, RHD.intCompanyLocationId
	, RHD.dtmDateModified
	, RHD.strChangeDescription
	, RHD.strOldData
	, RHD.strNewData
	, Item.strItemNo
	, Item.strDescription AS strItemDescription
	, Uom.strLongUPCCode
	, CompanyLoc.strLocationName
FROM tblSTRevertHolderDetail RHD
INNER JOIN tblICItem Item
	ON RHD.intItemId = Item.intItemId
INNER JOIN tblICItemUOM Uom
	ON RHD.intItemUOMId = Uom.intItemUOMId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON RHD.intCompanyLocationId = CompanyLoc.intCompanyLocationId