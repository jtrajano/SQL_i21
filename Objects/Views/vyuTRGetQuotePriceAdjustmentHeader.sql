CREATE VIEW [dbo].[vyuTRGetQuotePriceAdjustmentHeader]
	AS

SELECT QPAHeader.intQuotePriceAdjustmentHeaderId
	, QPAHeader.intCustomerGroupId
	, strCustomerGroup = CustomerGroup.strGroupName
	, QPAHeader.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, QPAHeader.intSupplyPointId
	, SupplyPoint.intEntityVendorId
	, SupplyPoint.strFuelSupplier
	, SupplyPoint.intEntityLocationId
	, SupplyPoint.strSupplyPoint
FROM tblTRQuotePriceAdjustmentHeader QPAHeader
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = QPAHeader.intEntityCustomerId
LEFT JOIN tblARCustomerGroup CustomerGroup ON CustomerGroup.intCustomerGroupId = QPAHeader.intCustomerGroupId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = QPAHeader.intSupplyPointId