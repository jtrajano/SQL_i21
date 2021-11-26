CREATE TABLE tblApiRESTErrorLog
(
    intId INT IDENTITY(1, 1) PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER,
    strError NVARCHAR(500) COLLATE Latin1_General_CI_AS,
    strField NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    strValue NVARCHAR(500) COLLATE Latin1_General_CI_AS,
    intLineNumber INT NULL,
    dblTotalAmount NUMERIC(18, 6),
    intLinePosition INT NULL,
    strLogLevel NVARCHAR(50) COLLATE Latin1_General_CI_AS
)