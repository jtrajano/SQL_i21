CREATE TABLE [dbo].[tblCRMMilestone]
(
	[intMilestoneId] INT IDENTITY (1, 1) NOT NULL,
	[strMileStone] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPriority] INT NOT NULL,
    [intSort] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMMilestone] PRIMARY KEY CLUSTERED ([intMilestoneId] ASC),
    CONSTRAINT [UNQ_tblCRMMilestone] UNIQUE ([strMileStone])
)