CREATE TABLE tblGLIntraCompanyConfig
(
    intIntraCompanyConfigId INT IDENTITY (1,1),
    intParentCompanySegmentId INT NOT NULL,
    intTargetCompanySegmentId INT NOT NULL,
    intDueFromAccountId INT NOT NULL,
    intDueToAccountId INT NOT NULL,
    intConcurrencyId INT NULL,
	CONSTRAINT [PK_tblGLIntraCompanyConfig] PRIMARY KEY CLUSTERED (intIntraCompanyConfigId ASC),
    CONSTRAINT UNIQUE_PARENT_TARGET_tblGLIntraCompanyConfig UNIQUE (intParentCompanySegmentId,intTargetCompanySegmentId)
)