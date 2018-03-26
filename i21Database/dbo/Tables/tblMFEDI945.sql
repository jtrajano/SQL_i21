	CREATE TABLE tblMFEDI945 (
	intEDI945Id INT NOT NULL IDENTITY(1, 1)
	,intInventoryShipmentId int
	,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmCreated datetime CONSTRAINT [DF_tblMFEDI945_dtmCreated] DEFAULT GETDATE() 
	,ysnStatus BIT CONSTRAINT DF_tblMFEDI945_ysnStatus DEFAULT 1
	)
