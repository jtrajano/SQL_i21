CREATE TABLE tblApiImportLogDetail (
    guiApiImportLogDetailId UNIQUEIDENTIFIER NOT NULL,
    guiApiImportLogId UNIQUEIDENTIFIER NOT NULL,
    strLogLevel NVARCHAR(100) NOT NULL, --Error, Info, Warning
    strStatus NVARCHAR(150) NOT NULL, --Failed, Success, Warning
    strAction NVARCHAR(150) NULL, --Skipped, etc.
    intRowNo INT NULL,
    strField NVARCHAR(100) NULL,
    strValue NVARCHAR(4000) NULL,
    strMessage NVARCHAR(4000) NULL,
    CONSTRAINT PK_tblApiImportLogDetail_guiApiImportLogId PRIMARY KEY NONCLUSTERED(guiApiImportLogDetailId),
    CONSTRAINT tblApiImportLogDetail_tblApiImportLog_guiApiImportLogId
        FOREIGN KEY (guiApiImportLogId) REFERENCES [tblApiImportLog](guiApiImportLogId) ON DELETE CASCADE
)

GO

CREATE CLUSTERED INDEX IX_tblApiImportLogDetail_intRowNo ON tblApiImportLogDetail (intRowNo ASC)

GO