CREATE VIEW [dbo].[vyuICGetCountSheet]
	AS 

SELECT Header.intLocationId
	, Header.intCommodityId
	, Header.strCommodity
	, Header.strCountNo
	, Header.dtmCountDate
	, Detail.*
	, Header.ysnCountByLots
	, Header.ysnCountByPallets
	, Header.ysnIncludeOnHand
	, Header.ysnIncludeZeroOnHand
	, dblPalletsBlank = null
	, dblQtyPerPalletBlank = null
	, dblPhysicalCountBlank = null
FROM vyuICGetInventoryCountDetail Detail
	LEFT JOIN vyuICGetInventoryCount Header ON Header.intInventoryCountId = Detail.intInventoryCountId
