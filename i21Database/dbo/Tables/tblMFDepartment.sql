﻿CREATE TABLE dbo.tblMFDepartment (
	intDepartmentId INT IDENTITY(1, 1) NOT NULL
	,strName NVARCHAR(50) NOT NULL
	,strDescription NVARCHAR(100) NOT NULL
	,intSubLocationId INT NOT NULL
	,CONSTRAINT PK_tblMFDepartment_intDepartmentId PRIMARY KEY (intDepartmentId)
	,CONSTRAINT FK_tblMFDepartment_tblSMCompanyLocationSubLocation_intSubLocationId FOREIGN KEY(intSubLocationId) REFERENCES dbo.tblSMCompanyLocationSubLocation (intCompanyLocationSubLocationId),
	)
