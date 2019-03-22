CREATE TABLE tblMFEDI945Error (
	strTransactionId NVARCHAR(3) COLLATE Latin1_General_CI_AS
	,strCustomerId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strType NVARCHAR(1) COLLATE Latin1_General_CI_AS
	,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPurchaseOrderNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dtmShipmentDate DATETIME
	,strShipmentId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShipToAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToAddress2 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToState NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToZipCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strBOL NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmShippedDate DATETIME
	,strTransportationMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strSCAC NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strRouting NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShipmentMethodOfPayment NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strTotalPalletsLoaded NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblTotalUnitsShipped NUMERIC(38, 20)
	,dblTotalWeight NUMERIC(38, 20)
	,strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intLineNo INT
	,strSSCCNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strOrderStatus NVARCHAR(2) COLLATE Latin1_General_CI_AS
	,strUPCCaseCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	,dblQtyOrdered NUMERIC(38, 20)
	,dblQtyShipped NUMERIC(38, 20)
	,dblQtyDifference NUMERIC(38, 20)
	,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strBestBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intRowNumber INT
	,ysnNotify bit CONSTRAINT [DF_tblMFEDI945Error] DEFAULT 0
	,ysnSentEMail bit
	)
