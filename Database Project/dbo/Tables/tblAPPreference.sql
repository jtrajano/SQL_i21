CREATE TABLE [dbo].[tblAPPreference]
(
	[intPreferenceId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
    [intDefaultAccountId] INT NULL, 
    [intWithholdAccountId] INT NULL, 
    [intDiscountId] INT NULL, 
    [dblWithholdPercent] INT NULL
)
