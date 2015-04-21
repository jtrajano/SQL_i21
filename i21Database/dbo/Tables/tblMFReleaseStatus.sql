CREATE TABLE tblMFReleaseStatus (
	intReleaseStatusId INT CONSTRAINT PK_tblMFReleaseStatus_intReleaseStatusId PRIMARY KEY
	,strReleaseStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	)
GO