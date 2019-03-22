CREATE TABLE dbo.tblMFDepartment (
	intDepartmentId INT IDENTITY(1, 1) NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,intSubLocationId INT NOT NULL
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFDepartment_intConcurrencyId DEFAULT 0
	,CONSTRAINT PK_tblMFDepartment_intDepartmentId PRIMARY KEY (intDepartmentId)
	,CONSTRAINT FK_tblMFDepartment_tblSMCompanyLocationSubLocation_intSubLocationId FOREIGN KEY(intSubLocationId) REFERENCES dbo.tblSMCompanyLocationSubLocation (intCompanyLocationSubLocationId),
	)
