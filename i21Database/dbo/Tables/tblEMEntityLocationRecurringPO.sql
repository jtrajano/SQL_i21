CREATE TABLE [dbo].[tblEMEntityLocationRecurringPO] (
    [intEntityLocationRecurringPOId]    INT                 IDENTITY (1, 1) NOT NULL,
    [intEntityLocationId]               INT                 NOT NULL,    
    [strRecurringPONumber]              NVARCHAR(50)        COLLATE Latin1_General_CI_AS NULL,    
    [dtmFrom]				            DATETIME            NOT NULL,    
    [dtmTo]				                DATETIME            NOT NULL,    
    [intConcurrencyId]			        INT                 NOT NULL,
    [guiApiUniqueId]                    UNIQUEIDENTIFIER    NULL,
    CONSTRAINT [PK_tblEMEntityLocationRecurringPO] PRIMARY KEY CLUSTERED ([intEntityLocationRecurringPOId] ASC),
	CONSTRAINT [FK_tblEMEntityLocationRecurringPO_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]) ON DELETE CASCADE,
);


