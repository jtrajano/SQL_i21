CREATE TABLE [dbo].[tblARCustomAgingSetupBucket]
(
    [intCustomAgingSetupBucketId]       INT NOT NULL IDENTITY,
    [intCustomAgingSetupId]             INT NOT NULL,
    [strOriginalBucket]                 NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCustomTitle]                    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intAgeFrom]                        INT NULL,
    [intAgeTo]                          INT NULL,
    [ysnShow]                           BIT NOT NULL CONSTRAINT [DF_tblARCustomAgingSetupBucket_ysnShow] DEFAULT ((0)),
    [intConcurrencyId]                  INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblARCustomAgingSetupBucket] PRIMARY KEY ([intCustomAgingSetupBucketId]),
    CONSTRAINT [FK_tblARCustomAgingSetupBucket_tblARCustomAgingSetup_intCustomAgingSetupId] FOREIGN KEY ([intCustomAgingSetupId]) REFERENCES [dbo].[tblARCustomAgingSetup] ([intCustomAgingSetupId]) ON DELETE CASCADE
)