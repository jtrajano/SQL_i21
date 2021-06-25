CREATE TABLE [dbo].[tblRestApiTransformationLog]
(
    guiTransformationLogId UNIQUEIDENTIFIER NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    strField NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    strValue NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, 
    intLineNumber INT NULL, 
    strLogLevel NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    strIntegrationType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, --RESTfulAPI,RESTfulAPI_CSV,i21_CSV
    strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    strApiVersion NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    guiSubscriptionId UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_tblRestApiTransformationLog PRIMARY KEY(guiTransformationLogId)
)