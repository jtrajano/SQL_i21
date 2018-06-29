CREATE TABLE [dbo].[tblMFWastageType]
(
	intWastageTypeId INT NOT NULL,
	strWastageTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT PK_tblMFWastageType PRIMARY KEY (intWastageTypeId),
	CONSTRAINT AK_tblMFWastageType_strWastageTypeName UNIQUE (strWastageTypeName)
)