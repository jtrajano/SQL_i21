--liquibase formatted sql

-- changeset Von:vyuICGetItemFactoryManufacturingCell.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetItemFactoryManufacturingCell]
	AS 
	
SELECT ifmc.intItemFactoryManufacturingCellId
	, ifmc.intItemFactoryId
	, ItemFactory.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, ItemFactory.intFactoryId
	, Factory.strLocationName
	, ifmc.intManufacturingCellId
	, ManufacturingCell.strCellName
	, strManufacturingCellDescription = ManufacturingCell.strDescription
	, ifmc.ysnDefault
	, ifmc.intPreference
	, ifmc.intSort
FROM tblICItemFactoryManufacturingCell ifmc
LEFT JOIN tblICItemFactory ItemFactory ON ItemFactory.intItemFactoryId = ifmc.intItemFactoryId
LEFT JOIN tblICItem Item ON Item.intItemId = ItemFactory.intItemId
LEFT JOIN tblSMCompanyLocation Factory ON Factory.intCompanyLocationId = ItemFactory.intFactoryId
LEFT JOIN tblMFManufacturingCell ManufacturingCell ON ManufacturingCell.intManufacturingCellId = ifmc.intManufacturingCellId



