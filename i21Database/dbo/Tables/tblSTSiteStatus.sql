CREATE TABLE [dbo].[tblSTSiteStatus]
(
    [intSiteStatusId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL,
    [dtmStatusDate] DATETIME NOT NULL,
    [ysnInternetConnectivity] BIT NOT NULL,
    [ysnRegisterConnectivity] BIT NOT NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTSiteStatus] PRIMARY KEY CLUSTERED ([intSiteStatusId] ASC),
    CONSTRAINT [FK_tblSTSiteStatus_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),    
)