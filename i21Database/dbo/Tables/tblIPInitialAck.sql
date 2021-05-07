CREATE TABLE tblIPInitialAck (
	intInitialAckId INT identity(1, 1)
	,intTrxSequenceNo INT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intMessageTypeId INT
	,intStatusId INT
	,strStatusText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS

	,CONSTRAINT PK_tblIPInitialAck PRIMARY KEY (intInitialAckId)
	)
