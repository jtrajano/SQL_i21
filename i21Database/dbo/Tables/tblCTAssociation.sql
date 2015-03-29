CREATE TABLE [dbo].[tblCTAssociation]
(
	[intAssociationId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strComment] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NOT NULL,
	CONSTRAINT [PK_tblCTAssociation_intAssociationId] PRIMARY KEY CLUSTERED ([intAssociationId] ASC), 
    CONSTRAINT [UK_tblCTAssociation_strName] UNIQUE ([strName])
)
