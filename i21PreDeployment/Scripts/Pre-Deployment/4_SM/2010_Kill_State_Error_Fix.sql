IF ( ISNULL(CAST(SERVERPROPERTY('ProductMajorVersion') AS INT), 0) >= 15 ) -- RUN ONLY FOR SQL SERVER 2019 OR LATER ref: https://stackoverflow.com/a/52940648/13726696
    BEGIN
        PRINT 'SET SCALAR UDF INLINING TO OFF'
        ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF
    END
GO