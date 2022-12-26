CREATE TABLE tblIPSAPProperty
(
	intSAPPropertyId INT IDENTITY(1, 1),
	strSAPPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	stri21PropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	stri21TestName NVARCHAR(100) COLLATE Latin1_General_CI_AS,

	CONSTRAINT PK_tblIPSAPProperty_intSAPPropertyId PRIMARY KEY (intSAPPropertyId) 
)

