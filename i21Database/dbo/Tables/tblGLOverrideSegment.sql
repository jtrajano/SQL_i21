CREATE TABLE tblGLOverrideSegment(
	intOverrideSegmentId INT IDENTITY(1,1) ,
	intAccountIdFrom INT ,
	intAccountIdTo INT NULL,
	intCompanySegmentId INT,
	strNewAccountId NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL,
    guidId UNIQUEIDENTIFIER,
    dtmDate DATETIME,
	intConcurrencyId INT NULL,
	CONSTRAINT [PK_OverrideAccount_OverrideSegmentId] PRIMARY KEY CLUSTERED ([intOverrideSegmentId] ASC)
)
