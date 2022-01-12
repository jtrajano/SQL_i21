CREATE TABLE tblIPBillDetailStage (
	intBillStageDetailId INT identity(1, 1)
	,intBillStageId INT
	,strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractSequenceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPProductionOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPServicePONo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPServicePOLineNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strWorkOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblUnitRate NUMERIC(18, 6)
	,strUnitRatePerUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strUnitRateCurrency NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblAmount NUMERIC(18, 6)
	,strICOMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblNetWeight NUMERIC(18, 6)
	,strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContainerNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intSeqNo INT
	,intContractHeaderId INT
	,intContractDetailId INT
	,intLoadId INT
	,intLoadDetailId INT
	,intWorkOrderId int
	,intInventoryReceiptId int
	,intInventoryReceiptItemId int
	,CONSTRAINT [PK_tblIPBillDetailStage] PRIMARY KEY (intBillStageDetailId)
	,CONSTRAINT [FK_tblIPBillDetailStage_tblIPBillStage_intBillStageId] FOREIGN KEY (intBillStageId) REFERENCES tblIPBillStage(intBillStageId)
	)