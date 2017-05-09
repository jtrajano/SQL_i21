CREATE TABLE [dbo].[tblSCScaleOperator]
(
	[intScaleOperatorId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [strName] NVARCHAR(100) NULL, 
	[intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSCTicketScaleOperator] PRIMARY KEY ([intScaleOperatorId]),
	CONSTRAINT [FK_tblSCScaleOperator_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId])
)
