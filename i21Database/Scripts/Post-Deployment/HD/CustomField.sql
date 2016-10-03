IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstCRMCampaign'))
BEGIN
    print('/*******************  BEGIN Creating CRM Campaign Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstCRMCampaign]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstCRMCampaign] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstCRMCampaign_tblCRMCampaign] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Help Desk Campaign Custom Table *******************/')
END