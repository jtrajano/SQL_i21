CREATE TABLE tblMFEDI944Error (
	strTransactionId NVARCHAR(50) Collate Latin1_General_CI_AS
	,strCustomerId NVARCHAR(50) Collate Latin1_General_CI_AS
	,strType NVARCHAR(2) Collate Latin1_General_CI_AS
	,dtmDate DATETIME
	,strWarehouseReceiptNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,strDepositorOrderNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,strShipmentId NVARCHAR(50) Collate Latin1_General_CI_AS
	,dtmShippedDate DATETIME
	,dblTotalReceivedQty NUMERIC(38, 20)
	,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
	,strDescription NVARCHAR(250) Collate Latin1_General_CI_AS
	,dblReceived NUMERIC(38, 20)
	,strUOM NVARCHAR(50) Collate Latin1_General_CI_AS
	,strParentLotNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,ysnNotify BIT
	,ysnSentEMail BIT
	)

