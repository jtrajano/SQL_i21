CREATE TABLE tblGLIntraCompanyConfig
(
    intIntraCompanyConfigId INT IDENTITY (1,1),
    intParentCompanySegmentId INT NOT NULL,
    intTargeCompanySegmentId INT NOT NULL,
    intDueFromAccountId INT NOT NULL,
    intDueToAccountId INT NOT NULL,
    intConcurrencyId INT NOT NULL
)