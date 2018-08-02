CREATE TABLE [dbo].[tblCTComponentMap]
(
	intComponentMapId   INT IDENTITY(1,1) NOT NULL,
	strComponent	    NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL,
	intItemId		    INT,

	CONSTRAINT [PK_tblCTComponentMap_intComponentMapId] PRIMARY KEY CLUSTERED (intComponentMapId ASC),
	CONSTRAINT [UQ_tblCTComponentMap_intItemId] UNIQUE (intItemId), 
	CONSTRAINT [UQ_tblCTComponentMap_strComponent] UNIQUE (strComponent), 
	CONSTRAINT [FK_tblCTComponentMap_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
