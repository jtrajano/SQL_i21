CREATE TABLE tblFAFixedAssetJournal
(
    intFixedAssetJournalId INT IDENTITY(1,1),
    intJournalId INT NOT NULL,
    intAssetId INT NOT NULL,
    intConcurrencyId INT NOT NULL,
    dtmDateEntered DATETIME NOT NULL,
    intEntityId INT NOT NULL,
    CONSTRAINT [PK_tblFAFixedAssetJournal] PRIMARY KEY CLUSTERED ([intFixedAssetJournalId] ASC),
    CONSTRAINT [FK_tblFAFixedAssetJournal_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
