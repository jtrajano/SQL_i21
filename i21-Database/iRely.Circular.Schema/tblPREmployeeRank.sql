CREATE TABLE [dbo].[tblPREmployeeRank]
(
	[intEmployeeRankId] INT NOT NULL IDENTITY, 
    [intRank] INT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
	CONSTRAINT [PK_tblPREmployeeRank] PRIMARY KEY CLUSTERED ([intEmployeeRankId] ASC),
    CONSTRAINT [AK_tblPREmployeeRank_intRank] UNIQUE ([intRank])
)
