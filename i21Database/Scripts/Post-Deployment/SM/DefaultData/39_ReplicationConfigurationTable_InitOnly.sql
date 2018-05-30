PRINT N'REPLICATION TABLE Initialization Only'
GO

UPDATE tblSMReplicationConfigurationTable SET ysnInitOnly = 1 
WHERE intReplicationConfigurationTableId in 
(
	SELECT intReplicationConfigurationTableId
	FROM tblSMReplicationTable as tbl
	INNER Join tblSMReplicationConfigurationTable as contbl
	ON tbl.intReplicationTableId = contbl.intReplicationTableId
	WHERE strTableName in (
		'tblGLAccountSystem', 

		'tblGLAccountReallocation',

		'tblGLAccountTemplate',

		'tblGLAccountTemplateDetail',

		'tblGLAccountSystem',

		'tblGLCrossReferenceMapping', 

		'tblGLCOATemplate', 

		'tblGLCOATemplateDetail',

		'tblGLCompanyPreferenceOption'
	)
)


PRINT N'END REPLICATION TABLE Initialization Only'
GO