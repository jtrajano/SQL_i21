﻿CREATE TABLE tblMFEDI943 (
	intEDI943Id INT NOT NULL IDENTITY(1, 1)
	,intTransactionId INT
	,strCustomerId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDepositorOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShipmentId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strActionCode CHAR(1) COLLATE Latin1_General_CI_AS
	,strShipFromName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strShipFromAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipFromAddress2 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipFromCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipFromState NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipFromZip NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strShipFromCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strTransportationMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strSCAC NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblTotalNumberofUnitsShipped NUMERIC(36, 20)
	,dblTotalWeight NUMERIC(36, 20)
	,strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strVendorItemNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
	,dblQtyShipped NUMERIC(36, 20)
	,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS, CONSTRAINT [PK_tblMFEDI943_intEDI943Id] PRIMARY KEY (intEDI943Id)
	,dtmCreated datetime CONSTRAINT [DF_tblMFEDI943_dtmCreated] DEFAULT GETDATE() 
	,strFileName nvarchar(MAX) COLLATE Latin1_General_CI_AS
	,strParentLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	,intLineNumber int
	,strWarehouseCode nvarchar(50) COLLATE Latin1_General_CI_AS
	,intWarehouseCodeType int
	,ysnNotify bit CONSTRAINT [DF_tblMFEDI943_ysnNotify] DEFAULT 0
	,ysnSentEMail bit CONSTRAINT [DF_tblMFEDI943_ysnSentEMail] DEFAULT 0
	)