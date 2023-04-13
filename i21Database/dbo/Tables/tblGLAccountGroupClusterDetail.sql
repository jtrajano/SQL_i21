CREATE TABLE tblGLAccountGroupClusterDetail (
    intAccountGroupClusterDetailId INT IDENTITY (1,1),
	intAccountGroupClusterId INT,
	intAccountGroupId INT,
    intAccountId INT,
	intConcurrencyId INT NULL, 
    CONSTRAINT [PK_tblGLAccountGroupClusterDetail] PRIMARY KEY (intAccountGroupClusterDetailId),
	
)
GO

GO