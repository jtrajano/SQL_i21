CREATE VIEW vyuSTStorePumpItem
AS
SELECT 
	PU.intStorePumpItemId
	, PU.intStoreId
	, PU.intItemUOMId
	, PU.dblPrice
	, PU.intTaxGroupId
	, PU.intCategoryId
	, CAT.strCategoryCode
	, I.strItemNo
	, UOM.strLongUPCCode
	, I.strDescription AS strPumpItemDescription
	, TG.strTaxGroup
	, PU.intConcurrencyId
FROM tblSTPumpItem PU
JOIN tblICItemUOM UOM 
	ON PU.intItemUOMId = UOM.intItemUOMId
JOIN tblICCategory CAT
	ON PU.intCategoryId = CAT.intCategoryId
JOIN tblICItem I
	ON UOM.intItemId = I.intItemId
JOIN tblSTStore ST
	ON PU.intStoreId = ST.intStoreId
JOIN tblSMTaxGroup TG
	ON ST.intTaxGroupId = TG.intTaxGroupId