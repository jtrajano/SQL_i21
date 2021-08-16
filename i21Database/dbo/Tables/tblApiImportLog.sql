CREATE TABLE tblApiImportLog (
    guiApiImportLogId UNIQUEIDENTIFIER NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    guiSubscriptionId UNIQUEIDENTIFIER NOT NULL,
    guiUserId UNIQUEIDENTIFIER NOT NULL,
    strDefinition NVARCHAR(250) NOT NULL,
    strSubscription NVARCHAR(200) NOT NULL,
    strStatus NVARCHAR(150) NOT NULL, -- Pending, Running, Completed, Cancelled, Success, Failed
    strResult NVARCHAR(150) NULL,
    strTrigger NVARCHAR(150) NULL,
    strUsername NVARCHAR(200) NOT NULL,
    strTemplate NVARCHAR(250) NULL,
    guiTemplateId UNIQUEIDENTIFIER NULL,
    strFileName NVARCHAR(500) NULL,
    strApiBuildNumber NVARCHAR(200) NULL,
    strApiVersion NVARCHAR(200) NULL,
    strI21Version NVARCHAR(200) NULL,
    intTotalRecordsCreated INT NULL, -- Total rows added
    intTotalRecordsUpdated INT NULL, -- Total rows updated
    intTotalRows INT NULL, -- Totals rows in the source file
    intTotalRowsSkipped INT NULL,
    intTotalRowsImported INT NULL, -- Total rows added plus total rows updated
    dtmImportDateUtc DATETIME2 NULL,
    dtmImportFinishDateUtc DATETIME2 NULL,
    ysnRolledBack BIT NULL,
    strMessage NVARCHAR(4000) NULL,
    CONSTRAINT PK_tblApiImportLog_guiApiImportLogId PRIMARY KEY NONCLUSTERED(guiApiImportLogId)
)
GO

CREATE CLUSTERED INDEX UX_tblApiImportLog_dtmImportDateUtc ON tblApiImportLog(dtmImportDateUtc DESC)

GO