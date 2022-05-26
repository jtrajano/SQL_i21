CREATE VIEW [dbo].[vyuICSearchStockReservation]
AS

SELECT 
Reservation.intStockReservationId,
CompanyLocation.strLocationName,
Reservation.intTransactionId,
Reservation.strTransactionId,
Reservation.dtmDateCreated,
Reservation.intInventoryTransactionType,
Item.strItemNo,
Item.strDescription,
Category.strCategoryCode,
Commodity.strCommodityCode,
Transact.dblOnHandQty,
CASE WHEN (Reservation.ysnPosted = 1 AND Invoice.ysnPosted = 1) THEN	
	0
ELSE
	Reservation.dblQty
END  dblReservedQty,
dblTotalQty = ISNULL(Transact.dblOnHandQty, 0) + ISNULL(TotalReserved.dblQty, 0)
FROM tblICStockReservation Reservation
INNER JOIN (
	tblICItem Item 
	LEFT JOIN tblICCommodity Commodity
	ON
	Item.intCommodityId = Commodity.intCommodityId
	LEFT JOIN tblICCategory Category
	ON
	Item.intCategoryId = Category.intCategoryId
) ON
Reservation.intItemId = Item.intItemId
LEFT JOIN tblSMCompanyLocation CompanyLocation
ON
Reservation.intLocationId = CompanyLocation.intCompanyLocationId
OUTER APPLY (
	SELECT TOP 1 
		SUM(dblQty) AS dblOnHandQty 
		FROM tblICInventoryTransaction 
		WHERE 
		intItemId = Reservation.intItemId 
		AND
		intItemLocationId = Reservation.intItemLocationId
) AS Transact
OUTER APPLY
(
	SELECT TOP 1
		SUM(dblQty) AS dblQty
		FROM tblICStockReservation
		WHERE 
		intItemId = Reservation.intItemId
		AND
		intItemLocationId = Reservation.intItemLocationId
) AS TotalReserved
LEFT JOIN tblARInvoice AS Invoice ON Reservation.strTransactionId  = Invoice.strInvoiceNumber 