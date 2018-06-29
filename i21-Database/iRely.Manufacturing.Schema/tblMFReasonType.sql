CREATE TABLE [dbo].[tblMFReasonType]
(
	intReasonTypeId INT NOT NULL,
	strReasonName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT PK_tblMFReasonType PRIMARY KEY (intReasonTypeId),
	CONSTRAINT AK_tblMFReasonType_strWastageTypeName UNIQUE (strReasonName)
)