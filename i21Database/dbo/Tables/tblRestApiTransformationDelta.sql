CREATE TABLE [dbo].[tblRestApiTransformationDelta]
(
    guiTransformationDeltaId UNIQUEIDENTIFIER NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intTransactionId INT NOT NULL,
    strTransactionNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblTotalAmount NUMERIC(18,6) NULL,
    strIntegrationType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, --RESTfulAPI,RESTfulAPI_CSV,i21_CSV
    strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    strApiVersion NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    guiSubscriptionId UNIQUEIDENTIFIER NULL,
    CONSTRAINT PK_tblRestApiTransformationDelta PRIMARY KEY(guiTransformationDeltaId)
)