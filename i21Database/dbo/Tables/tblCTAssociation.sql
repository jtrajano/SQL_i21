CREATE TABLE [dbo].[tblCTAssociation]
(
	[intAssociationId] INT NOT NULL PRIMARY KEY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strComment] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NOT NULL
)
