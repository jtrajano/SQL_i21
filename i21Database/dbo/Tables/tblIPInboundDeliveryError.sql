Create table tblIPInboundDeliveryError
	(
	intInboundDeliveryErrorId int
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL
	,dtmCreatedDate DATETIME
	,strPONumber NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL
	,strPOLineItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strPOStatus NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL
	,strBatchId NVARCHAR(50)  COLLATE Latin1_General_CI_AS 
	,strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,strBOLNo NVARCHAR(50)	 COLLATE Latin1_General_CI_AS NOT NULL
	,dtmStockDate DATETIME
	,strFreightAgent NVARCHAR(50)  COLLATE Latin1_General_CI_AS 
	,strSealNo NVARCHAR(50)	   COLLATE Latin1_General_CI_AS 
	,strContainerType NVARCHAR(50)	COLLATE Latin1_General_CI_AS 
	,strVoyage NVARCHAR(50)	  COLLATE Latin1_General_CI_AS 
	,strVessel NVARCHAR(50)  COLLATE Latin1_General_CI_AS 
	,intStatusId int
	,strMessage	  NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS 
	,strIBDNo NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS 
	)