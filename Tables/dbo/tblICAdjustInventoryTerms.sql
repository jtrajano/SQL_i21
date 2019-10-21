CREATE TABLE [dbo].[tblICAdjustInventoryTerms]
(
	[intAdjustInventoryTermsId] INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
	[strTerms] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT(1) NOT NULL 
)
