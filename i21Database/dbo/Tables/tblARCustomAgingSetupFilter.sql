CREATE TABLE [dbo].[tblARCustomAgingSetupFilter]
(
    [intCustomAgingSetupFilterId]       INT NOT NULL IDENTITY, 
    [intCustomAgingSetupId]             INT NOT NULL,
    [strFilterField]                    NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]                      NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strFrom]                           NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strTo]                             NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strOperator]                       NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                  INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblARCustomAgingSetupFilter] PRIMARY KEY ([intCustomAgingSetupFilterId]),
    CONSTRAINT [FK_tblARCustomAgingSetupFilter_tblARCustomAgingSetup_intCustomAgingSetupId] FOREIGN KEY ([intCustomAgingSetupId]) REFERENCES [dbo].[tblARCustomAgingSetup] ([intCustomAgingSetupId]) ON DELETE CASCADE
)