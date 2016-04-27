CREATE TABLE [dbo].[tblMFShiftActivityStatus]
(
	intShiftActivityStatusId INT NOT NULL,
	strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT PK_tblMFShiftActivityStatus PRIMARY KEY (intShiftActivityStatusId),
	CONSTRAINT AK_tblMFShiftActivityStatus_strStatus UNIQUE (strStatus)
)