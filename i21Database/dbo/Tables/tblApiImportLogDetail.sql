CREATE TABLE tblApiImportLogDetail (
    guiApiImportLogDetailId UNIQUEIDENTIFIER NOT NULL,
    guiApiImportLogId UNIQUEIDENTIFIER NOT NULL,
    strLogLevel NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, --Error, Info, Warning
    strStatus NVARCHAR(150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, --Failed, Success, Warning
    strAction NVARCHAR(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, --Skipped, etc.
    intRowNo INT NULL,
    strField NVARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strValue NVARCHAR(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strMessage NVARCHAR(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    CONSTRAINT PK_tblApiImportLogDetail_guiApiImportLogId PRIMARY KEY NONCLUSTERED(guiApiImportLogDetailId),
    CONSTRAINT tblApiImportLogDetail_tblApiImportLog_guiApiImportLogId
        FOREIGN KEY (guiApiImportLogId) REFERENCES [tblApiImportLog](guiApiImportLogId) ON DELETE CASCADE
)

GO

CREATE CLUSTERED INDEX IX_tblApiImportLogDetail_intRowNo ON tblApiImportLogDetail (intRowNo ASC)

GO