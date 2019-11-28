CREATE VIEW dbo.vyuIPGetItemUOM
AS
SELECT intItemId
	,UM.strUnitMeasure
	,IU.dblUnitQty
	,IU.dblWeight
	,WUM.strUnitMeasure AS strWeightUnitMeasure
	,IU.strUpcCode
	,IU.strLongUPCCode
	,IU.ysnStockUnit
	,IU.ysnAllowPurchase
	,IU.ysnAllowSale
	,IU.dblLength
	,IU.dblWidth
	,IU.dblHeight
	,DUM.strUnitMeasure AS strDimensionUnitMeasure
	,IU.dblVolume
	,intVolumeUOMId
	,VUM.strUnitMeasure AS strVolumeUnitMeasure
	,IU.dblMaxQty
	,IU.ysnStockUOM
	,DS.strSourceName
	,IU.intUpcCode
	,IU.intSort
	,IU.intConcurrencyId
	,IU.dtmDateCreated
	,IU.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemUOM IU
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = IU.intWeightUOMId
LEFT JOIN tblICUnitMeasure VUM ON VUM.intUnitMeasureId = IU.intVolumeUOMId
LEFT JOIN tblICUnitMeasure DUM ON DUM.intUnitMeasureId = IU.intDimensionUOMId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IU.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IU.intModifiedByUserId
LEFT JOIN tblICDataSource DS ON DS.intDataSourceId = IU.intDataSourceId
