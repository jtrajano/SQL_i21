CREATE TABLE tblIPStorageLocationArchive (
	intStorageLocationArchiveId INT identity(1, 1)
	,intStorageLocationStageId INT
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageUnitType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,CONSTRAINT PK_tblIPStorageLocationArchive PRIMARY KEY (intStorageLocationArchiveId)
	)