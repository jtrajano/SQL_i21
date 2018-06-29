CREATE PROCEDURE [dbo].[uspPORecur]
	@poId INT,
	@poDate DATETIME,
	@userId INT,
	@newPoId NVARCHAR(50) OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @purchaseCreatedPrimaryKey INT;
	EXEC uspPODuplicate @poId, @userId, @purchaseCreatedPrimaryKey OUTPUT

	UPDATE A
		SET A.dtmDate = @poDate
	FROM tblPOPurchase A
	WHERE A.intPurchaseId = @purchaseCreatedPrimaryKey
	
	SET @newPoId = (SELECT strPurchaseOrderNumber FROM tblPOPurchase WHERE intPurchaseId = @purchaseCreatedPrimaryKey)

END