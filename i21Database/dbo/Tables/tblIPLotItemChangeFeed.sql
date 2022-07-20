﻿CREATE TABLE tblIPLotItemChangeFeed (
	intLotItemChangeFeedId INT identity(1, 1)
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedByUser NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionTypeId INT
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strOldItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNewItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMotherLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strReasonCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNotes NVARCHAR(2048) COLLATE Latin1_General_CI_AS
	,intStatusId int
	,strMessage NVARCHAR(2048) COLLATE Latin1_General_CI_AS
	,strAdjustmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT CONSTRAINT DF_tblIPLotItemChangeFeed_ysnMailSent DEFAULT 0
	,strLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,CONSTRAINT PK_tblIPLotItemChangeFeed PRIMARY KEY (intLotItemChangeFeedId)
	)

	