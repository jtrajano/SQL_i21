CREATE TABLE tblGLISMaskAccount(
    intAccountId INT,
    strAccountId NVARCHAR(30) COLLATE Latin1_General_CI_AS,
    intConcurrencyId INT,
    dtmModified DATETIME,
    CONSTRAINT [PK_tblGLISMaskAccount] PRIMARY KEY CLUSTERED ([intAccountId] ASC)
)