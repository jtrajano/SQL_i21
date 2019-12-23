CREATE TABLE tblIPInventoryReceiptWeightClaim (
	intInventoryReceiptWeightClaimId INT IDENTITY(1, 1) CONSTRAINT [PK_tblIPInventoryReceiptWeightClaim_intInventoryReceiptWeightClaimId] PRIMARY KEY
	,intInventoryReceiptId INT
	,dtmCreated DATETIME CONSTRAINT DF_tblIPInventoryReceiptWeightClaim_dtmCreated DEFAULT GETDATE()
	)
