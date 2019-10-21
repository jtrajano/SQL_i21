CREATE TABLE tblMFEDI940 (
	intEDI940Id INT NOT NULL IDENTITY(1, 1)
	,intTransactionId INT
	,strCustomerId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPurpose NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPONumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShipToName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strShipToAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToAddress2 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToState NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToZip NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipToCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strBuyerIdentification NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPODate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDeliveryRequestedDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intLineNumber int
	,strCustomerItemNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strUPCCaseCode NVARCHAR(250) COLLATE Latin1_General_CI_AS
	,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	,dblQtyOrdered NUMERIC(36, 20)
	,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS, CONSTRAINT [PK_tblMFEDI940_intEDI940Id] PRIMARY KEY (intEDI940Id)
	,dblInnerPacksPerOuterPack NUMERIC(36, 20)
	,dblTotalQtyOrdered NUMERIC(36, 20)
	,dtmCreated datetime CONSTRAINT [DF_tblMFEDI940_dtmCreated] DEFAULT GETDATE() 
	,strFileName nvarchar(MAX) COLLATE Latin1_General_CI_AS
	,strShipmentDate nvarchar(50) COLLATE Latin1_General_CI_AS
	,strTransportationMethod nvarchar(50) COLLATE Latin1_General_CI_AS
	,strSCAC nvarchar(50) COLLATE Latin1_General_CI_AS
	,strRouting nvarchar(50) COLLATE Latin1_General_CI_AS
	,strShipmentMethodOfPayment nvarchar(50) COLLATE Latin1_General_CI_AS
	,strCustomerCode nvarchar(50) COLLATE Latin1_General_CI_AS
	,intCustomerCodeType int
	,ysnNotify bit CONSTRAINT [DF_tblMFEDI940_ysnNotify] DEFAULT 0
	,ysnSentEMail bit
	)