CREATE TABLE [dbo].[tblWHPickPreference]
(
	intPickPreferenceId INT IDENTITY (1,1),
	intPickPreferenceType INT,
	strDescription NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL, 
	strInternalCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	ysnIsDefault BIT,

    CONSTRAINT [PK_tblWHPickPreference] PRIMARY KEY ([intPickPreferenceId])
)