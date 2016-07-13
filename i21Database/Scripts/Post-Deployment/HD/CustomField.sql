IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstHDOpportunityCampaign'))
BEGIN
    print('/*******************  BEGIN Creating Help Desk Campaign Custom Table *******************/')
    EXEC('
        CREATE TABLE [dbo].[cstHDOpportunityCampaign]
        (
            [intId] INT NOT NULL,
            CONSTRAINT [PK_cstHDOpportunityCampaign] PRIMARY KEY CLUSTERED ([intId] ASC),
            CONSTRAINT [FK_cstHDOpportunityCampaign_tblHDOpportunityCampaign] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblHDOpportunityCampaign] ([intOpportunityCampaignId]) ON DELETE CASCADE
        );
    ')
    print('/*******************  END Creating Help Desk Campaign Custom Table *******************/')
END