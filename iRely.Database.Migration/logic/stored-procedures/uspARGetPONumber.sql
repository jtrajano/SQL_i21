--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARGetPONumber]
	 @ShipToID			INT				= NULL
	,@LocationId		INT				= NULL
	,@TransactionDate	DATETIME
	,@PONumber			NVARCHAR(200)	= NULL OUTPUT
AS
BEGIN
--DECLARE  @ShipToID INT
--		,@LocationId INT
--		,@TransactionDate DATETIME
--		,@PONumber NVARCHAR(200)

--SET @ShipToID = 2182
--SET @LocationId = 1
--SET @TransactionDate = GETDATE()

SELECT TOP 1
	@PONumber = PO.strPurchaseOrderNumber 
FROM
	(
	SELECT
		 0 AS intSort
		,strPurchaseOrderNumber
		,DATEDIFF(day,@TransactionDate, dtmExpectedDate) AS dateInterval
	FROM
		tblPOPurchase
	WHERE
		intShipFromId = @ShipToID
		AND intShipToId = @LocationId
		
	UNION ALL

	SELECT
		 0 AS intSort
		,strPurchaseOrderNumber
		,DATEDIFF(day,@TransactionDate, dtmExpectedDate) AS dateInterval
	FROM
		tblPOPurchase
	WHERE
		intShipFromId = @ShipToID
		OR intShipToId = @LocationId
	
	) AS PO
	
ORDER BY
	 PO.intSort ASC
	,PO.dateInterval ASC



RETURN 0




END