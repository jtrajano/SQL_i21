CREATE TABLE tblQMSamplePreStage
(
	intSamplePreStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intSampleId				INT,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblQMSamplePreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intBookId				INT,

	strSampleNumber			NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	intRecordStatus			INT,
	intSampleTypeId			INT,
	intItemId				INT,
	intCountryID			INT,
	intCompanyLocationSubLocationId INT,
	intContractDetailId		INT,
	intEntityId				INT,
	intCreatedUserId		INT,

	strContainerNumber		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMarks				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLotNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblRepresentingQty		NUMERIC(18, 6),
	dtmSampleReceivedDate	DATETIME,
	dtmCreated				DATETIME
)