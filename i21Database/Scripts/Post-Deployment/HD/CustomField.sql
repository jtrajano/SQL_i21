IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstHDCampaign'))
BEGIN
    print('/*******************  BEGIN Creating Help Desk Campaign Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstHDCampaign]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstHDCampaign] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstHDCampaign_tblHDOpportunityCampaign] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblHDOpportunityCampaign] ([intOpportunityCampaignId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Help Desk Campaign Custom Table *******************/')
END