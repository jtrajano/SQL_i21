CREATE TABLE [dbo].[tblLGNotifyPartyGroup]
(
	[intNotifyPartyGroupId] INT NOT NULL IDENTITY (1, 1),
    [intCountryId] INT NOT NULL, 
    [strDestinationPort] NVARCHAR(200) NOT NULL,
    [strSubLocationName] NVARCHAR(200) NOT NULL,
    [intConcurrencyId] INT NOT NULL, 

    CONSTRAINT [PK_tblLGNotifyPartyGroup] PRIMARY KEY ([intNotifyPartyGroupId]), 
    CONSTRAINT [FK_tblLGNotifyPartyGroup_tblSMCountry] FOREIGN KEY ([intCountryId]) REFERENCES [tblSMCountry]([intCountryID])
)
