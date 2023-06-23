CREATE VIEW [dbo].[vyuICSearchItemCustomerXref]
AS
SELECT
	Item.intItemId,
	CustomerXref.intItemCustomerXrefId,
	Item.strItemNo,
	Item.strDescription,
	ItemLocation.strLocationName,
	Customer.strName,
	CustomerXref.strCustomerProduct,
	CustomerXref.strProductDescription,
	CustomerXref.strPickTicketNotes
FROM tblICItemCustomerXref CustomerXref
INNER JOIN tblICItem Item
ON
CustomerXref.intItemId = Item.intItemId
LEFT JOIN vyuICGetItemLocation ItemLocation
ON
CustomerXref.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN vyuARCustomer Customer
ON
CustomerXref.intCustomerId = Customer.intEntityId