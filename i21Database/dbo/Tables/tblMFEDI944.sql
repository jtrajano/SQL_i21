CREATE TABLE tblMFEDI944 (
	intEDI944Id INT NOT NULL IDENTITY(1, 1)
	,intInventoryReceiptId int
	,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmCreated datetime CONSTRAINT [DF_tblMFEDI944_dtmCreated] DEFAULT GETDATE() 
	,ysnStatus BIT CONSTRAINT DF_tblMFEDI944_ysnStatus DEFAULT 1
	)
