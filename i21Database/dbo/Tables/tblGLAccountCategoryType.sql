CREATE TABLE tblGLAccountCategoryType
(
    intAccountCategoryTypeId INT IDENTITY(1,1) NOT NULL,
    intAccountCategoryId INT,
    strAccountType NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
     CONSTRAINT [PK_tblGLAccountCategoryType] PRIMARY KEY CLUSTERED 
(
	intAccountCategoryTypeId ASC
)
)