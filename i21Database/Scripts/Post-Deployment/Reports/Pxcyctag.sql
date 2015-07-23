IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pxcyctag]') AND type in (N'U')) 
BEGIN
	DELETE FROM pxcyctag
	
	--pxcyctag_cycle_id
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_cycle_id' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_cycle_id char(6)NOT NULL 
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_cycle_id char(6)NOT NULL  
    END
    
    --pxcyctag_cycle_seq
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_cycle_seq' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
		DROP INDEX Ipxcyctag0 ON  pxcyctag 
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_cycle_seq smallint NOT NULL 
		CREATE UNIQUE INDEX Ipxcyctag0 ON pxcyctag (pxcyctag_cycle_seq);
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_cycle_seq smallint NOT NULL  
    END
	
	--pxcyctag_end_rev_dt
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_end_rev_dt' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_end_rev_dt int NULL 
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_end_rev_dt int NULL 
    END
    
    --pxcyctag_beg_rev_dt
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_beg_rev_dt' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_beg_rev_dt int NULL 
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_beg_rev_dt int NULL 
    END
    
    --pxcyctag_i21_report_title
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_i21_report_title' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_i21_report_title char(100) NULL 
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_i21_report_title char(100) NULL 
    END
    
    --pxcyctag_processed_yn
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'pxcyctag_processed_yn' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
    BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN pxcyctag_processed_yn char(1) NULL 
    END
    ELSE
    BEGIN
		ALTER TABLE pxcyctag 
		ADD pxcyctag_processed_yn char(1) NULL 
    END
    
    
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'A4GLIdentity' AND OBJECT_ID = OBJECT_ID(N'pxcyctag'))
	BEGIN
        ALTER TABLE pxcyctag 
		ALTER COLUMN A4GLIdentity NUMERIC(9, 0) NOT NULL 
    END
    ELSE
    BEGIN
        ALTER TABLE pxcyctag 
		ADD A4GLIdentity NUMERIC(9, 0) NOT NULL IDENTITY
    END
END
GO

