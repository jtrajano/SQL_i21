CREATE TABLE [dbo].[tblGRStorageScheduleLocationUse]
(
	[intStorageScheduleLocationUseId] INT NOT NULL  IDENTITY, 
    [intStorageScheduleId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [ysnStorageScheduleLocationActive] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRStorageScheduleLocationUse_intStorageScheduleLocationUseId] PRIMARY KEY ([intStorageScheduleLocationUseId]), 
    CONSTRAINT [FK_tblGRStorageScheduleLocationUse_tblGRStorageScheduleRule_intStorageScheduleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblGRStorageScheduleLocationUse_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)