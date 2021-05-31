CREATE TABLE tblIPInventoryAdjustment (
	intInventoryAdjustmentId INT identity(1, 1)
	,dtmCreatedDate DATETIME
	,intContractHeaderId INT
	,intContractDetailId INT
	,intLoadId INT
	,intLoadDetailId INT
	,intLoadContainerId INT
	,intInventoryReceiptId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblNet NUMERIC(18, 6)
	,dblGross NUMERIC(18, 6)
	,CONSTRAINT PK_tblIPInventoryAdjustment PRIMARY KEY (intInventoryAdjustmentId )
	)
