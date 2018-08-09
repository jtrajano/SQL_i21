CREATE TABLE tblIPSAPLocation
(
	intLocationId INT identity(1, 1),
	strSAPLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	stri21Location NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT PK_tblIPSAPLocation_intLocationId PRIMARY KEY (intLocationId) 
)

