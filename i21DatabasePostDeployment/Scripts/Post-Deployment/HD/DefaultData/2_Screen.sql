IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'HelpDesk.view.Campaign')
    BEGIN
        INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomTab], [intConcurrencyId], [strGroupName])
            VALUES (N'Campaign', N'Campaign', N'HelpDesk.view.Campaign', N'Help Desk', N'tblHDOpportunityCampaign', convert(bit,0), 0, N'Support')
        END
ELSE
    BEGIN
        UPDATE tblSMScreen
        SET strTableName = N'tblHDOpportunityCampaign', ysnCustomTab = convert(bit,0)
        WHERE strNamespace = 'HelpDesk.view.Campaign'
    END