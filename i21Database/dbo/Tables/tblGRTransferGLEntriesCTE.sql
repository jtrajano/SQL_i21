CREATE TABLE tblGRTransferGLEntriesCTE
(
	intTransferGLEntriesCTEId INT PRIMARY KEY IDENTITY(1,1) NOT NULL
	,intItemId INT NULL
	,intItemLocationId INT NULL
	,intSourceTransactionId INT NULL
	,intSourceTransactionDetailId INT NULL
	,strSourceTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,intTransactionId INT NULL
	,intTransactionDetailId INT NULL
	,strTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,dblQty DECIMAL(38,20) NULL
	,dblUOMQty DECIMAL(38,20) NULL
	,dblCost DECIMAL(38,20) NULL
	,dblValue DECIMAL(38,20) NULL
	,intCurrencyId INT NULL
	,strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strRateType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strTransactionType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,dtmDate DATETIME NULL
	,ysnIsUnposted BIT NULL
	,strBatchId NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,strUnpostBatchId NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,strCheck NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
)