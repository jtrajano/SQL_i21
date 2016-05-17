--EXEC tSQLt.NewTestClass 'AP'
--EXEC tSQLt.NewTestClass 'AP Import'
CREATE SCHEMA [AP]
	AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'tSQLt.TestClass', @value = 1, @level0type = N'SCHEMA', @level0name = N'AP';
GO
CREATE SCHEMA [AP Import]
	AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'tSQLt.TestClass', @value = 1, @level0type = N'SCHEMA', @level0name = N'AP Import';