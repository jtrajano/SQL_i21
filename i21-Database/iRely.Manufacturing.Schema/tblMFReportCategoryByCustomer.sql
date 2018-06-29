CREATE TABLE dbo.tblMFReportCategoryByCustomer (
	intReportCategoryId INT NOT NULL identity(1, 1) CONSTRAINT PK_tblMFReportCategoryByCustomer_intReportCategoryId PRIMARY KEY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intCategoryId INT NOT NULL
	,CONSTRAINT PK_tblMFReportCategoryByCustomer_intCategoryId FOREIGN KEY (intCategoryId) REFERENCES tblICCategory(intCategoryId)
	,CONSTRAINT UQ_tblMFReportCategoryByCustomer_strReportName_intCategoryId UNIQUE (
		strReportName
		,intCategoryId
		)
	)