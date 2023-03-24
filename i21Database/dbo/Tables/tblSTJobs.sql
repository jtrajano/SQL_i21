CREATE TABLE [dbo].[tblSTJobs]
(
    [intJobId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL,
    [intJobTypeId] INT NOT NULL,
    [dtmJobCreated] DATETIME NOT NULL,
    [strParameter1] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
    [strParameter2] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
    [ysnJobReceived] BIT NOT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTJobs] PRIMARY KEY CLUSTERED ([intJobId] ASC),
    CONSTRAINT [FK_tblSTJobs_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
    CONSTRAINT [FK_tblSTJobs_tblSTJobTypes] FOREIGN KEY ([intJobTypeId]) REFERENCES [tblSTJobTypes]([intJobTypeId])
)