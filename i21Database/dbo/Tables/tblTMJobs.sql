CREATE TABLE [dbo].[tblTMJobs]
(
    [intJobId] INT NOT NULL IDENTITY,
    [intDeviceId] INT NOT NULL,
    [dtmJobCreated] DATETIME NOT NULL,
    [ysnJobReceived] BIT NOT NULL,
    [intEntityId] INT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblTMJobs] PRIMARY KEY CLUSTERED ([intJobId] ASC),
    CONSTRAINT [FK_tblTMJobs_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [tblTMDevice]([intDeviceId]) ON DELETE CASCADE,
)