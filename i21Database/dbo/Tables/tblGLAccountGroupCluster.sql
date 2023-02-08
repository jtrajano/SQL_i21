CREATE TABLE tblGLAccountGroupCluster (
	intAccountGroupClusterId INT IDENTITY (1,1),
	strAccountGroupClusterName NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL ,
	ysnActive BIT NULL,
    intConcurrencyId INT NULL, 
    CONSTRAINT [PK_tblGLAccountGroupCluster] PRIMARY KEY (intAccountGroupClusterId)
)