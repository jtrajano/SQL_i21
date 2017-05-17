CREATE TABLE [dbo].[tblSCScaleOperator]
(
	[intScaleOperatorId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL, 
	[intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSCTicketScaleOperator] PRIMARY KEY ([intScaleOperatorId]),
	CONSTRAINT [FK_tblSCScaleOperator_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId])
)
