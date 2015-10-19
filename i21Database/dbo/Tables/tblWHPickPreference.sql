CREATE TABLE [dbo].[tblWHPickPreference]
(
	intPickPreferenceId INT NOT NULL PRIMARY KEY,
	intPreferenceType INT NULL,
	strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
	ysnDefault BIT,
	strInternalCode NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
)
