IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'HelpDesk.view.Campaign')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
            VALUES (N'Campaign', N'Campaign', N'HelpDesk.view.Campaign', N'Help Desk', N'tblHDOpportunityCampaign', 0)
        END
ELSE
    BEGIN
        UPDATE tblSMScreen
        SET strTableName = N'tblHDOpportunityCampaign'
        WHERE strNamespace = 'HelpDesk.view.Campaign'
    END