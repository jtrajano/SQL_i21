CREATE TABLE tblPRSchoolDistricts(
	[intSchoolDistrictId] [int] IDENTITY(1,1) NOT NULL,
	[strSchoolDistrict] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSchoolDistrictCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	intConcurrencyId INT NULL DEFAULT ((1)), 
)