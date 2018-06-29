CREATE TABLE [dbo].[tblCTAssociation]
(
	[intAssociationId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intLastWeighingDays] INT NULL,
    [intClaimValidTill] INT NULL, 
    [ysnActive] BIT NOT NULL,
	CONSTRAINT [PK_tblCTAssociation_intAssociationId] PRIMARY KEY CLUSTERED ([intAssociationId] ASC), 
    CONSTRAINT [UK_tblCTAssociation_strName] UNIQUE ([strName])
)
