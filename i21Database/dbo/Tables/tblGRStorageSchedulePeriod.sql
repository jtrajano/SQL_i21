CREATE TABLE [dbo].[tblGRStorageSchedulePeriod]
(
	[intStorageSchedulePeriodId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intStorageScheduleRule] INT NOT NULL, 
    [intUseDateDays] INT NOT NULL, 
    [dtmEffectiveDate] DATETIME NULL, 
    [dtmEndingDate] DATETIME NULL, 
    [intNumberOfDays] INT NOT NULL DEFAULT 0, 
    [intStorageRate] INT NOT NULL DEFAULT 0, 
    [strFeeDescription] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intFeeRate] INT NOT NULL, 
    [intFeeType] INT NOT NULL, 
    CONSTRAINT [PK_tblGRStorageSchedulePeriod_intStorageSchedulePeriodId] PRIMARY KEY ([intStorageSchedulePeriodId]), 
    CONSTRAINT [FK_tblGRStorageSchedulePeriod_tblGRStorageScheduleRule] FOREIGN KEY ([intStorageScheduleRule]) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]) 
)
