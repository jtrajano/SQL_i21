CREATE VIEW [dbo].[vyuPODetails]
AS
SELECT
	B.intPurchaseDetailId
	,B.intPurchaseId
	,A.strPurchaseOrderNumber
	,B.intItemId
	,B.intUnitOfMeasureId
	,B.intAccountId
	,B.intTaxId
	,B.intStorageLocationId
	,B.intLocationId
	,B.intSubLocationId
	,B.dblQtyOrdered
	,B.dblQtyReceived
	,B.dblQtyContract
	,B.dblVolume
	,B.dblWeight
	,B.dblDiscount
	,B.dblCost
	,B.dblTotal
	,B.dtmExpectedDate
	,B.strDescription
	,B.strPONumber
	,B.intLineNo
FROM tblPOPurchase A
	LEFT JOIN  tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	
