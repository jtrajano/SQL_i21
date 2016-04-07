CREATE VIEW [dbo].[vyuTRGetQuotePriceAdjustmentHeader]
	AS

SELECT QPAHeader.intQuotePriceAdjustmentHeaderId
	, QPAHeader.intCustomerGroupId
	, strCustomerGroup = CustomerGroup.strGroupName
	, QPAHeader.intEntityCustomerId
	, strCustomerName = Customer.strName
	, Customer.strCustomerNumber
	, QPAHeader.intSupplyPointId
	, SupplyPoint.strSupplyPoint
FROM tblTRQuotePriceAdjustmentHeader QPAHeader
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = QPAHeader.intEntityCustomerId
LEFT JOIN tblARCustomerGroup CustomerGroup ON CustomerGroup.intCustomerGroupId = QPAHeader.intCustomerGroupId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intSupplyPointId = QPAHeader.intSupplyPointId