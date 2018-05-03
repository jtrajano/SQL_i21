﻿CREATE TABLE [dbo].[tblCFCard] (
    [intCardId]                  INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]               INT            NULL,
    [strCardNumber]              NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strCardDescription]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]               INT            NOT NULL,
    [intProductAuthId]           INT            NULL,
    [intEntryCode]               INT            NULL,
    [strCardXReference]          NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strCardForOwnUse]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intExpenseItemId]           INT            NULL,
    [intDefaultFixVehicleNumber] INT            NULL,
    [intDepartmentId]            INT            NULL,
    [dtmLastUsedDated]           DATETIME       NULL,
    [intCardTypeId]              INT            NULL,
    [dtmIssueDate]               DATETIME       NULL,
    [ysnActive]                  BIT            NULL,
    [ysnCardLocked]              BIT            NULL,
    [strCardPinNumber]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [dtmCardExpiratioYearMonth]  DATETIME       NULL,
    [strCardValidationCode]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intNumberOfCardsIssued]     INT            NULL,
    [intCardLimitedCode]         INT            NULL,
    [intCardFuelCode]            INT            NULL,
    [strCardTierCode]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCardOdometerCode]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCardWCCode]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strSplitNumber]             NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intCardManCode]             INT            NULL,
    [intCardShipCat]             INT            NULL,
    [intCardProfileNumber]       INT            NULL,
    [intCardPositionSite]        INT            NULL,
    [intCardvehicleControl]      INT            NULL,
    [intCardCustomPin]           INT            NULL,
    [intCreatedUserId]           INT            NULL,
    [dtmCreated]                 DATETIME       NULL,
    [intLastModifiedUserId]      INT            NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblCFCard_intConcurrencyId] DEFAULT ((1)) NULL,
    [dtmLastModified]            DATETIME       NULL,
    [ysnCardForOwnUse]           BIT            NULL,
    [ysnIgnoreCardTransaction]   BIT            NULL,
    [strComment]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intDailyTransactionCount]   INT            CONSTRAINT [DF_tblCFCard_intDailyTransactionCount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCFCard] PRIMARY KEY CLUSTERED ([intCardId] ASC),
    CONSTRAINT [FK_tblCFCard_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFCard_tblCFCardType] FOREIGN KEY ([intCardTypeId]) REFERENCES [dbo].[tblCFCardType] ([intCardTypeId]),
    CONSTRAINT [FK_tblCFCard_tblCFDepartment] FOREIGN KEY ([intDepartmentId]) REFERENCES [dbo].[tblCFDepartment] ([intDepartmentId]),
    CONSTRAINT [FK_tblCFCard_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]),
    CONSTRAINT [FK_tblCFCard_tblCFProductAuth] FOREIGN KEY ([intProductAuthId]) REFERENCES [dbo].[tblCFProductAuth] ([intProductAuthId]),
    CONSTRAINT [FK_tblCFCard_tblCFVehicle] FOREIGN KEY ([intDefaultFixVehicleNumber]) REFERENCES [dbo].[tblCFVehicle] ([intVehicleId]),
    CONSTRAINT [FK_tblCFCard_tblICItem] FOREIGN KEY ([intExpenseItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
);


GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO



GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO



GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];




GO



GO



GO
ALTER TABLE [dbo].[tblCFCard] NOCHECK CONSTRAINT [FK_tblCFCard_tblCFVehicle];






GO
CREATE NONCLUSTERED INDEX [IX_tblCFCard_intCardId]
    ON [dbo].[tblCFCard]([intCardId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFCard_intNetworkId]
    ON [dbo].[tblCFCard]([intNetworkId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFCard_intCardId]
    ON [dbo].[tblCFCard]([intCardId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFCard_intAccountId]
    ON [dbo].[tblCFCard]([intAccountId] ASC);

