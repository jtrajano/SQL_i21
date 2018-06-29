CREATE TABLE [dbo].[tblMFPickPreference] (
		[intPickPreferenceId] INT NOT NULL IDENTITY
	,[intConcurrencyId] INT NOT NULL
	,[strPickPreference] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,[ysnIsDefault] BIT
	)