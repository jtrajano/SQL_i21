CREATE TABLE [dbo].[tblMFPickListPreference]
(
	[intPickListPreferenceId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFPickListPreference_intPickListPreferenceId] PRIMARY KEY ([intPickListPreferenceId]), 
    CONSTRAINT [UQ_tblMFPickListPreference_strName] UNIQUE ([strName]) 
)
