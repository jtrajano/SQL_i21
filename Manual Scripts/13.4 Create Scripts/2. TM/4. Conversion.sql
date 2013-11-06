print N'BEGIN CONVERSION - i21 TANK MANAGEMENT..'

print N'BEGIN Indexing legacy tables required for i21 - Tank Management..'
print ''

	IF EXISTS(SELECT TOP 1 1 from sys.indexes WHERE NAME = 'IX_agitmmst_A4GLIdentity' and object_id = OBJECT_ID(N'agitmmst'))
	BEGIN
		print 'agitmmst.IX_agitmmst_A4GLIdentity is existing..'
		print 'BEGIN drop agitmmst.IX_agitmmst_A4GLIdentity..'
		
		DROP INDEX agitmmst.IX_agitmmst_A4GLIdentity
	END	

GO

	print 'CREATE agitmmst.IX_agitmmst_A4GLIdentity..'
	CREATE NONCLUSTERED INDEX IX_agitmmst_A4GLIdentity
	ON agitmmst
	(A4GLIdentity)
	WITH (DROP_EXISTING =  OFF) --setting this to ON drops the index if it exists however, it throws error when it is not existing.
	ON [default]
	-- print 'EXISTS'	

print ''
GO

	IF EXISTS(SELECT TOP 1 1 from sys.indexes WHERE NAME = 'IX_agcusmst_A4GLIdentity' and object_id = OBJECT_ID(N'agcusmst'))
	BEGIN
		print 'agcusmst.IX_agcusmst_A4GLIdentity is existing..'
		print 'BEGIN drop agcusmst.IX_agcusmst_A4GLIdentity..'
		
		DROP INDEX agcusmst.IX_agcusmst_A4GLIdentity
	END	

	print 'CREATE agcusmst.IX_agitmmst_A4GLIdentity..'
	CREATE NONCLUSTERED INDEX IX_agcusmst_A4GLIdentity
	ON agcusmst
	(A4GLIdentity)
	WITH (DROP_EXISTING =  OFF) --setting this to ON drops the index if it exists however, it throws error when it is not existing.
	ON [default]
	-- print 'EXISTS'	


print ''

print N'Rebuilding indexes..'

GO

	alter index all on agcusmst rebuild
	alter index all on agitmmst rebuild

	alter index all on agcusmst reorganize
	alter index all on agitmmst reorganize


print ''
print N'DONE Indexing legacy tables required for i21 - Tank Management'