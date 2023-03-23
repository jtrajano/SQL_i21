CREATE TABLE tblGLAccountGroupClusterDetails (
	intAccountGroupClusterDetailsId INT IDENTITY (1,1),
    intAccountGroupClusterId INT,
    intAccountGroupId INT NULL,
	intAccountId INT,
    intConcurrencyId INT NULL, 
    CONSTRAINT [FK_tblGLAccountGroupClusterDetails_tblGLAccountGroupCluster] FOREIGN KEY ([intAccountGroupClusterId]) REFERENCES [dbo].[tblGLAccountGroupCluster] ([intAccountGroupClusterId]) ON DELETE CASCADE,
    CONSTRAINT [PK_tblGLAccountGroupClusterDetails] PRIMARY KEY (intAccountGroupClusterDetailsId)
)
GO
CREATE UNIQUE INDEX [UX_tblGLAccountGroupCluster_intAccountGroupClusterId] ON [dbo].[tblGLAccountGroupClusterDetails](
    intAccountGroupClusterId ASC,
	intAccountId ASC,
    intAccountGroupId ASC
)
GO