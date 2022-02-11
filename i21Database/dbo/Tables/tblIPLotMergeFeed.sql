﻿CREATE TABLE tblIPLotMergeFeed (
	intLotMergeFeedId INT identity(1, 1)
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedByUser NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionTypeId INT
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMotherLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDestinationStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDestinationStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDestinationLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strReasonCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNotes NVARCHAR(2048) COLLATE Latin1_General_CI_AS
	,intStatusId int
	,strMessage NVARCHAR(2048) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT CONSTRAINT DF_tblIPLotMergeFeed_ysnMailSent DEFAULT 0

	,CONSTRAINT PK_tblIPLotMergeFeed PRIMARY KEY (intLotMergeFeedId)
	)