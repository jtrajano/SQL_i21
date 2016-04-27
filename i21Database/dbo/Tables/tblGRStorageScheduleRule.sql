﻿CREATE TABLE [dbo].[tblGRStorageScheduleRule]
(
	[intStorageScheduleRuleId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strScheduleDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intStorageType] INT NOT NULL, 
    [intCommodity] INT NOT NULL, 
    [intAllowanceDays] INT NOT NULL DEFAULT 0, 
    [dtmEffectiveDate] DATETIME NULL, 
    [dtmTerminationDate] DATETIME NULL, 
    [dblFeeRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strFeeType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL , 
    [intCurrencyID] INT NOT NULL, 
    [strScheduleId] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStorageRate] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strFirstMonth] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strLastMonth] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblGRStorageScheduleRule_intStorageScheduleRuleId] PRIMARY KEY ([intStorageScheduleRuleId]), 
    CONSTRAINT [FK_tblGRStorageScheduleRule_tblICCommodity] FOREIGN KEY ([intCommodity]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblGRStorageScheduleRule_tblGRStorageType] FOREIGN KEY ([intStorageType]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]), 
    CONSTRAINT [FK_tblGRStorageScheduleRule_tblSMCurrency] FOREIGN KEY ([intCurrencyID]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [UK_tblGRStorageScheduleRule_strScheduleId_intStorageType_intCommodity] UNIQUE ([strScheduleId],[intStorageType],[intCommodity]) 
)
