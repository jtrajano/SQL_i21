
GO
IF NOT EXISTS (SELECT 1 FROM tblCMResponsiblePartyOption)
BEGIN
    INSERT INTO tblCMResponsiblePartyOption (strOptionName)
    SELECT 'Umatched Transaction' UNION
    SELECT 'Unmatched Configuration'
END
GO