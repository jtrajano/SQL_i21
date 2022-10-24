CREATE  TABLE tblMFBatchLog(
	intId INT IDENTITY(1,1),
    guidBatchLogId uniqueidentifier,
    strResult NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    intBatchId int null ,
	dtmDate DATETIME NOT NULL
)

