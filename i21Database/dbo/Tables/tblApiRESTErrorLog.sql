CREATE TABLE tblApiRESTErrorLog
(
    intId INT IDENTITY(1, 1) PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER,
    strError NVARCHAR(500),
    strField NVARCHAR(100),
    strValue NVARCHAR(500),
    intLineNumber INT NULL,
    dblTotalAmount NUMERIC(18, 6),
    intLinePosition INT NULL,
    strLogLevel NVARCHAR(50)
)