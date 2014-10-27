PRINT N'Dropping [dbo].[uspICPostCosting]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICPostCosting' and type = 'P') 
		DROP PROCEDURE [dbo].[uspICPostCosting];
GO

PRINT N'Dropping [dbo].[uspICValidateCostingOnPost]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICValidateCostingOnPost' and type = 'P') 
		DROP PROCEDURE [dbo].[uspICValidateCostingOnPost];
GO

PRINT N'Dropping [dbo].[uspICProcessCosting]...';
GO
	IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICProcessCosting' and type = 'P') 
		DROP PROCEDURE [dbo].[uspICProcessCosting];
GO
