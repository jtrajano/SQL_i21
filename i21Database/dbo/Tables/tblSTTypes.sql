CREATE TABLE [dbo].[tblSTJobTypes]
(
    [intJobTypeId] INT NOT NULL IDENTITY,
    [strJobType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTJobTypes] PRIMARY KEY CLUSTERED ([intJobTypeId] ASC)
)