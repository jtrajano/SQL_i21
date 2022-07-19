CREATE PROCEDURE [dbo].[uspLGFixStartingNumbers]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	/* Allocation */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strAllocationNumber, '')
		FROM tblLGAllocationHeader 
		WHERE intAllocationHeaderId = (SELECT MAX(intAllocationHeaderId) FROM tblLGAllocationHeader WHERE CHARINDEX(A.strPrefix, strAllocationNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Allocations' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Load Schedule */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strLoadNumber, '')
		FROM tblLGLoad 
		WHERE intLoadId = (SELECT MAX(intLoadId) FROM tblLGLoad WHERE intShipmentType = 1 AND CHARINDEX(A.strPrefix, strLoadNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Load Schedule' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Generate Load/Batch Load */
	UPDATE A
	SET A.intNumber = intTransactionId + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT intTransactionId = ISNULL(intReferenceNumber, 0)
		FROM tblLGGenerateLoad 
		WHERE intReferenceNumber = (SELECT MAX(intReferenceNumber) FROM tblLGGenerateLoad)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType IN ('Batch Load', 'Generate Load')
		AND A.intNumber < intTransactionId + 1

	/* Pick Lots */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strPickLotNumber, '')
		FROM tblLGPickLotHeader 
		WHERE intPickLotHeaderId = (SELECT MAX(intPickLotHeaderId) FROM tblLGPickLotHeader WHERE intType = 1 AND CHARINDEX(A.strPrefix, strPickLotNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Pick Lots' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Stock Sales */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strStockSalesNumber, '')
		FROM tblLGStockSalesHeader 
		WHERE intStockSalesHeaderId = (SELECT MAX(intStockSalesHeaderId) FROM tblLGStockSalesHeader WHERE CHARINDEX(A.strPrefix, strStockSalesNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Stock Sales' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Delivery Notice */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strDeliveryNoticeNumber, '')
		FROM tblLGLoadWarehouse 
		WHERE intLoadWarehouseId = (SELECT MAX(intLoadWarehouseId) FROM tblLGLoadWarehouse WHERE CHARINDEX(A.strPrefix, strDeliveryNoticeNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Delivery Notice' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Least Cost Routing */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strRouteNumber, '')
		FROM tblLGRoute 
		WHERE intRouteId = (SELECT MAX(intRouteId) FROM tblLGRoute WHERE CHARINDEX(A.strPrefix, strRouteNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Least Cost Routing' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Load Shipping Instruction */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strLoadNumber, '')
		FROM tblLGLoad 
		WHERE intLoadId = (SELECT MAX(intLoadId) FROM tblLGLoad WHERE intShipmentType = 2 AND CHARINDEX(A.strPrefix, strLoadNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Load Shipping Instruction' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Weight Claims */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strReferenceNumber, '')
		FROM tblLGWeightClaim 
		WHERE intWeightClaimId = (SELECT MAX(intWeightClaimId) FROM tblLGWeightClaim WHERE CHARINDEX(A.strPrefix, strReferenceNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Weight Claims' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Allocation Details */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strAllocationDetailRefNo, '')
		FROM tblLGAllocationDetail 
		WHERE intAllocationDetailId = (SELECT MAX(intAllocationDetailId) FROM tblLGAllocationDetail WHERE CHARINDEX(A.strPrefix, strAllocationDetailRefNo) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Allocation Detail' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

	/* Pick Containers */
	UPDATE A
	SET A.intNumber = CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1
	FROM tblSMStartingNumber A
	OUTER APPLY (
		SELECT strTransactionId = ISNULL(strPickLotNumber, '')
		FROM tblLGPickLotHeader 
		WHERE intPickLotHeaderId = (SELECT MAX(intPickLotHeaderId) FROM tblLGPickLotHeader WHERE intType = 2 AND CHARINDEX(A.strPrefix, strPickLotNumber) > 0)
		) B
	WHERE A.strModule = 'Logistics' 
		AND A.strTransactionType = 'Pick Containers' 
		AND A.intNumber < CAST(RIGHT(strTransactionId, COALESCE(NULLIF(PATINDEX('%[^0-9]%', REVERSE(strTransactionId)), 0) - 1, LEN(strTransactionId))) AS INT) + 1

END