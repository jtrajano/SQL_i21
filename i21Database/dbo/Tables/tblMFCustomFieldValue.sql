CREATE TABLE [dbo].[tblMFCustomFieldValue]
(
	intCustomFieldValueId INT NOT NULL IDENTITY(1,1),
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFCustomFieldValue_intConcurrencyId DEFAULT 0,
	intCustomTabDetailId INT NOT NULL,
	intWorkOrderInputLotId INT NOT NULL,
	strValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

    CONSTRAINT PK_tblMFCustomFieldValue PRIMARY KEY (intCustomFieldValueId)
)
