CREATE TABLE [dbo].[tblCFVehicle] (
    [intVehicleId]            INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]            INT            NOT NULL,
    [strVehicleNumber]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strCustomerUnitNumber]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strVehicleDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intDaysBetweenService]   INT            NULL,
    [intMilesBetweenService]  INT            NULL,
    [intLastReminderOdometer] INT            NULL,
    [dtmLastReminderDate]     DATETIME       NULL,
    [dtmLastServiceDate]      DATETIME       NULL,
    [intLastServiceOdometer]  INT            NULL,
    [strNoticeMessageLine1]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strNoticeMessageLine2]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strVehicleForOwnUse]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intExpenseItemId]        INT            NULL,
    [strLicencePlateNumber]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]        INT            NULL,
    [dtmCreated]              DATETIME       NULL,
    [intLastModifiedUserId]   INT            NULL,
    [intConcurrencyId]        INT            CONSTRAINT [DF_tblCFVehicle_intConcurrencyId] DEFAULT ((1)) NULL,
    [dtmLastModified]         DATETIME       NULL,
    [ysnCardForOwnUse]        BIT            NULL,
    [ysnActive]				  BIT			 CONSTRAINT [DF_tblCFVehicle_ysnActive]  DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFVehicle] PRIMARY KEY CLUSTERED ([intVehicleId] ASC),
    CONSTRAINT [FK_tblCFVehicle_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFVehicle_tblICItem] FOREIGN KEY ([intExpenseItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
);












GO
CREATE NONCLUSTERED INDEX [IX_tblCFVehicle_intVehicleId]
    ON [dbo].[tblCFVehicle]([intVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFVehicle_intVehicleId]
    ON [dbo].[tblCFVehicle]([intVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFVehicle_intAccountId]
    ON [dbo].[tblCFVehicle]([intAccountId] ASC);

