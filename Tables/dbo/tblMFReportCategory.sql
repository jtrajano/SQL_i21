CREATE TABLE dbo.tblMFReportCategory (
	intReportCategoryId INT NOT NULL identity(1, 1) CONSTRAINT PK_tblMFReportCategory_intReportCategoryId PRIMARY KEY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intCategoryId INT NOT NULL
	,intNoOfLabel INT
	,CONSTRAINT PK_tblMFReportCategory_intCategoryId FOREIGN KEY (intCategoryId) REFERENCES tblICCategory(intCategoryId)
	,CONSTRAINT UQ_tblMFReportCategory_strReportName_intCategoryId UNIQUE (
		strReportName
		,intCategoryId
		)
	)