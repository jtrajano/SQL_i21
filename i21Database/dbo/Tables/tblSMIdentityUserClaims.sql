CREATE TABLE [dbo].[tblSMIdentityUserClaims] (
    [intUserClaimId]         INT IDENTITY (1, 1) NOT NULL,
    [intUserId]              INT NOT NULL,
    [strClaimType]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strClaimValue]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_dbo.tblSMIdentityUserClaims] PRIMARY KEY CLUSTERED ([intUserClaimId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_intUserId]
    ON [dbo].[tblSMIdentityUserClaims]([intUserId] ASC);