CREATE VIEW [dbo].[vyuMFItemManufacturingCell]
AS
/*
	Created By: Jonathan Valenzuela
	Date: 11/24/2022
	Purpose: Return Location based on Item Factory
	JIRA: http://jira.irelyserver.com/browse/MFG-4723
*/

	SELECT Item.intItemId
	     , Cell.intManufacturingCellId
		 , Cell.strCellName
		 , ItemFactory.intFactoryId AS intLocationId
		 , Cell.intSubLocationId
		 , CLSL.strSubLocationName 
	FROM tblICItem AS Item
	JOIN tblICItemFactory AS ItemFactory on Item.intItemId = ItemFactory.intItemId 
	JOIN tblICItemFactoryManufacturingCell AS FactoryCell on ItemFactory.intItemFactoryId=FactoryCell.intItemFactoryId 
	JOIN tblMFManufacturingCell AS Cell on FactoryCell.intManufacturingCellId=Cell.intManufacturingCellId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = Cell.intSubLocationId
GO


