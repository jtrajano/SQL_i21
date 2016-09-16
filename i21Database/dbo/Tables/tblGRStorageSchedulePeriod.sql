CREATE TABLE [dbo].[tblGRStorageSchedulePeriod]
(
	[intStorageSchedulePeriodId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intStorageScheduleRule] INT NOT NULL, 
    [strPeriodType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmEffectiveDate] DATETIME NULL, 
    [dtmEndingDate] DATETIME NULL, 
    [intNumberOfDays] INT NULL , 
    [dblStorageRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strFeeDescription] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL, 
    [dblFeeRate] NUMERIC(18, 6) NULL, 
    [strFeeType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblGRStorageSchedulePeriod_intStorageSchedulePeriodId] PRIMARY KEY ([intStorageSchedulePeriodId]), 
	CONSTRAINT [FK_tblGRStorageSchedulePeriod_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblGRStorageSchedulePeriod_tblGRStorageScheduleRule] FOREIGN KEY ([intStorageScheduleRule]) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]) ON DELETE CASCADE
)
