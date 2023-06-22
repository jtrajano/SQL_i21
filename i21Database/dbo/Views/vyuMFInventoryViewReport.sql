CREATE VIEW [dbo].[vyuMFInventoryViewReport]
AS 
/****************************************************************
	Title: Inventory View Report
	Description: Inventory View Report intended for Strauss 
	JIRA: MFG-4596 
	HD: HDTN-275494  
	Created By: Jonathan Valenzuela
	Date: 06/22/2023
*****************************************************************/
SELECT strLotNumber				AS [Item]
	 , strParentLotNumber		AS [Parent Lot No]
	 , strPrimaryStatus			AS [Status]
	 , strItemNo				AS [Item Number]
	 , strItemDescription		AS [Item Desc.]
	 , strItemCategory			AS [Category]
	 , strOwnershipType			AS [Ownership Type]
	 , strCompanyLocationName	AS [Location]
	 , strSubLocationName		AS [Storage Location]
	 , strStorageLocationName	AS [Storage Unit]
	 , dblWeight				AS [Qty]
	 , strWeightUOM				AS [UOM]
	 , dblWeightPerQty			AS [Weight Per Unit]
	 , dblQty					AS [No of Packs]
	 , strQtyUOM				AS [Packing UOM]
	 , dblAvailableQty			AS [Available Qty]
	 , dblAvailableNoOfPacks	AS [Available No of Packs]
	 , intUnitPallet			AS [Units per Pallet]
	 , dtmLastMoveDate			AS [Last Transaction Date]
	 , dtmDateCreated			AS [Create Date]
	 , dtmManufacturedDate		AS [Manufacturing Date]
	 , dtmExpiryDate			AS [Expiry Date]
	 , dtmDueDate				AS [Due Date]
	 , strVendor				AS [Vendor]
	 , dblLastCost				AS [Unit Cost]
	 , strRestrictionType		AS [Restriction Type]
	 , strBondStatus			AS [Bonded Status]
	 , strContainerNo			AS [Container No]
	 , strVendorRefNo			AS [Vendor Ref No]
	 , strWarehouseRefNo		AS [WH Ref No / Order Entry No]
	 , strReceiptNo				AS [Receipt No]
	 , ysnPartialPallet			AS [Partial Pallet]
	 , strNotes					AS [Remarks]
	 , intAge					AS [Age(Days)]
	 , intRemainingLife			AS [Remaining Life(Days)]
FROM vyuMFInventoryView