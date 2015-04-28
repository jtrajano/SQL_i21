CREATE TABLE [dbo].[tblGRStorageScheduleRule]
(
	[intStorageScheduleRuleId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strStorageSchedule] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intStorageNumber] INT NOT NULL, 
    [intStorageType] INT NOT NULL, 
    [intCommodity] INT NOT NULL, 
    [intCompanyLocation] INT NOT NULL, 
    [intAllowanceDays] INT NOT NULL DEFAULT 0, 
    [dtmEffectiveDate] DATETIME NULL, 
    [dtmTerminationDate] DATETIME NULL, 
    [intFeeRate] INT NOT NULL DEFAULT 0, 
    [intFeeType] INT NOT NULL DEFAULT 1, 
    [dblCurrencyRate] NUMERIC(18, 6) NOT NULL, 
    CONSTRAINT [PK_tblGRStorageScheduleRule_intStorageScheduleRuleId] PRIMARY KEY ([intStorageScheduleRuleId]), 
    CONSTRAINT [FK_tblGRStorageScheduleRule_tblICCommodity] FOREIGN KEY ([intCommodity]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblGRStorageScheduleRule_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocation]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
)
