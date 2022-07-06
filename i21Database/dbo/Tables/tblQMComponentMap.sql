CREATE TABLE [dbo].[tblQMComponentMap]
(
	intComponentMapId   INT IDENTITY(1,1) NOT NULL,
	strComponent	    NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL,
	intPropertyId	    INT,
	intConcurrencyId	INT,

	CONSTRAINT [PK_tblQMComponentMap_intComponentMapId] PRIMARY KEY CLUSTERED (intComponentMapId ASC),
	CONSTRAINT [UQ_tblQMComponentMap_strComponent] UNIQUE (strComponent), 
	CONSTRAINT [FK_tblQMComponentMap_tblQMProperty_intPropertyId] FOREIGN KEY (intPropertyId) REFERENCES [tblQMProperty](intPropertyId)
)
