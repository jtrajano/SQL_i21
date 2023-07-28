--liquibase formatted sql

-- changeset Von:vyuICGetEffectiveItemPrice.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetEffectiveItemPrice]
	AS 

SELECT
	EffectiveItemPrice.intEffectiveItemPriceId,
	EffectiveItemPrice.intItemId,
	Item.strItemNo,
	EffectiveItemPrice.intItemLocationId,
	ItemLocation.strLocationName,
	EffectiveItemPrice.dblRetailPrice,
	EffectiveItemPrice.dtmEffectiveRetailPriceDate,
	EffectiveItemPrice.intItemUOMId,
	ItemUOM.strUnitMeasure,
	EffectiveItemPrice.intConcurrencyId,
	EffectiveItemPrice.dtmDateCreated,
	EffectiveItemPrice.dtmDateModified,
	EffectiveItemPrice.intCreatedByUserId,
	EffectiveItemPrice.intModifiedByUserId,
	EffectiveItemPrice.intDataSourceId,
	EffectiveItemPrice.intImportFlagInternal
FROM 
	tblICEffectiveItemPrice EffectiveItemPrice
INNER JOIN
	tblICItem Item
	ON
		EffectiveItemPrice.intItemId = Item.intItemId
INNER JOIN
	vyuICGetItemLocation ItemLocation
	ON
		EffectiveItemPrice.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN
	vyuICGetItemUOM ItemUOM
	ON
		EffectiveItemPrice.intItemUOMId = ItemUOM.intItemUOMId



